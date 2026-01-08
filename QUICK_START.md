# Quick Start Guide - Wedding App Deployment

## 🎉 Repository Successfully Pushed!

Your wedding invitation app is now available at:
**https://github.com/Jayrajsinh45/wedding_app**

## 📋 What's Included

I've added the following deployment configurations:

1. **`.github/workflows/deploy.yml`** - GitHub Actions workflow for SSH deployment
2. **`.github/workflows/docker-deploy.yml`** - GitHub Actions workflow for Docker deployment
3. **`DEPLOYMENT.md`** - Comprehensive deployment guide
4. **Existing Docker setup** - `Dockerfile` and `docker-compose.yaml`

## 🚀 Next Steps to Deploy

### Option 1: Deploy to Your Server (Recommended)

#### 1. Prepare Your Server

You need a VPS/server with:
- Ubuntu/Debian Linux
- SSH access
- At least 1GB RAM
- PHP 8.3, MySQL, Nginx

#### 2. Configure GitHub Secrets

Go to: https://github.com/Jayrajsinh45/wedding_app/settings/secrets/actions

Click **"New repository secret"** and add:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `SSH_HOST` | Your server IP address | `123.45.67.89` |
| `SSH_USERNAME` | SSH username | `ubuntu` or `pi` |
| `SSH_PRIVATE_KEY` | Your SSH private key | Contents of `~/.ssh/id_rsa` |
| `SSH_PORT` | SSH port | `22` |
| `DEPLOY_PATH` | Path on server | `/home/ubuntu/wedding_app` |

#### 3. Setup Server

SSH into your server and run:

```bash
# Install dependencies
sudo apt update
sudo apt install -y php8.3 php8.3-fpm php8.3-mysql php8.3-mbstring php8.3-xml \
  php8.3-curl php8.3-zip php8.3-gd php8.3-bcmath nginx mariadb-server \
  nodejs npm git

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Clone your repository
cd ~
git clone https://github.com/Jayrajsinh45/wedding_app.git
cd wedding_app

# Setup application
composer install
cp .env.example .env
php artisan key:generate
npm install
npm run build

# Setup database
sudo mysql -u root -p
```

In MySQL console:
```sql
CREATE DATABASE wedding_invitation;
CREATE USER 'wedding_user'@'localhost' IDENTIFIED BY 'YourSecurePassword123';
GRANT ALL PRIVILEGES ON wedding_invitation.* TO 'wedding_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Update `.env` file:
```bash
nano .env
```

Set these values:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=http://your-server-ip

DB_DATABASE=wedding_invitation
DB_USERNAME=wedding_user
DB_PASSWORD=YourSecurePassword123
```

Run migrations:
```bash
php artisan migrate:fresh --seed
php artisan storage:link

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

#### 4. Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/wedding-app
```

Add:
```nginx
server {
    listen 80;
    server_name your-server-ip;
    root /home/ubuntu/wedding_app/public;

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

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/wedding-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
```

#### 5. Test Deployment

Visit: `http://your-server-ip`

Admin panel: `http://your-server-ip/adminpanel`

#### 6. Auto-Deploy on Push

Now whenever you push to `main` branch, GitHub Actions will automatically deploy!

```bash
# Make changes
git add .
git commit -m "Update wedding details"
git push origin main
```

Watch deployment: https://github.com/Jayrajsinh45/wedding_app/actions

---

### Option 2: Docker Deployment

#### 1. Setup Docker Secrets

Add these additional secrets:
- `DOCKER_USERNAME` - Your Docker Hub username
- `DOCKER_PASSWORD` - Your Docker Hub password/token

#### 2. Use Docker Compose

On your server:
```bash
git clone https://github.com/Jayrajsinh45/wedding_app.git
cd wedding_app
cp .env.example .env
# Edit .env with your settings
docker-compose up -d
docker-compose exec app php artisan migrate:fresh --seed
```

---

## 🎨 Customize Your Wedding Invitation

1. **Access Admin Panel**: `http://your-server-ip/adminpanel`
2. **Default Credentials**: Check the database seeders in `database/seeders/`
3. **Update Content**:
   - Hero section (countdown, background)
   - Couple information (Mempelai)
   - Event details (Acara)
   - Photo gallery
   - Gift information (Hadiah)

## 📱 Share with Guests

Send personalized links:
- `http://your-server-ip/?to=john`
- `http://your-server-ip/?to=sarah`
- `http://your-server-ip/?to=family`

## 🔒 Security Checklist

- [ ] Change default admin credentials
- [ ] Set `APP_DEBUG=false` in production
- [ ] Use strong database passwords
- [ ] Setup SSL certificate (Let's Encrypt)
- [ ] Enable firewall (UFW)
- [ ] Regular backups of database

### Setup SSL (HTTPS)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📊 Monitor Deployments

Check deployment status:
https://github.com/Jayrajsinh45/wedding_app/actions

## 🆘 Troubleshooting

### Permission Issues
```bash
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### Clear Cache
```bash
php artisan config:clear
php artisan cache:clear
php artisan view:clear
sudo systemctl restart nginx
```

### Check Logs
```bash
tail -f storage/logs/laravel.log
sudo tail -f /var/log/nginx/error.log
```

## 📚 Additional Resources

- **Full Deployment Guide**: See `DEPLOYMENT.md`
- **Original README**: See `README.md`
- **Laravel Docs**: https://laravel.com/docs

## 💡 Tips

1. Test locally first before deploying
2. Use `.env` for sensitive data (never commit it)
3. Backup database regularly
4. Monitor server resources
5. Keep dependencies updated

---

**Repository**: https://github.com/Jayrajsinh45/wedding_app

**Need Help?** Check the Issues tab or refer to DEPLOYMENT.md for detailed instructions.
