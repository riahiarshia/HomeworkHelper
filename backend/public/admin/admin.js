// Admin Dashboard JavaScript
// Homework Helper Admin Panel

const API_BASE_URL = window.location.origin + '/api';
let currentUser = null;
let currentPage = 1;
let adminToken = localStorage.getItem('adminToken');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    if (adminToken) {
        checkAuth();
    } else {
        showLoginScreen();
    }
    
    setupEventListeners();
});

function setupEventListeners() {
    // Login form
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    
    // Create promo form
    document.getElementById('createPromoForm').addEventListener('submit', handleCreatePromo);
    
    // Create user form
    document.getElementById('createUserForm').addEventListener('submit', handleCreateUser);
    
    // Change password form
    document.getElementById('changePasswordForm').addEventListener('submit', handleChangePassword);
    
    // Edit membership form
    document.getElementById('editMembershipForm').addEventListener('submit', handleEditMembership);
    
    // Search
    document.getElementById('userSearch').addEventListener('keyup', (e) => {
        if (e.key === 'Enter') loadUsers();
    });
    
    document.getElementById('statusFilter').addEventListener('change', loadUsers);
}

// MARK: - Authentication

async function handleLogin(e) {
    e.preventDefault();
    
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;
    
    try {
        const response = await fetch(`${API_BASE_URL}/auth/admin-login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            adminToken = data.token;
            localStorage.setItem('adminToken', adminToken);
            currentUser = data.admin;
            showDashboard();
            loadDashboardData();
        } else {
            showError('loginError', data.error || 'Login failed');
        }
    } catch (error) {
        console.error('Login error:', error);
        showError('loginError', 'Network error. Please try again.');
    }
}

async function checkAuth() {
    try {
        const response = await apiRequest('/admin/stats', 'GET');
        if (response) {
            showDashboard();
            loadDashboardData();
        } else {
            logout();
        }
    } catch (error) {
        logout();
    }
}

function logout() {
    adminToken = null;
    localStorage.removeItem('adminToken');
    showLoginScreen();
}

function showLoginScreen() {
    document.getElementById('loginScreen').style.display = 'block';
    document.getElementById('dashboard').style.display = 'none';
}

function showDashboard() {
    document.getElementById('loginScreen').style.display = 'none';
    document.getElementById('dashboard').style.display = 'block';
}

// MARK: - API Helper

async function apiRequest(endpoint, method = 'GET', body = null) {
    const options = {
        method,
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${adminToken}`
        }
    };
    
    if (body) {
        options.body = JSON.stringify(body);
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, options);
        
        if (response.status === 401) {
            logout();
            return null;
        }
        
        return await response.json();
    } catch (error) {
        console.error('API request error:', error);
        throw error;
    }
}

// MARK: - Navigation

