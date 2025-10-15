const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const authenticateUser = require('../middleware/auth');

// Stripe setup
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * POST /api/payment/create-checkout-session
 * Create a Stripe checkout session for subscription
 */
router.post('/create-checkout-session', authenticateUser, async (req, res) => {
    try {
        const userId = req.user.id;
        const { price_id } = req.body;  // Stripe price ID for your subscription
        
        // Get or create Stripe customer
        const userResult = await pool.query(
            'SELECT * FROM users WHERE user_id = $1',
            [userId]
        );
        
        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        const user = userResult.rows[0];
        let customerId = user.stripe_customer_id;
        
        // Create Stripe customer if doesn't exist
        if (!customerId) {
            const customer = await stripe.customers.create({
                email: user.email,
                metadata: {
                    user_id: userId
                }
            });
            
            customerId = customer.id;
            
            // Save customer ID
            await pool.query(
                'UPDATE users SET stripe_customer_id = $1 WHERE user_id = $2',
                [customerId, userId]
            );
        }
        
        // Create checkout session
        const session = await stripe.checkout.sessions.create({
            customer: customerId,
            mode: 'subscription',
            payment_method_types: ['card'],
            line_items: [
                {
                    price: price_id || process.env.STRIPE_PRICE_ID,  // Your default price ID
                    quantity: 1,
                }
            ],
            success_url: `${process.env.APP_URL}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${process.env.APP_URL}/payment-cancelled`,
            metadata: {
                user_id: userId
            }
        });
        
        res.json({
            checkout_url: session.url,
            session_id: session.id
        });
        
    } catch (error) {
        console.error('Create checkout session error:', error);
        res.status(500).json({ error: 'Failed to create checkout session' });
    }
});

/**
 * POST /api/payment/webhook
 * Handle Stripe webhooks
 */
router.post('/webhook', express.raw({type: 'application/json'}), async (req, res) => {
    const sig = req.headers['stripe-signature'];
    
    let event;
    
    try {
        event = stripe.webhooks.constructEvent(req.body, sig, STRIPE_WEBHOOK_SECRET);
    } catch (err) {
        console.error('Webhook signature verification failed:', err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }
    
    // Handle the event
    switch (event.type) {
        case 'checkout.session.completed':
            await handleCheckoutCompleted(event.data.object);
            break;
            
        case 'customer.subscription.created':
            await handleSubscriptionCreated(event.data.object);
            break;
            
        case 'customer.subscription.updated':
            await handleSubscriptionUpdated(event.data.object);
            break;
            
        case 'customer.subscription.deleted':
            await handleSubscriptionDeleted(event.data.object);
            break;
            
        case 'invoice.payment_succeeded':
            await handlePaymentSucceeded(event.data.object);
            break;
            
        case 'invoice.payment_failed':
            await handlePaymentFailed(event.data.object);
            break;
            
        default:
            console.log(`Unhandled event type ${event.type}`);
    }
    
    res.json({received: true});
});

// MARK: - Webhook Handlers

async function handleCheckoutCompleted(session) {
    console.log('Checkout completed:', session.id);
    
    const userId = session.metadata.user_id;
    const customerId = session.customer;
    const subscriptionId = session.subscription;
    
    // Update user with subscription
    await activateSubscription(userId, customerId, subscriptionId);
}

async function handleSubscriptionCreated(subscription) {
    console.log('Subscription created:', subscription.id);
    
    const customerId = subscription.customer;
    
    // Find user by customer ID
    const userResult = await pool.query(
        'SELECT * FROM users WHERE stripe_customer_id = $1',
        [customerId]
    );
    
    if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].user_id;
        await activateSubscription(userId, customerId, subscription.id);
    }
}

async function handleSubscriptionUpdated(subscription) {
    console.log('Subscription updated:', subscription.id);
    
    const customerId = subscription.customer;
    const status = subscription.status;
    
    const userResult = await pool.query(
        'SELECT * FROM users WHERE stripe_customer_id = $1',
        [customerId]
    );
    
    if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].user_id;
        
        if (status === 'active') {
            await activateSubscription(userId, customerId, subscription.id);
        } else if (status === 'canceled' || status === 'unpaid') {
            await deactivateSubscription(userId);
        }
    }
}

