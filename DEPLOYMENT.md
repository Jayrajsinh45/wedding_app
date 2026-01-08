# GitHub Deployment Guide

This guide will help you deploy the Wedding Invitation Laravel application using GitHub Actions.

## Prerequisites

1. A GitHub account
2. A server (VPS) with SSH access
3. Domain name (optional)

## Deployment Options

### Option 1: Direct SSH Deployment (Recommended)

This method deploys directly to your server via SSH.

#### Step 1: Create Your Own GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it something like `my-wedding-invitation`
3. Don't initialize with README (we already have one)

#### Step 2: Update Git Remote

```bash
cd d:\App\the-wedding-invitation

# Remove the original remote
git remote remove origin

# Add your new repository
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Push to your repository
git branch -M main
git push -u origin main
```

#### Step 3: Configure GitHub Secrets

Go to your repository on GitHub → Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

1. **SSH_HOST**: Your server IP address (e.g., `123.45.67.89`)
2. **SSH_USERNAME**: Your SSH username (e.g., `pi` or `ubuntu`)
3. **SSH_PRIVATE_KEY**: Your SSH private key
   - Generate on your local machine: `ssh-keygen -t rsa -b 4096`
   - Copy the private key: `cat ~/.ssh/id_rsa`
   - Add the public key to your server: `cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys`
4. **SSH_PORT**: SSH port (usually `22`)
5. **DEPLOY_PATH**: Path on server where app is deployed (e.g., `/home/pi/the-wedding-invitation`)

#### Step 4: Prepare Your Server

SSH into your server and run:

```bash
# Install required software (if not already installed)
sudo apt update
sudo apt install -y php8.3 php8.3-fpm php8.3-mysql nginx mariadb-server nodejs npm composer git

# Create deployment directory
mkdir -p /home/pi/the-wedding-invitation
cd /home/pi/the-wedding-invitation

# Clone your repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git .

# Initial setup
composer install
cp .env.example .env
php artisan key:generate
npm install
npm run build

# Setup database
sudo mysql -u root -p
# Then run:
# CREATE DATABASE wedding_invitation;
# CREATE USER 'wedding_user'@'localhost' IDENTIFIED BY 'your_password';
# GRANT ALL PRIVILEGES ON wedding_invitation.* TO 'wedding_user'@'localhost';
# FLUSH PRIVILEGES;
# EXIT;

# Update .env with database credentials
nano .env

# Run migrations
php artisan migrate:fresh --seed
php artisan storage:link

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

#### Step 5: Configure Nginx

Create nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/wedding-invitation
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /home/pi/the-wedding-invitation/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/wedding-invitation /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
```

#### Step 6: Deploy!

Now, whenever you push to the `main` branch, GitHub Actions will automatically:
1. Build the application
2. SSH into your server
3. Pull the latest code
4. Install dependencies
5. Build assets
6. Run migrations
7. Clear and cache configs
8. Restart services

Just commit and push:

```bash
git add .
git commit -m "Initial deployment setup"
git push origin main
```

---

### Option 2: Docker Deployment

This method uses Docker containers for deployment.

#### Step 1: Setup Docker on Server

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

#### Step 2: Configure GitHub Secrets

Add these additional secrets:

1. **DOCKER_USERNAME**: Your Docker Hub username
2. **DOCKER_PASSWORD**: Your Docker Hub password or access token

#### Step 3: Use Docker Workflow

The `docker-deploy.yml` workflow will:
1. Build a Docker image
2. Push to Docker Hub
3. Deploy to your server using docker-compose

#### Step 4: Deploy

```bash
git add .
git commit -m "Docker deployment setup"
git push origin main
```

---

## Environment Variables

Make sure to set these in your server's `.env` file:

```env
APP_NAME="Wedding Invitation"
APP_ENV=production
APP_KEY=base64:YOUR_KEY_HERE
APP_DEBUG=false
APP_URL=http://your-domain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=wedding_invitation
DB_USERNAME=wedding_user
DB_PASSWORD=your_secure_password

# Add other necessary variables
```

---

## Monitoring Deployments

1. Go to your GitHub repository
2. Click on "Actions" tab
3. You'll see all deployment runs
4. Click on any run to see detailed logs

---

## Troubleshooting

### Deployment fails at SSH step
- Check your SSH secrets are correct
- Ensure your server's firewall allows SSH connections
- Verify the deploy path exists on your server

### Permission errors
```bash
sudo chown -R www-data:www-data /home/pi/the-wedding-invitation/storage
sudo chmod -R 775 /home/pi/the-wedding-invitation/storage
```

### Database connection errors
- Verify database credentials in `.env`
- Check MySQL is running: `sudo systemctl status mariadb`
- Ensure database user has proper permissions

### Assets not loading
```bash
php artisan storage:link
npm run build
sudo systemctl restart nginx
```

---

## Manual Deployment

If you prefer manual deployment without GitHub Actions:

```bash
# On your server
cd /home/pi/the-wedding-invitation
git pull origin main
composer install --no-dev --optimize-autoloader
npm ci
npm run build
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
sudo systemctl restart php8.3-fpm
sudo systemctl restart nginx
```

---

## Security Recommendations

1. **Use HTTPS**: Install SSL certificate with Let's Encrypt
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

2. **Secure .env**: Never commit `.env` to Git
3. **Use strong passwords** for database and admin panel
4. **Keep dependencies updated**: Run `composer update` and `npm update` regularly
5. **Enable firewall**:
   ```bash
   sudo ufw allow 22
   sudo ufw allow 80
   sudo ufw allow 443
   sudo ufw enable
   ```

---

## Next Steps

1. Customize the wedding invitation content via admin panel
2. Upload photos to the gallery
3. Test RSVP functionality
4. Share the invitation link with guests: `http://your-domain.com/?to=guestname`

---

For more information, refer to the main [README.md](README.md)