function showTab(tabName) {
    // Update nav tabs
    document.querySelectorAll('.nav-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    event.target.classList.add('active');
    
    // Update sections
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    
    const sectionMap = {
        'dashboard': 'dashboardSection',
        'users': 'usersSection',
        'devices': 'devicesSection',
        'promo-codes': 'promoCodesSection',
        'api-usage': 'apiUsageSection',
        'ledger': 'ledgerSection',
        'audit-log': 'auditLogSection'
    };
    
    document.getElementById(sectionMap[tabName]).classList.add('active');
    
    // Load data for the tab
    if (tabName === 'dashboard') {
        loadDashboardData();
    } else if (tabName === 'api-usage') {
        loadApiUsageData();
    } else if (tabName === 'users') {
        loadUsers();
    } else if (tabName === 'devices') {
        loadDeviceAnalytics();
        loadFraudFlags();
    } else if (tabName === 'promo-codes') {
        loadPromoCodes();
    } else if (tabName === 'ledger') {
        loadLedgerData();
    } else if (tabName === 'audit-log') {
        loadAuditLogData();
    }
}

// MARK: - Dashboard Stats

async function loadDashboardData() {
    try {
        const stats = await apiRequest('/admin/stats', 'GET');
        
        if (stats) {
            document.getElementById('totalUsers').textContent = stats.total_users || 0;
            document.getElementById('activeSubs').textContent = stats.active_subscriptions || 0;
            document.getElementById('trialUsers').textContent = stats.trial_users || 0;
            document.getElementById('expiredUsers').textContent = stats.expired_subscriptions || 0;
        }
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// MARK: - Users Management

async function loadUsers(page = 1, forceRefresh = false) {
    const search = document.getElementById('userSearch').value;
    const status = document.getElementById('statusFilter').value;
    
    const queryParams = new URLSearchParams({
        page,
        limit: 20,
        search,
        status
    });
    
    // Add cache buster for force refresh
    if (forceRefresh) {
        queryParams.append('_t', Date.now());
        console.log('🔄 Force refresh with cache buster');
    }
    
    try {
        const data = await apiRequest(`/admin/users?${queryParams}`, 'GET');
        
        if (data) {
            console.log('📊 Loaded', data.users.length, 'users');
            displayUsers(data.users);
            displayPagination(data.pagination);
        }
    } catch (error) {
        console.error('Error loading users:', error);
        document.getElementById('usersTable').innerHTML = '<p class="loading">Failed to load users</p>';
    }
}

// Track selected users for bulk operations
let selectedUsers = new Set();

function displayUsers(users) {
    if (!users || users.length === 0) {
        document.getElementById('usersTable').innerHTML = '<p class="loading">No users found</p>';
        updateBulkDeleteButton();
        return;
    }
    
    const html = `
        <table>
            <thead>
                <tr>
                    <th style="width: 40px;">
                        <input type="checkbox" id="selectAllCheckbox" onchange="toggleSelectAll()" 
                               ${selectedUsers.size === users.length ? 'checked' : ''}>
                    </th>
                    <th>User ID</th>
                    <th>Email</th>
                    <th>Username</th>
                    <th>Status</th>
                    <th>Days Left</th>
                    <th>Activity</th>
                    <th>Created</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${users.map(user => `
                    <tr class="${selectedUsers.has(user.user_id) ? 'selected-row' : ''}">
                        <td>
                            <input type="checkbox" 
                                   class="user-checkbox" 
                                   data-user-id="${user.user_id}"
                                   onchange="toggleUserSelection('${user.user_id}')"
                                   ${selectedUsers.has(user.user_id) ? 'checked' : ''}>
                        </td>
                        <td style="font-size: 11px; max-width: 150px; overflow: hidden; text-overflow: ellipsis;" title="${user.user_id}">
                            ${user.user_id.substring(0, 8)}...
                        </td>
                        <td>${user.email}</td>
                        <td>${user.username || '-'}</td>
                        <td>${getStatusBadge(user.subscription_status)}</td>
                        <td>${Math.floor(user.days_remaining)} days</td>
                        <td>
                            <div style="font-size: 11px;">
                                <strong>${user.total_logins || 0}</strong> total<br>
                                <span style="color: #27ae60;">${user.logins_last_7_days || 0}</span> last 7d<br>
                                <span style="color: #7f8c8d;">${user.unique_devices || 0}</span> devices
                            </div>
                        </td>
                        <td>${formatDate(user.created_at)}</td>
                        <td>
                            <button class="btn btn-primary btn-sm" onclick="viewUserDetails('${user.user_id}')">View</button>
                            <button class="btn btn-${user.is_active ? 'danger' : 'success'} btn-sm" 
                                    onclick="toggleUserAccess('${user.user_id}', ${!user.is_active})">
                                ${user.is_active ? 'Deactivate' : 'Activate'}
                            </button>
                            <button class="btn btn-warning btn-sm" onclick="showExtendTrialModal('${user.user_id}', '${user.email}')">
                                Trial
                            </button>
                        </td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    
    document.getElementById('usersTable').innerHTML = html;
    updateBulkDeleteButton();
}

function toggleUserSelection(userId) {
    if (selectedUsers.has(userId)) {
        selectedUsers.delete(userId);
    } else {
        selectedUsers.add(userId);
    }
    updateBulkDeleteButton();
    
    // Update row styling
    const checkbox = document.querySelector(`input[data-user-id="${userId}"]`);
    if (checkbox) {
        const row = checkbox.closest('tr');
        if (selectedUsers.has(userId)) {
            row.classList.add('selected-row');
        } else {
            row.classList.remove('selected-row');
        }
    }
}

function toggleSelectAll() {
    const checkboxes = document.querySelectorAll('.user-checkbox');
    const selectAllCheckbox = document.getElementById('selectAllCheckbox');
    
    if (selectAllCheckbox.checked) {
        // Select all
        checkboxes.forEach(cb => {
            const userId = cb.dataset.userId;
            selectedUsers.add(userId);
            cb.checked = true;
            cb.closest('tr').classList.add('selected-row');
        });
    } else {
        // Deselect all
        checkboxes.forEach(cb => {
            const userId = cb.dataset.userId;
            selectedUsers.delete(userId);
            cb.checked = false;
            cb.closest('tr').classList.remove('selected-row');
        });
    }
    
    updateBulkDeleteButton();
}

function updateBulkDeleteButton() {
    const bulkDeleteBtn = document.getElementById('bulkDeleteBtn');
    const selectedCount = document.getElementById('selectedCount');
    
    if (selectedUsers.size > 0) {
        bulkDeleteBtn.style.display = 'block';
        selectedCount.textContent = selectedUsers.size;
    } else {
        bulkDeleteBtn.style.display = 'none';
    }
}

async function bulkDeleteUsers() {
    if (selectedUsers.size === 0) {
        alert('No users selected');
        return;
    }
    
    const confirmed = confirm(`Are you sure you want to delete ${selectedUsers.size} user(s)? This action cannot be undone.`);
    if (!confirmed) return;
    
    const userIds = Array.from(selectedUsers);
    let successCount = 0;
    let failCount = 0;
    
    // Show progress
    const bulkDeleteBtn = document.getElementById('bulkDeleteBtn');
    const originalText = bulkDeleteBtn.innerHTML;
    bulkDeleteBtn.innerHTML = '⏳ Deleting...';
    bulkDeleteBtn.disabled = true;
    
    // Delete users one by one
    for (const userId of userIds) {
        try {
            await apiRequest(`/admin/users/${userId}`, 'DELETE');
            successCount++;
            selectedUsers.delete(userId);
        } catch (error) {
            console.error(`Failed to delete user ${userId}:`, error);
            failCount++;
        }
    }
    
    // Reset button
    bulkDeleteBtn.innerHTML = originalText;
    bulkDeleteBtn.disabled = false;
    
    // Show result
    if (failCount === 0) {
        alert(`✅ Successfully deleted ${successCount} user(s)`);
    } else {
        alert(`Deleted ${successCount} user(s), ${failCount} failed`);
    }
    
    // Reload users
    selectedUsers.clear();
    updateBulkDeleteButton();
    loadUsers(currentPage);
}

function getStatusBadge(status) {
    const badges = {
        'trial': '<span class="badge badge-info">Trial</span>',
        'active': '<span class="badge badge-success">Active</span>',
        'promo_active': '<span class="badge badge-success">Promo</span>',
        'expired': '<span class="badge badge-danger">Expired</span>',
        'cancelled': '<span class="badge badge-warning">Cancelled</span>'
    };
    return badges[status] || `<span class="badge">${status}</span>`;
}

function displayPagination(pagination) {
    if (!pagination) return;
    
    let html = '';
    
    for (let i = 1; i <= pagination.totalPages; i++) {
        html += `<button class="${i === pagination.page ? 'active' : ''}" 
                         onclick="loadUsers(${i})">
                    ${i}
                 </button>`;
    }
    
    document.getElementById('usersPagination').innerHTML = html;
}

async function viewUserDetails(userId) {
    try {
        const data = await apiRequest(`/admin/users/${userId}`, 'GET');
        
        if (data) {
            const user = data.user;
            const history = data.subscription_history;
            
            const html = `
                <div class="form-group">
                    <label>User ID</label>
                    <input type="text" value="${user.user_id}" readonly>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="text" value="${user.email}" readonly>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <p>${getStatusBadge(user.subscription_status)}</p>
                </div>
                <div class="form-group">
                    <label>Subscription End</label>
                    <input type="text" value="${formatDate(user.subscription_end_date)}" readonly>
                </div>
                <div class="form-group">
                    <label>Promo Code Used</label>
                    <input type="text" value="${user.promo_code_used || 'None'}" readonly>
                </div>
                <div class="form-group">
                    <label>Quick Actions</label>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button class="btn btn-success" onclick="extendSubscription('${user.user_id}', 30)">
                            +30 Days
                        </button>
                        <button class="btn btn-success" onclick="extendSubscription('${user.user_id}', 90)">
                            +90 Days
                        </button>
                        <button class="btn btn-danger" onclick="banUser('${user.user_id}', ${!user.is_banned})">
                            ${user.is_banned ? 'Unban' : 'Ban'} User
                        </button>
                    </div>
                </div>
                <div class="form-group">
                    <label>Management Actions</label>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button class="btn btn-primary" onclick="showChangePasswordModal('${user.user_id}')">
                            Change Password
                        </button>
                        <button class="btn btn-primary" onclick="showEditMembershipModal('${user.user_id}', ${JSON.stringify(user).replace(/"/g, '&quot;')})">
                            Edit Membership
                        </button>
                        <button class="btn btn-danger" onclick="deleteUser('${user.user_id}', '${user.email}')">
                            Delete User
                        </button>
                    </div>
                </div>
                <h3 style="margin-top: 20px;">Subscription History</h3>
                <div style="max-height: 200px; overflow-y: auto; margin-top: 10px;">
                    ${history.map(h => `
                        <div style="padding: 10px; border-bottom: 1px solid #eee;">
                            <strong>${h.event_type}</strong> - ${formatDate(h.created_at)}
                        </div>
                    `).join('')}
                </div>
            `;
            
            document.getElementById('userDetailsContent').innerHTML = html;
            showModal('userDetailsModal');
        }
    } catch (error) {
        console.error('Error loading user details:', error);
        alert('Failed to load user details');
    }
}

async function toggleUserAccess(userId, isActive) {
    if (!confirm(`Are you sure you want to ${isActive ? 'activate' : 'deactivate'} this user?`)) {
        return;
    }
    
    try {
        const result = await apiRequest(`/admin/users/${userId}/toggle-access`, 'POST', { is_active: isActive });
        
        if (result && result.success) {
            alert(result.message);
            loadUsers();
        }
    } catch (error) {
        console.error('Error toggling access:', error);
        alert('Failed to toggle user access');
    }
}

async function extendSubscription(userId, days) {
    if (!confirm(`Extend subscription by ${days} days?`)) {
        return;
    }
    
    try {
        const result = await apiRequest(`/admin/users/${userId}/extend`, 'POST', { days });
        
        if (result && result.success) {
            alert(result.message);
            closeModal('userDetailsModal');
            loadUsers();
        }
    } catch (error) {
        console.error('Error extending subscription:', error);
        alert('Failed to extend subscription');
    }
}

async function banUser(userId, isBanned) {
    const reason = isBanned ? prompt('Reason for ban:') : null;
    
    if (isBanned && !reason) return;
    
    try {
        const result = await apiRequest(`/admin/users/${userId}/ban`, 'POST', { is_banned: isBanned, reason });
        
        if (result && result.success) {
            alert(result.message);
            closeModal('userDetailsModal');
            loadUsers();
        }
    } catch (error) {
        console.error('Error banning user:', error);
        alert('Failed to ban user');
    }
}

// MARK: - Create User

function showCreateUserModal() {
    showModal('createUserModal');
}

async function handleCreateUser(e) {
    e.preventDefault();
    
    const email = document.getElementById('newUserEmail').value;
    const password = document.getElementById('newUserPassword').value;
    const subscription_status = document.getElementById('newUserStatus').value;
    const subscription_days = parseInt(document.getElementById('newUserDays').value);
    
    try {
        // Username is automatically set to email on the backend
        const result = await apiRequest('/admin/users', 'POST', {
            email,
            password,
            subscription_status,
            subscription_days
        });
        
        if (result && result.success) {
            alert(result.message);
            closeModal('createUserModal');
            document.getElementById('createUserForm').reset();
            loadUsers();
        } else {
            alert(result.error || 'Failed to create user');
        }
    } catch (error) {
        console.error('Error creating user:', error);
        alert('Failed to create user');
    }
}

// MARK: - Delete User

async function deleteUser(userId, userEmail) {
    if (!confirm(`Are you sure you want to DELETE user ${userEmail}?\n\nThis action cannot be undone and will remove all user data including subscription history.`)) {
        return;
    }
    
    // Double confirmation for safety
    const confirmation = prompt('Type DELETE to confirm:');
    if (confirmation !== 'DELETE') {
        alert('Deletion cancelled');
        return;
    }
    
    try {
        const result = await apiRequest(`/admin/users/${userId}`, 'DELETE');
        
        if (result && result.success) {
            alert(result.message);
            closeModal('userDetailsModal');
            loadUsers();
        } else {
            alert(result.error || 'Failed to delete user');
        }
    } catch (error) {
        console.error('Error deleting user:', error);
        alert('Failed to delete user');
    }
}

// MARK: - Change Password

function showChangePasswordModal(userId) {
    document.getElementById('changePasswordUserId').value = userId;
    document.getElementById('changePasswordForm').reset();
    closeModal('userDetailsModal');
    showModal('changePasswordModal');
}

async function handleChangePassword(e) {
    e.preventDefault();
    
    const userId = document.getElementById('changePasswordUserId').value;
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    if (newPassword !== confirmPassword) {
        alert('Passwords do not match!');
        return;
    }
    
    if (newPassword.length < 6) {
        alert('Password must be at least 6 characters');
        return;
    }
    
    try {
        const result = await apiRequest(`/admin/users/${userId}/password`, 'PUT', {
            new_password: newPassword
        });
        
        if (result && result.success) {
            alert(result.message);
            closeModal('changePasswordModal');
            loadUsers();
        } else {
            alert(result.error || 'Failed to update password');
        }
    } catch (error) {
        console.error('Error updating password:', error);
        alert('Failed to update password');
    }
}

// MARK: - Edit Membership

function showEditMembershipModal(userId, userDataStr) {
    const userData = JSON.parse(userDataStr.replace(/&quot;/g, '"'));
    
    document.getElementById('editMembershipUserId').value = userId;
    document.getElementById('editMembershipStatus').value = '';
    
    // Set current dates
    if (userData.subscription_start_date) {
        const startDate = new Date(userData.subscription_start_date);
        document.getElementById('editMembershipStartDate').value = formatDateTimeLocal(startDate);
    }
    
    if (userData.subscription_end_date) {
        const endDate = new Date(userData.subscription_end_date);
        document.getElementById('editMembershipEndDate').value = formatDateTimeLocal(endDate);
    }
    
    closeModal('userDetailsModal');
    showModal('editMembershipModal');
}

async function handleEditMembership(e) {
    e.preventDefault();
    
    const userId = document.getElementById('editMembershipUserId').value;
    const subscription_status = document.getElementById('editMembershipStatus').value;
    const subscription_start_date = document.getElementById('editMembershipStartDate').value;
    const subscription_end_date = document.getElementById('editMembershipEndDate').value;
    
    const updates = {};
    
    if (subscription_status) {
        updates.subscription_status = subscription_status;
    }
    
    if (subscription_start_date) {
        updates.subscription_start_date = new Date(subscription_start_date).toISOString();
    }
    
    if (subscription_end_date) {
        updates.subscription_end_date = new Date(subscription_end_date).toISOString();
    }
    
    if (Object.keys(updates).length === 0) {
        alert('No changes to save');
        return;
    }
    
    try {
        const result = await apiRequest(`/admin/users/${userId}/membership`, 'PUT', updates);
        
        if (result && result.success) {
            alert(result.message);
            closeModal('editMembershipModal');
            loadUsers();
        } else {
            alert(result.error || 'Failed to update membership');
        }
    } catch (error) {
        console.error('Error updating membership:', error);
        alert('Failed to update membership');
    }
}

// MARK: - Promo Codes

async function loadPromoCodes() {
    try {
        const data = await apiRequest('/admin/promo-codes', 'GET');
        
        if (data && data.promo_codes) {
            displayPromoCodes(data.promo_codes);
        }
    } catch (error) {
        console.error('Error loading promo codes:', error);
    }
}

function displayPromoCodes(codes) {
    if (!codes || codes.length === 0) {
        document.getElementById('promoCodesTable').innerHTML = '<p class="loading">No promo codes found</p>';
        return;
    }
    
    const html = `
        <table>
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Duration</th>
                    <th>Uses</th>
                    <th>Active</th>
                    <th>Created</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${codes.map(code => `
                    <tr>
                        <td><strong>${code.code}</strong></td>
                        <td>${code.duration_days} days</td>
                        <td>${code.used_count} / ${code.uses_total === -1 ? '∞' : code.uses_total}</td>
                        <td>${code.active ? '✅' : '❌'}</td>
                        <td>${formatDate(code.created_at)}</td>
                        <td>
                            <button class="btn btn-${code.active ? 'danger' : 'success'} btn-sm" 
                                    onclick="togglePromoCode(${code.id}, ${!code.active})">
                                ${code.active ? 'Deactivate' : 'Activate'}
                            </button>
                        </td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    
    document.getElementById('promoCodesTable').innerHTML = html;
}

async function handleCreatePromo(e) {
    e.preventDefault();
    
    const code = document.getElementById('promoCode').value;
    const duration = parseInt(document.getElementById('promoDuration').value);
    const uses = document.getElementById('promoUses').value;
    const description = document.getElementById('promoDescription').value;
    const expires = document.getElementById('promoExpires').value;
    
    try {
        const result = await apiRequest('/admin/promo-codes', 'POST', {
            code,
            duration_days: duration,
            uses_total: uses ? parseInt(uses) : -1,
            description,
            expires_at: expires || null
        });
        
        if (result && result.success) {
            alert(result.message);
            closeModal('createPromoModal');
            document.getElementById('createPromoForm').reset();
            loadPromoCodes();
        }
    } catch (error) {
        console.error('Error creating promo code:', error);
        alert('Failed to create promo code');
    }
}

async function togglePromoCode(codeId, active) {
    try {
        const result = await apiRequest(`/admin/promo-codes/${codeId}`, 'PUT', { active });
        
        if (result && result.success) {
            loadPromoCodes();
        }
    } catch (error) {
        console.error('Error toggling promo code:', error);
        alert('Failed to toggle promo code');
    }
}

// MARK: - Utilities

function showModal(modalId) {
    document.getElementById(modalId).classList.add('active');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

function showCreatePromoModal() {
    showModal('createPromoModal');
}

function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

function formatDateTimeLocal(date) {
    // Format date for datetime-local input
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day}T${hours}:${minutes}`;
}

function showError(elementId, message) {
    const el = document.getElementById(elementId);
    el.textContent = message;
    el.style.display = 'block';
    setTimeout(() => {
        el.style.display = 'none';
    }, 5000);
}

// MARK: - Trial Management

let currentTrialUserId = null;
let currentTrialUserEmail = null;

function showExtendTrialModal(userId, email) {
    currentTrialUserId = userId;
    currentTrialUserEmail = email;
    
    // Create modal if it doesn't exist
    let modal = document.getElementById('extendTrialModal');
    if (!modal) {
        const modalHTML = `
            <div id="extendTrialModal" class="modal">
                <div class="modal-content">
                    <span class="close" onclick="closeExtendTrialModal()">&times;</span>
                    <h2>Extend/Reduce Trial Period</h2>
                    <p id="trialUserEmail" style="margin-bottom: 20px; color: #666;"></p>
                    
                    <div style="margin-bottom: 20px;">
                        <label style="display: block; margin-bottom: 8px; font-weight: 600;">Days to Add/Remove:</label>
                        <input type="number" id="trialDaysInput" placeholder="Enter days (positive to extend, negative to reduce)" 
                               style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px;">
                        <p style="font-size: 12px; color: #666; margin-top: 8px;">
                            Examples: 7 (add 7 days), -3 (remove 3 days)
                        </p>
                    </div>
                    
                    <div style="display: flex; gap: 10px; justify-content: flex-end;">
                        <button class="btn btn-secondary" onclick="closeExtendTrialModal()">Cancel</button>
                        <button class="btn btn-primary" onclick="extendTrial()">Apply</button>
                    </div>
                    
                    <div id="trialError" class="error-message" style="margin-top: 15px;"></div>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', modalHTML);
        modal = document.getElementById('extendTrialModal');
    }
    
    document.getElementById('trialUserEmail').textContent = `User: ${email}`;
    document.getElementById('trialDaysInput').value = '';
    document.getElementById('trialError').style.display = 'none';
    modal.style.display = 'block';
}

function closeExtendTrialModal() {
    const modal = document.getElementById('extendTrialModal');
    if (modal) {
        modal.style.display = 'none';
    }
    currentTrialUserId = null;
    currentTrialUserEmail = null;
}

async function extendTrial() {
    const days = parseInt(document.getElementById('trialDaysInput').value);
    
    console.log('🔧 Extend trial function called');
    console.log('   Days:', days);
    console.log('   User ID:', currentTrialUserId);
    console.log('   User Email:', currentTrialUserEmail);
    console.log('   Admin Token:', adminToken ? 'Present' : 'Missing');
    
    if (isNaN(days) || days === 0) {
        showError('trialError', 'Please enter a valid number of days');
        return;
    }
    
    if (!currentTrialUserId) {
        showError('trialError', 'User ID not found');
        return;
    }
    
    try {
        console.log('📤 Sending API request to extend trial...');
        const response = await apiRequest('/subscription/admin/extend-trial', 'POST', {
            userId: currentTrialUserId,
            days: days
        });
        
        console.log('📥 API Response received:', response);
        
        if (response) {
            console.log('✅ Trial modification successful:', response);
            alert(`Trial period ${days > 0 ? 'extended' : 'reduced'} by ${Math.abs(days)} days for ${currentTrialUserEmail}\n\nNew subscription end date: ${response.subscription.endDate || 'N/A'}\nStatus: ${response.subscription.status || 'N/A'}`);
            closeExtendTrialModal();
            
            // Force refresh with cache buster
            setTimeout(() => {
                console.log('🔄 Reloading users after trial modification...');
                loadUsers(currentPage, true);  // Force refresh = true
            }, 500);
        } else {
            console.error('❌ No response from extend trial API');
            showError('trialError', 'Failed to update trial period');
        }
    } catch (error) {
        console.error('❌ Extend trial error:', error);
        console.error('   Error details:', error.message);
        showError('trialError', 'Network error. Please try again.');
    }
}

// Force refresh users with aggressive cache busting
function forceRefreshUsers() {
    console.log('🔄 Manual refresh triggered');
    
    // Clear any cached data
    if (window.caches) {
        caches.keys().then(names => {
            names.forEach(name => {
                caches.delete(name);
            });
        });
    }
    
    // Force reload with multiple cache busters
    const timestamp = Date.now();
    const randomId = Math.random().toString(36).substr(2, 9);
    
    console.log('🔄 Force refresh with timestamp:', timestamp, 'random:', randomId);
    
    // Reload the page with cache busters
    window.location.href = window.location.href.split('?')[0] + '?refresh=' + timestamp + '&r=' + randomId;
}

// MARK: - Device Analytics

async function loadDeviceAnalytics() {
    try {
        // Load shared device details instead of basic analytics
        const response = await fetch(`${API_BASE_URL}/admin/devices/shared-details`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        
        if (data.success) {
            displaySharedDeviceDetails(data.data);
        } else {
            throw new Error(data.error || 'Failed to load device analytics');
        }
        
    } catch (error) {
        console.error('Error loading device analytics:', error);
        document.getElementById('deviceAnalytics').innerHTML = 
            `<div class="error">Error loading device analytics: ${error.message}</div>`;
    }
}

function displaySharedDeviceDetails(devices) {
    const container = document.getElementById('deviceAnalytics');
    
    if (!devices || devices.length === 0) {
        container.innerHTML = '<div class="alert alert-success">✅ No shared devices found. All users are using unique devices.</div>';
        return;
    }
    
    let html = '<div style="display: flex; flex-direction: column; gap: 20px;">';
    
    devices.forEach(device => {
        const riskLevel = getRiskLevel(device.user_count, device.total_logins);
        const riskClass = getRiskClass(riskLevel);
        const users = device.users || [];
        
        html += `
            <div class="card" style="border-left: 4px solid ${getRiskColor(riskLevel)}; background: #fafafa;">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                    <div>
                        <h3 style="margin: 0; color: #2c3e50;">
                            📱 ${device.device_name || 'Unknown Device'}
                        </h3>
                        <p style="margin: 5px 0; color: #7f8c8d; font-size: 12px;">
                            Device ID: <code>${device.device_id.substring(0, 16)}...</code>
                        </p>
                    </div>
                    <div style="text-align: right;">
                        <span class="badge ${riskClass}" style="font-size: 14px; padding: 8px 12px;">
                            ${riskLevel} Risk
                        </span>
                        <p style="margin: 5px 0; color: #7f8c8d; font-size: 12px;">
                            ${device.user_count} accounts • ${device.total_logins} total logins
                        </p>
                    </div>
                </div>
                
                <div style="background: white; padding: 15px; border-radius: 8px; margin-top: 10px;">
                    <h4 style="margin: 0 0 10px 0; color: #34495e; font-size: 14px;">
                        👥 Users Sharing This Device:
                    </h4>
                    <div style="display: flex; flex-direction: column; gap: 10px;">
        `;
        
        users.forEach((user, index) => {
            const statusColor = user.is_active ? '#27ae60' : '#e74c3c';
            const providerIcon = user.auth_provider === 'google' ? '🔵' : user.auth_provider === 'apple' ? '🍎' : '📧';
            
            html += `
                <div style="display: flex; justify-content: space-between; align-items: center; padding: 10px; background: #f8f9fa; border-radius: 6px; border-left: 3px solid ${statusColor};">
                    <div style="flex: 1;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span style="font-size: 18px;">${providerIcon}</span>
                            <strong style="color: #2c3e50;">${user.email}</strong>
                            ${user.username && user.username !== user.email ? 
                                `<span style="color: #7f8c8d; font-size: 12px;">(${user.username})</span>` : ''}
                        </div>
                        <div style="margin-top: 4px; font-size: 12px; color: #7f8c8d;">
                            User ID: <code>${user.user_id.substring(0, 8)}...</code>
                        </div>
                    </div>
                    <div style="text-align: right;">
                        <div style="margin-bottom: 4px;">
                            <span class="badge ${getSubscriptionBadgeClass(user.subscription_status)}">
                                ${user.subscription_status}
                            </span>
                            ${user.is_active ? 
                                '<span class="badge badge-success">Active</span>' : 
                                '<span class="badge badge-danger">Inactive</span>'}
                        </div>
                        <div style="font-size: 11px; color: #7f8c8d;">
                            ${user.login_count} logins • Last: ${formatDate(user.last_login)}
                        </div>
                    </div>
                </div>
            `;
        });
        
        html += `
                    </div>
                </div>
                
                <div style="margin-top: 10px; padding: 10px; background: #ecf0f1; border-radius: 6px; font-size: 12px; color: #7f8c8d;">
                    📅 First seen: ${formatDate(device.first_seen)} • Last activity: ${formatDate(device.last_seen)}
                </div>
            </div>
        `;
    });
    
    html += '</div>';
    
    html += `
        <div class="alert alert-info" style="margin-top: 20px;">
            <strong>💡 Understanding Shared Devices:</strong><br>
            • <strong>Low Risk (2-3 accounts):</strong> Normal family sharing<br>
            • <strong>Medium Risk (4-5 accounts):</strong> Large family or potential sharing<br>
            • <strong>High Risk (6+ accounts):</strong> Review for potential abuse
        </div>
    `;
    
    container.innerHTML = html;
}

function getRiskColor(riskLevel) {
    switch (riskLevel) {
        case 'High': return '#e74c3c';
        case 'Medium': return '#f39c12';
        default: return '#27ae60';
    }
}

function getSubscriptionBadgeClass(status) {
    switch (status) {
        case 'active': return 'badge-success';
        case 'trial': return 'badge-info';
        case 'expired': return 'badge-danger';
        default: return 'badge-secondary';
    }
}

async function loadFraudFlags() {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/devices/fraud-flags?unresolved=true`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        
        if (data.success) {
            displayFraudFlags(data.data);
        } else {
            throw new Error(data.error || 'Failed to load fraud flags');
        }
        
    } catch (error) {
        console.error('Error loading fraud flags:', error);
        document.getElementById('fraudFlags').innerHTML = 
            `<div class="error">Error loading fraud flags: ${error.message}</div>`;
    }
}

function displayFraudFlags(flags) {
    const container = document.getElementById('fraudFlags');
    
    if (!flags || flags.length === 0) {
        container.innerHTML = '<div class="alert alert-success">No fraud flags found. All good! 🎉</div>';
        return;
    }
    
    let html = `
        <div class="table-container">
            <table class="table">
                <thead>
                    <tr>
                        <th>User ID</th>
                        <th>Device ID</th>
                        <th>Reason</th>
                        <th>Severity</th>
                        <th>Detected</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    flags.forEach(flag => {
        const severityClass = getSeverityClass(flag.severity);
        
        html += `
            <tr>
                <td><code>${flag.user_id.substring(0, 8)}...</code></td>
                <td><code>${flag.device_id.substring(0, 8)}...</code></td>
                <td><small>${flag.reason}</small></td>
                <td><span class="badge ${severityClass}">${flag.severity.toUpperCase()}</span></td>
                <td>${formatDate(flag.created_at)}</td>
                <td>
                    <button class="btn btn-sm btn-success" onclick="resolveFraudFlag('${flag.id}')">Resolve</button>
                </td>
            </tr>
        `;
    });
    
    html += `
                </tbody>
            </table>
        </div>
    `;
    
    container.innerHTML = html;
}

function getRiskLevel(accountCount, totalLogins) {
    if (accountCount > 5 || totalLogins > 100) return 'High';
    if (accountCount > 3 || totalLogins > 50) return 'Medium';
    return 'Low';
}

function getRiskClass(riskLevel) {
    switch (riskLevel) {
        case 'High': return 'badge-danger';
        case 'Medium': return 'badge-warning';
        default: return 'badge-success';
    }
}

function getSeverityClass(severity) {
    switch (severity) {
        case 'high': return 'badge-danger';
        case 'medium': return 'badge-warning';
        default: return 'badge-info';
    }
}

async function resolveFraudFlag(flagId) {
    if (!confirm('Mark this fraud flag as resolved?')) return;
    
    try {
        // Note: This would need a backend endpoint to resolve flags
        console.log(`Resolving fraud flag: ${flagId}`);
        alert('Fraud flag resolution feature coming soon!');
        
        // Refresh the fraud flags list
        loadFraudFlags();
        
    } catch (error) {
        console.error('Error resolving fraud flag:', error);
        alert('Error resolving fraud flag: ' + error.message);
    }
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('extendTrialModal');
    if (event.target === modal) {
        closeExtendTrialModal();
    }
}

// MARK: - API Usage Functions

async function loadApiUsageData() {
    try {
        console.log('📊 Loading API usage data...');
        
        // Load overall stats
        console.log('📊 Fetching overall stats...');
        const statsResponse = await fetch(`${API_BASE_URL}/usage/stats`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`
            }
        });
        
        if (!statsResponse.ok) {
            const errorText = await statsResponse.text();
            console.error('❌ Stats error:', errorText);
            throw new Error('Failed to load usage statistics: ' + errorText);
        }
        
        const statsData = await statsResponse.json();
        console.log('✅ Stats loaded:', statsData);
        displayUsageStats(statsData.data);
        
        // Load endpoint usage
        console.log('📊 Fetching endpoint usage...');
        const endpointResponse = await fetch(`${API_BASE_URL}/usage/endpoint`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`
            }
        });
        
        if (!endpointResponse.ok) {
            const errorText = await endpointResponse.text();
            console.error('❌ Endpoint error:', errorText);
            throw new Error('Failed to load endpoint usage: ' + errorText);
        }
        
        const endpointData = await endpointResponse.json();
        console.log('✅ Endpoint data loaded:', endpointData);
        displayEndpointUsage(endpointData.data);
        
        // Load user usage summary
        console.log('📊 Fetching user usage summary...');
        const userResponse = await fetch(`${API_BASE_URL}/usage/summary?limit=100&sortBy=total_cost&order=DESC`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`
            }
        });
        
        if (!userResponse.ok) {
            const errorText = await userResponse.text();
            console.error('❌ User usage error:', errorText);
            throw new Error('Failed to load user usage: ' + errorText);
        }
        
        const userData = await userResponse.json();
        console.log('✅ User data loaded:', userData);
        displayUserUsage(userData.data.users);
        console.log('✅ All API usage data loaded successfully');
        
    } catch (error) {
        console.error('❌ Error loading API usage data:', error);
        alert('Error loading usage data: ' + error.message);
    }
}

function displayUsageStats(stats) {
    // Display overall stats
    document.getElementById('totalApiCalls').textContent = formatNumber(stats.overall.total_api_calls || 0);
    document.getElementById('totalTokens').textContent = formatNumber(stats.overall.total_tokens || 0);
    document.getElementById('totalCost').textContent = '$' + formatCurrency(stats.overall.total_cost || 0);
    document.getElementById('activeUsersCount').textContent = formatNumber(stats.overall.total_users || 0);
    
    // Display today's stats
    document.getElementById('todayApiCalls').textContent = `Today: ${formatNumber(stats.daily.daily_api_calls || 0)}`;
    document.getElementById('todayTokens').textContent = `Today: ${formatNumber(stats.daily.daily_tokens || 0)}`;
    document.getElementById('todayCost').textContent = `Today: $${formatCurrency(stats.daily.daily_cost || 0)}`;
    document.getElementById('monthlyUsersCount').textContent = `This Month: ${formatNumber(stats.monthly.monthly_users || 0)}`;
}

function displayEndpointUsage(endpoints) {
    const table = `
        <table>
            <thead>
                <tr>
                    <th>Endpoint</th>
                    <th>Model</th>
                    <th>API Calls</th>
                    <th>Total Tokens</th>
                    <th>Avg Tokens/Call</th>
                    <th>Total Cost</th>
                    <th>Avg Cost/Call</th>
                </tr>
            </thead>
            <tbody>
                ${endpoints.map(ep => `
                    <tr>
                        <td><strong>${ep.endpoint}</strong></td>
                        <td><span class="badge">${ep.model}</span></td>
                        <td>${formatNumber(ep.api_calls)}</td>
                        <td>${formatNumber(ep.total_tokens)}</td>
                        <td>${formatNumber(Math.round(ep.avg_tokens_per_call))}</td>
                        <td><strong>$${formatCurrency(ep.cost_usd)}</strong></td>
                        <td>$${formatCurrency(ep.avg_cost_per_call)}</td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
    
    document.getElementById('endpointUsageTable').innerHTML = table;
}

let currentSortField = 'total_cost';
let currentSortOrder = 'DESC';

function displayUserUsage(users) {
    if (!users || users.length === 0) {
        document.getElementById('userUsageTable').innerHTML = '<p style="text-align: center; color: #95a5a6; padding: 20px;">No usage data available yet.</p>';
        return;
    }
    
    const table = `
        <table>
            <thead>
                <tr>
                    <th style="cursor: pointer;" onclick="sortUserUsage('email')">
                        User ${currentSortField === 'email' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th style="cursor: pointer;" onclick="sortUserUsage('device_id')">
                        Device ${currentSortField === 'device_id' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th colspan="4" style="text-align: center; background: #e8f4f8;">Current Billing Cycle</th>
                    <th colspan="2" style="text-align: center; background: #f0f0f0;">All-Time</th>
                    <th></th>
                </tr>
                <tr>
                    <th></th>
                    <th></th>
                    <th style="cursor: pointer; background: #e8f4f8;" onclick="sortUserUsage('cycle_calls')">
                        Calls ${currentSortField === 'cycle_calls' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th style="cursor: pointer; background: #e8f4f8;" onclick="sortUserUsage('cycle_tokens')">
                        Tokens ${currentSortField === 'cycle_tokens' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th style="cursor: pointer; background: #e8f4f8;" onclick="sortUserUsage('cycle_cost')">
                        Cost ${currentSortField === 'cycle_cost' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th style="cursor: pointer; background: #e8f4f8;" onclick="sortUserUsage('profit')">
                        Profit ${currentSortField === 'profit' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th style="cursor: pointer; background: #f0f0f0;" onclick="sortUserUsage('total_tokens')">
                        Tokens ${currentSortField === 'total_tokens' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th style="cursor: pointer; background: #f0f0f0;" onclick="sortUserUsage('total_cost')">
                        Cost ${currentSortField === 'total_cost' ? (currentSortOrder === 'ASC' ? '▲' : '▼') : ''}
                    </th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                ${users.map(user => {
                    const revenue = (user.subscription_status === 'active' || user.subscription_status === 'promo_active') ? 9.99 : 0;
                    const cycleCost = parseFloat(user.cycle_cost) || 0;
                    const profit = revenue - cycleCost;
                    const profitMargin = revenue > 0 ? (profit / revenue) * 100 : 0;
                    
                    // Color code based on profit margin
                    let profitColor = '#27ae60'; // Green
                    if (profitMargin < 50) profitColor = '#e74c3c'; // Red
                    else if (profitMargin < 90) profitColor = '#f39c12'; // Yellow
                    
                    return `
                    <tr style="cursor: pointer;" onclick="showUserCycleDetails('${user.user_id}')">
                        <td><strong>${user.email || user.username || '-'}</strong></td>
                        <td style="font-size: 11px; max-width: 100px; overflow: hidden; text-overflow: ellipsis;" title="${user.device_id || 'N/A'}">${user.device_id ? user.device_id.substring(0, 8) + '...' : '-'}</td>
                        <td style="background: #f8fbfc;">${formatNumber(user.cycle_calls || 0)}</td>
                        <td style="background: #f8fbfc;">${formatNumber(user.cycle_tokens || 0)}</td>
                        <td style="background: #f8fbfc;"><strong>$${formatCurrency(cycleCost)}</strong></td>
                        <td style="background: #f8fbfc; color: ${profitColor}; font-weight: bold;">$${profit.toFixed(2)} (${profitMargin.toFixed(1)}%)</td>
                        <td style="background: #fafafa;">${formatNumber(user.total_tokens || 0)}</td>
                        <td style="background: #fafafa;">$${formatCurrency(user.total_cost || 0)}</td>
                        <td>
                            <button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); showUserCycleDetails('${user.user_id}')">
                                📊 Details
                            </button>
                        </td>
                    </tr>
                `;
                }).join('')}
            </tbody>
        </table>
    `;
    
    document.getElementById('userUsageTable').innerHTML = table;
}

async function sortUserUsage(field) {
    // Toggle sort order if clicking the same field
    if (currentSortField === field) {
        currentSortOrder = currentSortOrder === 'ASC' ? 'DESC' : 'ASC';
    } else {
        currentSortField = field;
        currentSortOrder = 'DESC'; // Default to descending for new field
    }
    
    console.log(`📊 Sorting by ${field} ${currentSortOrder}`);
    
    // Reload data with new sort
    try {
        const userResponse = await fetch(`${API_BASE_URL}/usage/summary?limit=100&sortBy=${field}&order=${currentSortOrder}`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`
            }
        });
        
        if (!userResponse.ok) {
            throw new Error('Failed to load user usage');
        }
        
        const userData = await userResponse.json();
        displayUserUsage(userData.data.users);
    } catch (error) {
        console.error('Error sorting user usage:', error);
        alert('Error sorting data: ' + error.message);
    }
}

async function refreshUsageData() {
    console.log('🔄 Refreshing usage data...');
    
    // Show loading indicator
    const refreshBtn = event.target;
    const originalText = refreshBtn.innerHTML;
    refreshBtn.innerHTML = '⏳ Refreshing...';
    refreshBtn.disabled = true;
    
    try {
        await loadApiUsageData();
        console.log('✅ Usage data refreshed successfully');
        
        // Show success briefly
        refreshBtn.innerHTML = '✅ Refreshed!';
        setTimeout(() => {
            refreshBtn.innerHTML = originalText;
            refreshBtn.disabled = false;
        }, 1000);
    } catch (error) {
        console.error('❌ Error refreshing usage data:', error);
        refreshBtn.innerHTML = originalText;
        refreshBtn.disabled = false;
        alert('Error refreshing data: ' + error.message);
    }
}

async function exportUsageData(type) {
    try {
        const endpoint = type === 'summary' ? '/usage/export/summary' : '/usage/export';
        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`
            }
        });
        
        if (!response.ok) {
            throw new Error('Failed to export data');
        }
        
        // Get the filename from the response headers
        const contentDisposition = response.headers.get('Content-Disposition');
        let filename = `usage_export_${new Date().toISOString().split('T')[0]}.csv`;
        if (contentDisposition) {
            const matches = /filename="([^"]+)"/.exec(contentDisposition);
            if (matches && matches[1]) {
                filename = matches[1];
            }
        }
        
        // Download the file
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
        
        alert(`✅ ${type === 'summary' ? 'Summary' : 'Detailed'} data exported successfully!`);
    } catch (error) {
        console.error('Error exporting data:', error);
        alert('Error exporting data: ' + error.message);
    }
}

// MARK: - User Cycle Details Modal

async function showUserCycleDetails(userId) {
    showModal('userCycleDetailsModal');
    
    try {
        console.log(`📊 Loading cycle details for user: ${userId}`);
        
        const response = await fetch(`${API_BASE_URL}/usage/user/${userId}/cycle-stats`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`
            }
        });
        
        if (!response.ok) {
            throw new Error('Failed to load cycle details');
        }
        
        const result = await response.json();
        const data = result.data;
        
        // Calculate profit metrics
        const revenue = data.currentCycle.revenue;
        const cost = data.currentCycle.cost;
        const profit = data.currentCycle.profit;
        const profitMargin = data.currentCycle.profit_margin;
        
        // Determine profit color
        let profitColor = '#27ae60'; // Green
        let profitIcon = '✅';
        let profitWarning = '';
        
        if (profitMargin < 50) {
            profitColor = '#e74c3c'; // Red
            profitIcon = '🚨';
            profitWarning = '<div class="alert alert-error" style="margin-top: 10px;">⚠️ <strong>Warning:</strong> This user\'s costs exceed 50% of revenue. Consider implementing usage limits.</div>';
        } else if (profitMargin < 90) {
            profitColor = '#f39c12'; // Yellow
            profitIcon = '⚠️';
            profitWarning = '<div class="alert alert-warning" style="margin-top: 10px; background: #fff3cd; color: #856404; border: 1px solid #ffeeba;">💡 <strong>Notice:</strong> This user has higher than average usage costs.</div>';
        }
        
        // Format dates
        const cycleStart = new Date(data.currentCycle.start_date).toLocaleDateString();
        const cycleEnd = new Date(data.currentCycle.end_date).toLocaleDateString();
        const memberSince = new Date(data.user.member_since).toLocaleDateString();
        
        const html = `
            <div style="padding: 20px;">
                <!-- User Info Header -->
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 12px; margin-bottom: 20px;">
                    <h3 style="margin: 0; color: white;">${data.user.email}</h3>
                    <p style="margin: 5px 0 0 0; opacity: 0.9;">@${data.user.username || 'N/A'} • Member since ${memberSince}</p>
                    <p style="margin: 5px 0 0 0;">
                        <span class="badge ${data.user.subscription_status === 'active' ? 'badge-success' : data.user.subscription_status === 'trial' ? 'badge-info' : 'badge-warning'}" style="background: white; color: #667eea;">
                            ${data.user.subscription_status.toUpperCase()}
                        </span>
                    </p>
                </div>
                
                <!-- Current Billing Cycle -->
                <div class="card" style="margin-bottom: 20px;">
                    <h3 style="margin: 0 0 15px 0;">💳 Current Billing Cycle</h3>
                    <p style="color: #7f8c8d; margin-bottom: 15px;">${cycleStart} → ${cycleEnd} (${data.currentCycle.days_remaining} days remaining)</p>
                    
                    ${profitWarning}
                    
                    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin-top: 15px;">
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                            <div style="font-size: 12px; color: #95a5a6; text-transform: uppercase; letter-spacing: 0.5px;">Revenue This Cycle</div>
                            <div style="font-size: 28px; font-weight: bold; color: #27ae60;">$${revenue.toFixed(2)}</div>
                        </div>
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                            <div style="font-size: 12px; color: #95a5a6; text-transform: uppercase; letter-spacing: 0.5px;">Cost This Cycle</div>
                            <div style="font-size: 28px; font-weight: bold; color: #e74c3c;">$${cost.toFixed(4)}</div>
                        </div>
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                            <div style="font-size: 12px; color: #95a5a6; text-transform: uppercase; letter-spacing: 0.5px;">Profit This Cycle</div>
                            <div style="font-size: 28px; font-weight: bold; color: ${profitColor};">${profitIcon} $${profit.toFixed(2)}</div>
                        </div>
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                            <div style="font-size: 12px; color: #95a5a6; text-transform: uppercase; letter-spacing: 0.5px;">Profit Margin</div>
                            <div style="font-size: 28px; font-weight: bold; color: ${profitColor};">${profitMargin.toFixed(1)}%</div>
                        </div>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-top: 15px;">
                        <div>
                            <div style="font-size: 12px; color: #95a5a6;">API Calls</div>
                            <div style="font-size: 20px; font-weight: bold;">${formatNumber(data.currentCycle.calls)}</div>
                        </div>
                        <div>
                            <div style="font-size: 12px; color: #95a5a6;">Total Tokens</div>
                            <div style="font-size: 20px; font-weight: bold;">${formatNumber(data.currentCycle.tokens)}</div>
                        </div>
                        <div>
                            <div style="font-size: 12px; color: #95a5a6;">Last Activity</div>
                            <div style="font-size: 14px;">${data.currentCycle.last_call ? new Date(data.currentCycle.last_call).toLocaleString() : 'No activity'}</div>
                        </div>
                    </div>
                </div>
                
                <!-- Endpoint Breakdown -->
                <div class="card" style="margin-bottom: 20px;">
                    <h3 style="margin: 0 0 15px 0;">🔌 Usage by Endpoint (This Cycle)</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Endpoint</th>
                                <th>Model</th>
                                <th>Calls</th>
                                <th>Tokens</th>
                                <th>Cost</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${data.endpointBreakdown.map(ep => `
                                <tr>
                                    <td><strong>${ep.endpoint}</strong></td>
                                    <td><span class="badge">${ep.model}</span></td>
                                    <td>${formatNumber(ep.calls)}</td>
                                    <td>${formatNumber(ep.tokens)}</td>
                                    <td>$${formatCurrency(ep.cost)}</td>
                                </tr>
                            `).join('') || '<tr><td colspan="5" style="text-align: center; color: #95a5a6;">No usage this cycle</td></tr>'}
                        </tbody>
                    </table>
                </div>
                
                <!-- Device Breakdown -->
                <div class="card" style="margin-bottom: 20px;">
                    <h3 style="margin: 0 0 15px 0;">📱 Devices Used (This Cycle)</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Device ID</th>
                                <th>Calls</th>
                                <th>Tokens</th>
                                <th>Cost</th>
                                <th>Last Used</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${data.deviceBreakdown.map(device => `
                                <tr>
                                    <td style="font-family: monospace;">${device.device_id ? device.device_id.substring(0, 16) + '...' : 'Unknown'}</td>
                                    <td>${formatNumber(device.calls)}</td>
                                    <td>${formatNumber(device.tokens)}</td>
                                    <td>$${formatCurrency(device.cost)}</td>
                                    <td>${new Date(device.last_used).toLocaleString()}</td>
                                </tr>
                            `).join('') || '<tr><td colspan="5" style="text-align: center; color: #95a5a6;">No device data available</td></tr>'}
                        </tbody>
                    </table>
                </div>
                
                <!-- Historical Cycles -->
                <div class="card" style="margin-bottom: 20px;">
                    <h3 style="margin: 0 0 15px 0;">📅 Historical Usage (Past Periods)</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Period</th>
                                <th>Calls</th>
                                <th>Tokens</th>
                                <th>Cost</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${data.historicalCycles.map(cycle => `
                                <tr>
                                    <td>${new Date(cycle.period_start).toLocaleDateString()}</td>
                                    <td>${formatNumber(cycle.calls)}</td>
                                    <td>${formatNumber(cycle.tokens)}</td>
                                    <td>$${formatCurrency(cycle.cost)}</td>
                                </tr>
                            `).join('') || '<tr><td colspan="4" style="text-align: center; color: #95a5a6;">No historical data</td></tr>'}
                        </tbody>
                    </table>
                </div>
                
                <!-- All-Time Statistics -->
                <div class="card">
                    <h3 style="margin: 0 0 15px 0;">📊 All-Time Statistics</h3>
                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px;">
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                            <div style="font-size: 12px; color: #95a5a6;">Total API Calls</div>
                            <div style="font-size: 24px; font-weight: bold;">${formatNumber(data.allTime.total_calls)}</div>
                        </div>
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                            <div style="font-size: 12px; color: #95a5a6;">Total Tokens</div>
                            <div style="font-size: 24px; font-weight: bold;">${formatNumber(data.allTime.total_tokens)}</div>
                        </div>
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                            <div style="font-size: 12px; color: #95a5a6;">Total Cost</div>
                            <div style="font-size: 24px; font-weight: bold; color: #e74c3c;">$${formatCurrency(data.allTime.total_cost)}</div>
                        </div>
                    </div>
                    <div style="margin-top: 15px; padding: 10px; background: #ecf0f1; border-radius: 6px;">
                        <small style="color: #7f8c8d;">
                            First activity: ${data.allTime.first_call ? new Date(data.allTime.first_call).toLocaleString() : 'N/A'} •
                            Last activity: ${data.allTime.last_call ? new Date(data.allTime.last_call).toLocaleString() : 'N/A'}
                        </small>
                    </div>
                </div>
                
                <!-- Actions -->
                <div style="margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;">
                    <button class="btn btn-success" onclick="downloadUserCycleCSV('${userId}')">
                        📥 Download CSV
                    </button>
                    <button class="btn btn-secondary" onclick="closeModal('userCycleDetailsModal')">
                        Close
                    </button>
                </div>
            </div>
        `;
        
        document.getElementById('userCycleDetailsContent').innerHTML = html;
        
    } catch (error) {
        console.error('Error loading cycle details:', error);
        document.getElementById('userCycleDetailsContent').innerHTML = `
            <div class="alert alert-error">
                ❌ Error loading cycle details: ${error.message}
            </div>
        `;
    }
}

async function downloadUserCycleCSV(userId) {
    try {
        const response = await fetch(`${API_BASE_URL}/usage/user/${userId}/cycle-stats`, {
            headers: {
                'Authorization': `Bearer ${adminToken}`
            }
        });
        
        if (!response.ok) {
            throw new Error('Failed to load data for export');
        }
        
        const result = await response.json();
        const data = result.data;
        
        // Create CSV content
        const csvContent = `User Billing Cycle Report
Generated: ${new Date().toLocaleString()}

User Information
Email,${data.user.email}
Username,${data.user.username}
Status,${data.user.subscription_status}
Member Since,${new Date(data.user.member_since).toLocaleDateString()}

Current Billing Cycle (${new Date(data.currentCycle.start_date).toLocaleDateString()} - ${new Date(data.currentCycle.end_date).toLocaleDateString()})
Metric,Value
Days Remaining,${data.currentCycle.days_remaining}
Revenue,$${data.currentCycle.revenue.toFixed(2)}
API Calls,${data.currentCycle.calls}
Total Tokens,${data.currentCycle.tokens}
Cost,$${data.currentCycle.cost.toFixed(4)}
Profit,$${data.currentCycle.profit.toFixed(2)}
Profit Margin,${data.currentCycle.profit_margin.toFixed(1)}%

Endpoint Breakdown (Current Cycle)
Endpoint,Model,Calls,Tokens,Cost
${data.endpointBreakdown.map(ep => `${ep.endpoint},${ep.model},${ep.calls},${ep.tokens},$${parseFloat(ep.cost).toFixed(4)}`).join('\n')}

Device Breakdown (Current Cycle)
Device ID,Calls,Tokens,Cost,Last Used
${data.deviceBreakdown.map(d => `${d.device_id},${d.calls},${d.tokens},$${parseFloat(d.cost).toFixed(4)},${new Date(d.last_used).toLocaleString()}`).join('\n')}

All-Time Statistics
Total Calls,${data.allTime.total_calls}
Total Tokens,${data.allTime.total_tokens}
Total Cost,$${parseFloat(data.allTime.total_cost).toFixed(4)}
`;
        
        // Download
        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `user_${data.user.email}_cycle_${new Date().toISOString().split('T')[0]}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
        
        alert('✅ CSV downloaded successfully!');
    } catch (error) {
        console.error('Error downloading CSV:', error);
        alert('Error downloading CSV: ' + error.message);
    }
}

// Helper functions
function formatNumber(num) {
    if (!num) return '0';
    return parseInt(num).toLocaleString();
}

function formatCurrency(amount) {
    if (!amount) return '0.00';
    return parseFloat(amount).toFixed(4);
}

// MARK: - Entitlements Ledger

let currentLedgerFilter = 'all';
let currentLedgerPage = 1;

async function loadLedgerData() {
    await loadLedgerStats();
    await loadLedgerRecords();
    await loadUserEntitlements();
}

async function loadLedgerStats() {
    try {
        console.log('Loading ledger stats...');
        const data = await apiRequest('/admin/ledger/stats', 'GET');
        
        if (data && data.success) {
            const ledger = data.ledger;
            document.getElementById('ledgerTotalRecords').textContent = formatNumber(ledger.total_records);
            document.getElementById('ledgerTrialCount').textContent = formatNumber(ledger.trial_count);
            document.getElementById('ledgerActiveCount').textContent = formatNumber(ledger.active_count);
            document.getElementById('ledgerExpiredCount').textContent = formatNumber(ledger.expired_count);
            console.log('Ledger stats loaded successfully');
        } else {
            console.error('Ledger stats API returned success=false:', data);
        }
    } catch (error) {
        console.error('Error loading ledger stats:', error);
        // Show error in UI
        document.getElementById('ledgerTotalRecords').textContent = 'Error';
        document.getElementById('ledgerTrialCount').textContent = 'Error';
        document.getElementById('ledgerActiveCount').textContent = 'Error';
        document.getElementById('ledgerExpiredCount').textContent = 'Error';
    }
}

async function loadLedgerRecords(page = 1) {
    currentLedgerPage = page;
    
    try {
        const queryParams = new URLSearchParams({
            page,
            limit: 50,
            filter: currentLedgerFilter
        });
        
        const data = await apiRequest(`/admin/ledger/records?${queryParams}`, 'GET');
        
        if (data && data.success) {
            displayLedgerRecords(data.records);
            displayLedgerPagination(data.pagination);
        }
    } catch (error) {
        console.error('Error loading ledger records:', error);
        document.getElementById('ledgerRecordsTable').innerHTML = 
            '<p style="color: #e74c3c;">Error loading ledger records</p>';
    }
}

function displayLedgerRecords(records) {
    if (!records || records.length === 0) {
        document.getElementById('ledgerRecordsTable').innerHTML = 
            '<p style="color: #95a5a6;">No ledger records found</p>';
        return;
    }
    
    let html = `
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="border-bottom: 2px solid #ecf0f1; text-align: left;">
                    <th style="padding: 12px;">Hash (Preview)</th>
                    <th style="padding: 12px;">Product ID</th>
                    <th style="padding: 12px;">Group ID</th>
                    <th style="padding: 12px;">Ever Trial</th>
                    <th style="padding: 12px;">Status</th>
                    <th style="padding: 12px;">First Seen</th>
                    <th style="padding: 12px;">Last Seen</th>
                    <th style="padding: 12px;">Days Ago</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    records.forEach(record => {
        const statusColor = record.status === 'active' ? '#27ae60' : 
                          record.status === 'expired' ? '#e74c3c' : '#95a5a6';
        const trialBadge = record.ever_trial ? 
            '<span style="background: #3498db; color: white; padding: 3px 8px; border-radius: 4px; font-size: 12px;">TRIAL</span>' : 
            '<span style="color: #95a5a6;">-</span>';
        
        html += `
            <tr style="border-bottom: 1px solid #ecf0f1;">
                <td style="padding: 12px; font-family: monospace; font-size: 12px;">${record.hash_preview}</td>
                <td style="padding: 12px; font-size: 13px;">${record.product_id}</td>
                <td style="padding: 12px; font-size: 13px;">${record.subscription_group_id}</td>
                <td style="padding: 12px;">${trialBadge}</td>
                <td style="padding: 12px;">
                    <span style="color: ${statusColor}; font-weight: 600;">
                        ${record.status.toUpperCase()}
                    </span>
                </td>
                <td style="padding: 12px; font-size: 13px;">${new Date(record.first_seen_at).toLocaleDateString()}</td>
                <td style="padding: 12px; font-size: 13px;">${new Date(record.last_seen_at).toLocaleDateString()}</td>
                <td style="padding: 12px; color: #7f8c8d;">${Math.floor(record.days_since_last_seen)}d</td>
            </tr>
        `;
    });
    
    html += '</tbody></table>';
    document.getElementById('ledgerRecordsTable').innerHTML = html;
}

function displayLedgerPagination(pagination) {
    if (!pagination || pagination.totalPages <= 1) return;
    
    let html = '<div style="margin-top: 20px; text-align: center;">';
    
    for (let i = 1; i <= Math.min(pagination.totalPages, 10); i++) {
        const active = i === pagination.page ? 'style="background: #3498db; color: white;"' : '';
        html += `<button class="btn btn-secondary" ${active} onclick="loadLedgerRecords(${i})" style="margin: 0 5px;">${i}</button>`;
    }
    
    html += '</div>';
    document.getElementById('ledgerRecordsTable').innerHTML += html;
}

async function loadUserEntitlements(page = 1) {
    try {
        const queryParams = new URLSearchParams({ page, limit: 50 });
        const data = await apiRequest(`/admin/ledger/user-entitlements?${queryParams}`, 'GET');
        
        if (data && data.success) {
            displayUserEntitlements(data.records);
        }
    } catch (error) {
        console.error('Error loading user entitlements:', error);
        document.getElementById('userEntitlementsTable').innerHTML = 
            '<p style="color: #e74c3c;">Error loading user entitlements</p>';
    }
}

function displayUserEntitlements(records) {
    if (!records || records.length === 0) {
        document.getElementById('userEntitlementsTable').innerHTML = 
            '<p style="color: #95a5a6;">No user entitlements found</p>';
        return;
    }
    
    let html = `
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="border-bottom: 2px solid #ecf0f1; text-align: left;">
                    <th style="padding: 12px;">Email</th>
                    <th style="padding: 12px;">Username</th>
                    <th style="padding: 12px;">Hash (Preview)</th>
                    <th style="padding: 12px;">Product</th>
                    <th style="padding: 12px;">Is Trial</th>
                    <th style="padding: 12px;">Status</th>
                    <th style="padding: 12px;">Expires</th>
                    <th style="padding: 12px;">Days Left</th>
                </tr>
            </thead>
            <tbody>
    `;
    
    records.forEach(record => {
        const statusColor = record.status === 'active' ? '#27ae60' : 
                          record.status === 'expired' ? '#e74c3c' : '#95a5a6';
        const trialBadge = record.is_trial ? 
            '<span style="background: #3498db; color: white; padding: 3px 8px; border-radius: 4px; font-size: 12px;">YES</span>' : 
            '<span style="color: #95a5a6;">NO</span>';
        
        html += `
            <tr style="border-bottom: 1px solid #ecf0f1;">
                <td style="padding: 12px;">${record.email || 'N/A'}</td>
                <td style="padding: 12px;">${record.username || 'N/A'}</td>
                <td style="padding: 12px; font-family: monospace; font-size: 11px;">${record.hash_preview}</td>
                <td style="padding: 12px; font-size: 12px;">${record.product_id}</td>
                <td style="padding: 12px;">${trialBadge}</td>
                <td style="padding: 12px;">
                    <span style="color: ${statusColor}; font-weight: 600;">
                        ${record.status.toUpperCase()}
                    </span>
                </td>
                <td style="padding: 12px; font-size: 13px;">
                    ${record.expires_at ? new Date(record.expires_at).toLocaleDateString() : 'N/A'}
                </td>
                <td style="padding: 12px; color: #7f8c8d;">${record.days_remaining || 0} days</td>
            </tr>
        `;
    });
    
    html += '</tbody></table>';
    document.getElementById('userEntitlementsTable').innerHTML = html;
}

function filterLedger(filter) {
    currentLedgerFilter = filter;
    
    // Update button styles
    ['filterAll', 'filterTrial', 'filterActive', 'filterExpired'].forEach(id => {
        const btn = document.getElementById(id);
        if (btn) {
            btn.style.background = '';
            btn.style.color = '';
        }
    });
    
    const activeBtn = document.getElementById('filter' + filter.charAt(0).toUpperCase() + filter.slice(1));
    if (activeBtn) {
        activeBtn.style.background = '#3498db';
        activeBtn.style.color = 'white';
    }
    
    loadLedgerRecords(1);
}

function refreshLedgerData() {
    loadLedgerStats();
    loadLedgerRecords(currentLedgerPage);
}

// MARK: - Admin Audit Log

let currentAuditFilter = 'all';
let currentAuditPage = 1;

async function loadAuditLogData() {
    await loadAuditLogRecords();
}

async function loadAuditLogRecords(page = 1) {
    currentAuditPage = page;
    
    try {
        console.log('Loading audit log records...', { page, filter: currentAuditFilter });
        const queryParams = new URLSearchParams({
            page,
            limit: 20,
            action: currentAuditFilter === 'all' ? '' : currentAuditFilter
        });
        
        const data = await apiRequest(`/admin/audit-log?${queryParams}`, 'GET');
        
        if (data.success) {
            console.log('Audit log loaded successfully:', data.records.length, 'records');
            displayAuditLogRecords(data.records);
            displayAuditLogPagination(data.pagination);
        } else {
            console.error('Audit log API returned success=false:', data);
        }
    } catch (error) {
        console.error('Error loading audit log:', error);
        document.getElementById('auditLogTable').innerHTML = 
            '<p style="color: #e74c3c;">Error loading audit log</p>';
    }
}

function displayAuditLogRecords(records) {
    if (!records || records.length === 0) {
        document.getElementById('auditLogTable').innerHTML = 
            '<p style="color: #95a5a6;">No audit log entries found</p>';
        return;
    }
    
    let html = `
        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Admin</th>
                        <th>Action</th>
                        <th>Target</th>
                        <th>Details</th>
                        <th>IP Address</th>
                        <th>Timestamp</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    records.forEach(record => {
        const details = record.details ? JSON.parse(record.details) : {};
        const actionIcon = getActionIcon(record.action);
        const timestamp = new Date(record.created_at).toLocaleString();
        
        html += `
            <tr>
                <td>
                    <div>
                        <strong>${record.admin_username}</strong><br>
                        <small style="color: #7f8c8d;">${record.admin_email}</small>
                    </div>
                </td>
                <td>
                    <span class="action-badge ${getActionClass(record.action)}">
                        ${actionIcon} ${record.action.replace('_', ' ')}
                    </span>
                </td>
                <td>
                    ${record.target_email ? `
                        <div>
                            <strong>${record.target_username || 'N/A'}</strong><br>
                            <small style="color: #7f8c8d;">${record.target_email}</small>
                        </div>
                    ` : '<span style="color: #95a5a6;">System</span>'}
                </td>
                <td>
                    <div style="max-width: 200px; word-wrap: break-word;">
                        ${Object.keys(details).map(key => 
                            `<small><strong>${key}:</strong> ${details[key]}</small>`
                        ).join('<br>')}
                    </div>
                </td>
                <td>
                    <code>${record.ip_address || 'N/A'}</code>
                </td>
                <td>
                    <small>${timestamp}</small>
                </td>
            </tr>
        `;
    });
    
    html += `
                </tbody>
            </table>
        </div>
    `;
    
    document.getElementById('auditLogTable').innerHTML = html;
}

function displayAuditLogPagination(pagination) {
    if (pagination.pages <= 1) return;
    
    let html = '<div style="margin-top: 20px; text-align: center;">';
    
    for (let i = 1; i <= Math.min(pagination.pages, 10); i++) {
        const active = i === pagination.page ? 'style="background: #3498db; color: white;"' : '';
        html += `<button class="btn btn-secondary" ${active} onclick="loadAuditLogRecords(${i})" style="margin: 0 5px;">${i}</button>`;
    }
    
    html += '</div>';
    document.getElementById('auditLogTable').innerHTML += html;
}

function getActionIcon(action) {
    const icons = {
        'user_delete': '🗑️',
        'user_ban': '🚫',
        'user_extend': '⏰',
        'user_create': '➕',
        'user_modify': '✏️',
        'system': '⚙️'
    };
    return icons[action] || '📝';
}

function getActionClass(action) {
    const classes = {
        'user_delete': 'action-delete',
        'user_ban': 'action-ban',
        'user_extend': 'action-extend',
        'user_create': 'action-create',
        'user_modify': 'action-modify'
    };
    return classes[action] || 'action-default';
}

function filterAuditLog(filter) {
    currentAuditFilter = filter;
    
    // Update button states
    document.querySelectorAll('[id^="filterAudit"]').forEach(btn => {
        btn.style.background = '';
        btn.style.color = '';
    });
    
    const activeBtn = document.getElementById(`filterAudit${filter === 'all' ? 'All' : filter.charAt(0).toUpperCase() + filter.slice(1)}`);
    if (activeBtn) {
        activeBtn.style.background = '#3498db';
        activeBtn.style.color = 'white';
    }
    
    loadAuditLogRecords(1);
}

function refreshAuditLog() {
    console.log('Refreshing audit log...');
    loadAuditLogRecords(currentAuditPage);
}

function refreshUserEntitlements() {
    loadUserEntitlements();
}


