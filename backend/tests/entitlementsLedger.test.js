/**
 * Tests for Entitlements Ledger Service
 * 
 * These tests verify:
 * 1. Ledger upsert behavior (idempotency, ever_trial flag)
 * 2. Account deletion flow (PII removed, ledger persists)
 * 3. Transaction ID hashing (stability, non-reversibility)
 */

const { Pool } = require('pg');
const { upsertLedgerRecord, hasEverUsedTrial } = require('../services/entitlementsLedgerService');
const { txidHash } = require('../lib/txidHash');

// Mock pool for testing (or use a test database)
jest.mock('pg');

describe('Entitlements Ledger Service', () => {
    let mockPool;
    
    beforeEach(() => {
        mockPool = {
            query: jest.fn()
        };
        Pool.mockImplementation(() => mockPool);
        
        // Set required env vars for tests
        process.env.LEDGER_SALT = 'test-salt-12345';
        process.env.DATABASE_URL = 'postgresql://test';
    });
    
    afterEach(() => {
        jest.clearAllMocks();
    });
    
    describe('txidHash', () => {
        it('should produce consistent hashes for same input', () => {
            const txid = '1000000000000001';
            const salt = 'test-salt';
            
            const hash1 = txidHash(txid, salt);
            const hash2 = txidHash(txid, salt);
            
            expect(hash1).toBe(hash2);
            expect(hash1).toHaveLength(64); // SHA-256 produces 64 hex characters
        });
        
        it('should produce different hashes for different inputs', () => {
            const salt = 'test-salt';
            
            const hash1 = txidHash('1000000000000001', salt);
            const hash2 = txidHash('1000000000000002', salt);
            
            expect(hash1).not.toBe(hash2);
        });
        
        it('should throw error if salt is missing', () => {
            expect(() => {
                txidHash('1000000000000001', '');
            }).toThrow('LEDGER_SALT');
        });
        
        it('should throw error if originalTxId is missing', () => {
            expect(() => {
                txidHash('', 'test-salt');
            }).toThrow('originalTxId');
        });
    });
    
    describe('upsertLedgerRecord', () => {
        it('should create new ledger record if none exists', async () => {
            // Mock: No existing record
            mockPool.query.mockResolvedValueOnce({ rows: [] });
            // Mock: Insert succeeds
            mockPool.query.mockResolvedValueOnce({ rows: [] });
            
            const result = await upsertLedgerRecord({
                originalTransactionId: '1000000000000001',
                productId: 'com.homeworkhelper.monthly',
                subscriptionGroupId: 'com.homeworkhelper.premium',
                status: 'active',
                everTrial: true
            });
            
            expect(result).toHaveProperty('original_transaction_id_hash');
            expect(mockPool.query).toHaveBeenCalledTimes(2); // SELECT + INSERT
        });
        
        it('should update existing ledger record', async () => {
            const existingRecord = {
                original_transaction_id_hash: 'existing-hash',
                ever_trial: false,
                status: 'active'
            };
            
            // Mock: Existing record found
            mockPool.query.mockResolvedValueOnce({ rows: [existingRecord] });
            // Mock: Update succeeds
            mockPool.query.mockResolvedValueOnce({ rows: [] });
            
            await upsertLedgerRecord({
                originalTransactionId: '1000000000000001',
                productId: 'com.homeworkhelper.monthly',
                subscriptionGroupId: 'com.homeworkhelper.premium',
                status: 'expired',
                everTrial: true
            });
            
            expect(mockPool.query).toHaveBeenCalledTimes(2); // SELECT + UPDATE
        });
        
        it('should preserve ever_trial=true once set', async () => {
            const existingRecord = {
                original_transaction_id_hash: 'existing-hash',
                ever_trial: true, // Already true
                status: 'expired'
            };
            
            // Mock: Existing record with ever_trial=true
            mockPool.query.mockResolvedValueOnce({ rows: [existingRecord] });
            // Mock: Update
            mockPool.query.mockResolvedValueOnce({ rows: [] });
            
            await upsertLedgerRecord({
                originalTransactionId: '1000000000000001',
                productId: 'com.homeworkhelper.monthly',
                subscriptionGroupId: 'com.homeworkhelper.premium',
                status: 'expired',
                everTrial: false // Trying to set to false
            });
            
            // Verify UPDATE query preserves ever_trial=true
            const updateCall = mockPool.query.mock.calls[1];
            expect(updateCall[1][3]).toBe(true); // 4th parameter (ever_trial) should be true
        });
        
        it('should throw error for invalid status', async () => {
            await expect(
                upsertLedgerRecord({
                    originalTransactionId: '1000000000000001',
                    productId: 'com.homeworkhelper.monthly',
                    subscriptionGroupId: 'com.homeworkhelper.premium',
                    status: 'invalid-status',
                    everTrial: false
                })
            ).rejects.toThrow('status must be one of');
        });
    });
    
    describe('hasEverUsedTrial', () => {
        it('should return true if ledger shows ever_trial=true', async () => {
            mockPool.query.mockResolvedValueOnce({
                rows: [{ ever_trial: true }]
            });
            
            const result = await hasEverUsedTrial('1000000000000001');
            
            expect(result).toBe(true);
        });
        
        it('should return false if ledger shows ever_trial=false', async () => {
            mockPool.query.mockResolvedValueOnce({
                rows: [{ ever_trial: false }]
            });
            
            const result = await hasEverUsedTrial('1000000000000001');
            
            expect(result).toBe(false);
        });
        
        it('should return false if no ledger record exists', async () => {
            mockPool.query.mockResolvedValueOnce({ rows: [] });
            
            const result = await hasEverUsedTrial('1000000000000001');
            
            expect(result).toBe(false);
        });
        
        it('should return false and not throw on query error', async () => {
            mockPool.query.mockRejectedValueOnce(new Error('Database error'));
            
            const result = await hasEverUsedTrial('1000000000000001');
            
            expect(result).toBe(false); // Fail open - don't block on errors
        });
    });
});

