# 📥 Download Production Build from GitHub

## Quick Guide: Get Your Ready-to-Deploy App

This guide shows you how to download a **production-ready build** of your wedding app directly from GitHub Actions - no need to install dependencies or build locally!

---

## 🎯 What You Get

When you download the build from GitHub Actions, you get:

✅ **All PHP dependencies installed** (via Composer)  
✅ **Frontend assets compiled** (CSS, JS optimized)  
✅ **Production-ready code** (no dev dependencies)  
✅ **Ready to upload** to your server  
✅ **Installation instructions** included  

---

## 📋 Step-by-Step: Download Your Build

### Step 1: Trigger a Build

**Option A: Automatic Build (Recommended)**
- Just push any changes to the `main` branch
- GitHub Actions will automatically build

```bash
git add .
git commit -m "Trigger build"
git push origin main
```

**Option B: Manual Build**
1. Go to: https://github.com/Jayrajsinh45/wedding_app/actions
2. Click on **"Quick Build & Download"** workflow
3. Click **"Run workflow"** button (top right)
4. Select branch: `main`
5. Click green **"Run workflow"** button

### Step 2: Wait for Build to Complete

1. Go to: https://github.com/Jayrajsinh45/wedding_app/actions
2. You'll see your workflow running (yellow dot 🟡)
3. Wait for it to complete (green checkmark ✅)
4. Usually takes 2-5 minutes

### Step 3: Download the Build

1. Click on the completed workflow run
2. Scroll down to the **"Artifacts"** section
3. Click on **`wedding-app-production-XXX.zip`** to download
4. Save the ZIP file to your computer

**Direct Link**: https://github.com/Jayrajsinh45/wedding_app/actions

---

## 📦 What's Inside the ZIP File

```
wedding-app-production.zip
├── app/                    # Laravel application code
├── bootstrap/              # Bootstrap files
├── config/                 # Configuration files
├── database/               # Migrations & seeders
├── public/                 # Web root (compiled assets here!)
│   ├── build/             # ✅ Compiled CSS & JS
│   └── index.php          # Entry point
├── resources/              # Views and source files
├── routes/                 # Application routes
├── storage/                # Storage directories
├── vendor/                 # ✅ PHP dependencies (pre-installed!)
├── .env.production.example # Environment template
├── BUILD_INFO.txt         # Build information
├── INSTALL.txt            # Installation guide
├── DEPLOYMENT.md          # Detailed deployment guide
└── README.md              # Application documentation
```

---

## 🚀 Deploy to Your Server

### Quick Deployment Steps

1. **Upload to Server**
   ```bash
   # On your local machine
   scp wedding-app-production.zip user@your-server:/home/user/
   
   # Or use FTP/SFTP client like FileZilla
   ```

2. **Extract on Server**
   ```bash
   # SSH into your server
   ssh user@your-server
   
   # Extract the ZIP
   unzip wedding-app-production.zip
   mv the-wedding-invitation /var/www/wedding-app
   cd /var/www/wedding-app
   ```

3. **Configure Environment**
   ```bash
   # Create .env file
   cp .env.production.example .env
   nano .env
   ```
   
   Update these values:
   ```env
   APP_NAME="My Wedding"
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=http://your-domain.com
   
   DB_DATABASE=wedding_invitation
   DB_USERNAME=your_db_user
   DB_PASSWORD=your_db_password
   ```

4. **Generate Application Key**
   ```bash
   php artisan key:generate
   ```

5. **Set Permissions**
   ```bash
   sudo chown -R www-data:www-data storage bootstrap/cache
   sudo chmod -R 775 storage bootstrap/cache
   ```

6. **Run Migrations**
   ```bash
   php artisan migrate:fresh --seed
   php artisan storage:link
   ```

7. **Configure Web Server**
   
   Point your Nginx/Apache to: `/var/www/wedding-app/public`
   
   See `DEPLOYMENT.md` for detailed Nginx configuration.

8. **Access Your Site**
   - Website: `http://your-domain.com`
   - Admin: `http://your-domain.com/adminpanel`

---

## 🔄 Update Your Deployment

When you make changes and want to update:

1. **Push changes to GitHub**
   ```bash
   git add .
   git commit -m "Update wedding details"
   git push origin main
   ```

2. **Download new build** from GitHub Actions (see steps above)

