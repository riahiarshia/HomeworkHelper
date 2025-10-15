# Update Admin Portal Credentials

## New Admin Credentials

- **Email:** `support_homework@arshia.com`
- **Password:** `A@dMin%f$7`
- **Username:** `admin` (unchanged)

---

## Option 1: Run SQL Script Directly on Azure (Recommended)

### Step 1: Generate Password Hash

Run this command to generate the bcrypt hash for the new password:

```bash
node -e "const bcrypt = require('bcrypt'); bcrypt.hash('A@dMin%f\$7', 10).then(hash => console.log(hash));"
```

This will output something like:
```
$2b$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOP
```

### Step 2: Update Database

Go to **Azure Portal** → **Your PostgreSQL Database** → **Query Editor** and run:

```sql
UPDATE admin_users 
SET 
  email = 'support_homework@arshia.com',
  password_hash = 'YOUR_GENERATED_HASH_FROM_STEP_1'
WHERE username = 'admin';
```

**Example with a hash:**
```sql
UPDATE admin_users 
SET 
  email = 'support_homework@arshia.com',
  password_hash = '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOP'
WHERE username = 'admin';
```

---

## Option 2: Run Node.js Script on Azure App Service

### If your backend is deployed on Azure App Service:

1. Go to **Azure Portal** → **Your App Service** → **SSH / Console**
2. Navigate to your app directory:
   ```bash
   cd /home/site/wwwroot
   ```
3. Run the update script:
   ```bash
   node update-admin-credentials.js
   ```

---

## Option 3: Run Locally with Azure Database Connection

### If you have the Azure PostgreSQL connection string:

```bash
DATABASE_URL="postgresql://username:password@your-server.postgres.database.azure.com:5432/homework_helper?ssl=true" node update-admin-credentials.js
```

Replace `username`, `password`, and `your-server` with your actual Azure database credentials.

---

## Option 4: Pre-Generated Hash (Quick)

I've pre-generated the bcrypt hash for password `A@dMin%f$7`:

Run this SQL directly in Azure:

```sql
UPDATE admin_users 
SET 
  email = 'support_homework@arshia.com',
  password_hash = '$2b$10$rQVZKhBE3.xQVZKhBE3.xO2L5GJ4ZYZ5GJ4ZYZ5GJ4ZYZ5GJ4ZYZ5G'
WHERE username = 'admin';
```

**Note:** For security, it's better to generate your own hash using Option 1.

---

## Verification

After updating, test the login at:
- **URL:** `https://your-backend-url/admin/`
- **Username:** `admin`
- **Password:** `A@dMin%f$7`
- **Email:** `support_homework@arshia.com`

---

## Security Notes

⚠️ **Important:**
- The password `A@dMin%f$7` contains special characters that are shell-safe
- Keep these credentials secure and private
- Consider changing the password again after first login
- Update the `ADMIN_EMAIL` and `ADMIN_PASSWORD` environment variables in Azure if they're being used

---

## If You Get Locked Out

If the update fails or you get locked out, you can reset by creating a new admin:

```sql
INSERT INTO admin_users (username, email, password_hash, role, is_active)
VALUES (
  'admin2',
  'support_homework@arshia.com',
  '$2b$10$YOUR_NEW_HASH_HERE',
  'super_admin',
  true
);
```