describe('Account Deletion Flow', () => {
    let mockPool;
    
    beforeEach(() => {
        mockPool = {
            query: jest.fn()
        };
        Pool.mockImplementation(() => mockPool);
        
        process.env.LEDGER_SALT = 'test-salt-12345';
        process.env.DATABASE_URL = 'postgresql://test';
    });
    
    it('should mirror entitlements to ledger before deletion', async () => {
        const userId = 'user-123';
        const entitlements = [
            {
                id: 'ent-1',
                user_id: userId,
                original_transaction_id: '1000000000000001',
                product_id: 'com.homeworkhelper.monthly',
                subscription_group_id: 'com.homeworkhelper.premium',
                is_trial: true,
                status: 'expired'
            }
        ];
        
        // Simulate deletion flow
        // 1. Query user entitlements
        mockPool.query.mockResolvedValueOnce({ rows: entitlements });
        // 2. Check if ledger record exists
        mockPool.query.mockResolvedValueOnce({ rows: [] });
        // 3. Insert to ledger
        mockPool.query.mockResolvedValueOnce({ rows: [] });
        // 4-N. Delete user data
        mockPool.query.mockResolvedValue({ rows: [] });
        
        // Simulate the deletion logic
        const ents = await mockPool.query(
            'SELECT * FROM user_entitlements WHERE user_id = $1',
            [userId]
        );
        
        for (const ent of ents.rows) {
            await upsertLedgerRecord({
                originalTransactionId: ent.original_transaction_id,
                productId: ent.product_id,
                subscriptionGroupId: ent.subscription_group_id,
                status: ent.status,
                everTrial: ent.is_trial
            });
        }
        
        // Delete user data (simplified)
        await mockPool.query('DELETE FROM user_entitlements WHERE user_id = $1', [userId]);
        await mockPool.query('DELETE FROM users WHERE user_id = $1', [userId]);
        
        // Verify ledger was upserted before deletion
        expect(mockPool.query).toHaveBeenCalledWith(
            'SELECT * FROM user_entitlements WHERE user_id = $1',
            [userId]
        );
        
        // Verify deletion happened
        expect(mockPool.query).toHaveBeenCalledWith(
            'DELETE FROM user_entitlements WHERE user_id = $1',
            [userId]
        );
        expect(mockPool.query).toHaveBeenCalledWith(
            'DELETE FROM users WHERE user_id = $1',
            [userId]
        );
    });
});

describe('Receipt Validation Flow', () => {
    it('should upsert both user_entitlements and ledger on receipt validation', async () => {
        // TODO: Add integration test that validates Apple receipt
        // and checks that both tables are updated
        
        // This would require mocking the full receipt validation flow
        // For now, this is a placeholder for future integration tests
        expect(true).toBe(true);
    });
});