async function handleSubscriptionDeleted(subscription) {
    console.log('Subscription deleted:', subscription.id);
    
    const customerId = subscription.customer;
    
    const userResult = await pool.query(
        'SELECT * FROM users WHERE stripe_customer_id = $1',
        [customerId]
    );
    
    if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].user_id;
        await deactivateSubscription(userId);
    }
}

async function handlePaymentSucceeded(invoice) {
    console.log('Payment succeeded:', invoice.id);
    
    const customerId = invoice.customer;
    const subscriptionId = invoice.subscription;
    
    if (!subscriptionId) return;
    
    // Get subscription details
    const subscription = await stripe.subscriptions.retrieve(subscriptionId);
    
    const userResult = await pool.query(
        'SELECT * FROM users WHERE stripe_customer_id = $1',
        [customerId]
    );
    
    if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].user_id;
        await activateSubscription(userId, customerId, subscriptionId);
        
        // Log payment
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, 'payment_succeeded', $2)
        `, [userId, JSON.stringify({ invoice_id: invoice.id, amount: invoice.amount_paid })]);
    }
}

async function handlePaymentFailed(invoice) {
    console.log('Payment failed:', invoice.id);
    
    const customerId = invoice.customer;
    
    const userResult = await pool.query(
        'SELECT * FROM users WHERE stripe_customer_id = $1',
        [customerId]
    );
    
    if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].user_id;
        
        // Log failed payment
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, 'payment_failed', $2)
        `, [userId, JSON.stringify({ invoice_id: invoice.id })]);
    }
}

// MARK: - Helper Functions

async function activateSubscription(userId, customerId, subscriptionId) {
    try {
        // Get subscription details from Stripe
        const subscription = await stripe.subscriptions.retrieve(subscriptionId);
        
        const currentPeriodEnd = new Date(subscription.current_period_end * 1000);
        
        await pool.query(`
            UPDATE users 
            SET subscription_status = 'active',
                subscription_start_date = NOW(),
                subscription_end_date = $1,
                stripe_customer_id = $2,
                stripe_subscription_id = $3,
                updated_at = NOW()
            WHERE user_id = $4
        `, [currentPeriodEnd, customerId, subscriptionId, userId]);
        
        // Log activation
        await pool.query(`
            INSERT INTO subscription_history 
            (user_id, event_type, new_status, new_end_date, metadata)
            VALUES ($1, 'subscription_activated', 'active', $2, $3)
        `, [userId, currentPeriodEnd, JSON.stringify({ subscription_id: subscriptionId })]);
        
        console.log(`✅ Activated subscription for user ${userId}`);
        
    } catch (error) {
        console.error('Error activating subscription:', error);
    }
}

async function deactivateSubscription(userId) {
    try {
        await pool.query(`
            UPDATE users 
            SET subscription_status = 'cancelled',
                updated_at = NOW()
            WHERE user_id = $1
        `, [userId]);
        
        // Log cancellation
        await pool.query(`
            INSERT INTO subscription_history 
            (user_id, event_type, new_status)
            VALUES ($1, 'subscription_cancelled', 'cancelled')
        `, [userId]);
        
        console.log(`❌ Deactivated subscription for user ${userId}`);
        
    } catch (error) {
        console.error('Error deactivating subscription:', error);
    }
}

/**
 * POST /api/payment/cancel-subscription
 * Cancel user's subscription
 */
router.post('/cancel-subscription', authenticateUser, async (req, res) => {
    try {
        const userId = req.user.id;
        
        const userResult = await pool.query(
            'SELECT * FROM users WHERE user_id = $1',
            [userId]
        );
        
        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        const user = userResult.rows[0];
        
        if (!user.stripe_subscription_id) {
            return res.status(400).json({ error: 'No active subscription found' });
        }
        
        // Cancel subscription in Stripe
        await stripe.subscriptions.cancel(user.stripe_subscription_id);
        
        res.json({
            success: true,
            message: 'Subscription cancelled successfully'
        });
        
    } catch (error) {
        console.error('Cancel subscription error:', error);
        res.status(500).json({ error: 'Failed to cancel subscription' });
    }
});

module.exports = router;