3. **Update on server**
   ```bash
   # Backup database first!
   php artisan db:backup  # or use mysqldump
   
   # Extract new build
   unzip wedding-app-production-NEW.zip
   
   # Copy .env file (preserve your settings)
   cp /var/www/wedding-app/.env the-wedding-invitation/.env
   
   # Replace old files
   rm -rf /var/www/wedding-app
   mv the-wedding-invitation /var/www/wedding-app
   
   # Run migrations (if any)
   cd /var/www/wedding-app
   php artisan migrate --force
   
   # Clear cache
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   
   # Restart services
   sudo systemctl restart php8.3-fpm
   sudo systemctl restart nginx
   ```

---

## 🎨 Available Workflows

Your repository has 3 build workflows:

### 1. **Quick Build & Download** (Recommended)
- **File**: `.github/workflows/build-download.yml`
- **Purpose**: Create downloadable production build
- **Trigger**: Push to main or manual
- **Artifact**: `wedding-app-production-XXX.zip`
- **Best for**: Getting ready-to-deploy builds

### 2. **Build Application Artifact**
- **File**: `.github/workflows/build-artifact.yml`
- **Purpose**: Build and package for deployment
- **Trigger**: Push, PR, or manual
- **Artifact**: `wedding-app-production-build`
- **Best for**: Testing and releases

### 3. **Deploy Laravel Application**
- **File**: `.github/workflows/deploy.yml`
- **Purpose**: Auto-deploy to server via SSH
- **Trigger**: Push to main
- **Best for**: Continuous deployment (requires server setup)

---

## 📊 Check Build Status

### View All Builds
https://github.com/Jayrajsinh45/wedding_app/actions

### Build Badges
Add to your README:

```markdown
![Build Status](https://github.com/Jayrajsinh45/wedding_app/actions/workflows/build-download.yml/badge.svg)
```

---

## 💡 Pro Tips

### 1. **Create Releases**
Tag your code to create releases with attached builds:

```bash
git tag -a v1.0.0 -m "First release"
git push origin v1.0.0
```

The build will be attached to the release automatically!

### 2. **Download via CLI**
Use GitHub CLI to download artifacts:

```bash
# Install GitHub CLI
# https://cli.github.com/

# Download latest artifact
gh run download --repo Jayrajsinh45/wedding_app
```

### 3. **Automate Downloads**
Create a script to auto-download latest build:

```bash
#!/bin/bash
# download-latest.sh

REPO="Jayrajsinh45/wedding_app"
WORKFLOW="build-download.yml"

# Get latest successful run
RUN_ID=$(gh run list --repo $REPO --workflow $WORKFLOW --status success --limit 1 --json databaseId --jq '.[0].databaseId')

# Download artifacts
gh run download $RUN_ID --repo $REPO

echo "✅ Latest build downloaded!"
```

---

## 🆘 Troubleshooting

### Build Failed
1. Check the workflow logs in Actions tab
2. Look for red ❌ marks
3. Common issues:
   - Composer dependency conflicts
   - NPM build errors
   - Missing files

### Can't Find Artifacts
- Artifacts are only available for **90 days**
- Must be logged into GitHub
- Check if build completed successfully (green ✅)

### ZIP File Corrupted
- Re-download from GitHub
- Check your internet connection
- Try different browser

### Permission Denied on Server
```bash
sudo chown -R www-data:www-data /var/www/wedding-app
sudo chmod -R 775 storage bootstrap/cache
```

---

## 📞 Need Help?

1. **Check Build Logs**: https://github.com/Jayrajsinh45/wedding_app/actions
2. **Read Guides**:
   - `INSTALL.txt` - In the ZIP file
   - `DEPLOYMENT.md` - Detailed deployment
   - `README.md` - Application info
3. **Check Issues**: https://github.com/Jayrajsinh45/wedding_app/issues

---

## ✅ Checklist: First Deployment

- [ ] Build triggered and completed successfully
- [ ] ZIP file downloaded from GitHub Actions
- [ ] Uploaded to server
- [ ] Extracted to web directory
- [ ] `.env` file configured
- [ ] Application key generated
- [ ] Database created and credentials set
- [ ] Migrations run successfully
- [ ] Storage linked
- [ ] Permissions set correctly
- [ ] Web server configured
- [ ] Site accessible in browser
- [ ] Admin panel working

---

## 🎊 You're Ready!

Your wedding invitation app is now built and ready to deploy. Just download from GitHub Actions and upload to your server!

**Happy Wedding Planning! 💒💍**

---

*Repository: https://github.com/Jayrajsinh45/wedding_app*  
*Actions: https://github.com/Jayrajsinh45/wedding_app/actions*
