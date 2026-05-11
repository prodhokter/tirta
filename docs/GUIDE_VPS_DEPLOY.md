# Guide Deploy VPS + Backend — TIRTA

> Panduan lengkap deploy backend TIRTA ke VPS (Virtual Private Server). Ditulis untuk pemula — ikuti langkah-langkahnya secara berurutan.

---

## Informasi Server

| Item | Nilai |
|------|-------|
| **IP VPS** | `103.253.212.55` |
| **Domain** | `tirta-app.web.id` |
| **OS** | Ubuntu 22.04 LTS |

---

## Daftar Isi

1. [Koneksi ke VPS via SSH](#1-koneksi-ke-vps-via-ssh)
2. [Update System](#2-update-system)
3. [Install Node.js 20](#3-install-nodejs-20)
4. [Install PM2](#4-install-pm2)
5. [Upload Backend ke VPS](#5-upload-backend-ke-vps)
6. [Konfigurasi Environment Variables](#6-konfigurasi-environment-variables)
7. [Test Backend](#7-test-backend)
8. [Install Nginx](#8-install-nginx)
9. [Setup Nginx Reverse Proxy](#9-setup-nginx-reverse-proxy)
10. [Setup SSL (HTTPS)](#10-setup-ssl-https)
11. [Jalankan dengan PM2](#11-jalankan-dengan-pm2)
12. [Verifikasi](#12-verifikasi)
13. [Troubleshooting](#troubleshooting)

---

## 1. Koneksi ke VPS via SSH

Buka terminal di komputer kamu (Command Prompt / PowerShell / Git Bash), lalu ketik:

```bash
ssh root@103.253.212.55
```

- Jika diminta konfirmasi fingerprint, ketik `yes` lalu Enter
- Masukkan password VPS kamu

> **Jika error "Connection refused":** Pastikan VPS sudah running dan port 22 terbuka di firewall.
>
> **Jika dari Windows:** Kamu bisa pakai aplikasi **PuTTY** atau **MobaXterm** sebagai alternatif terminal SSH.

---

## 2. Update System

Setelah berhasil login ke VPS, jalankan:

```bash
sudo apt update && sudo apt upgrade -y
```

Tunggu sampai selesai (bisa 2-5 menit tergantung kecepatan server).

---

## 3. Install Node.js 20

Jalankan perintah berikut **satu per satu**:

```bash
# Download dan install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js
sudo apt-get install -y nodejs

# Verifikasi instalasi
node --version    # Harus muncul v20.x.x
npm --version     # Harus muncul 10.x.x
```

---

## 4. Install PM2

PM2 adalah process manager yang menjaga agar backend tetap berjalan (auto restart jika crash).

```bash
sudo npm install -g pm2

# Setup PM2 untuk auto-start saat server reboot
pm2 startup systemd
```

Setelah menjalankan `pm2 startup`, PM2 akan menampilkan sebuah perintah `sudo env PATH=...`. **Copy perintah tersebut dan jalankan!**

---

## 5. Upload Backend ke VPS

Ada beberapa cara untuk upload file ke VPS. Berikut cara paling mudah:

### Cara A: Menggunakan SCP (Terminal)

Di komputer kamu (BUKAN di VPS), jalankan:

```bash
# Upload seluruh folder backend ke VPS
scp -r "C:\Users\Ibnu Habib\Documents\Kuliah\Tugas\Workshop Perangkat Bergerak\tirta\backend" root@103.253.212.55:/home/ubuntu/tirta-backend
```

> **Jika path mengandung spasi:** Bungkus dengan tanda kutip seperti di atas.

### Cara B: Menggunakan SFTP (FileZilla / WinSCP)

1. Download **WinSCP** dari https://winscp.net/ (gratis)
2. Buka WinSCP
3. Isi koneksi:
   - Host name: `103.253.212.55`
   - User name: `root`
   - Password: password VPS kamu
4. Klik **"Login"**
5. Di panel kiri (komputer kamu), navigasi ke folder `backend`
6. Di panel kanan (VPS), navigasi ke `/home/ubuntu/`
7. Drag folder `backend` dari kiri ke kanan
8. Rename folder yang muncul di VPS dari `backend` menjadi `tirta-backend`

### Cara C: Menggunakan Git (Recommended)

Jika kode sudah di GitHub:

```bash
# Di VPS
cd /home/ubuntu
git clone https://github.com/username/tirta.git tirta-repo
cp -r tirta-repo/backend tirta-backend
```

---

## 6. Konfigurasi Environment Variables

**INI LANGKAH PALING PENTING!** Tanpa file `.env` yang benar, backend tidak akan berjalan.

```bash
# Masuk ke folder backend di VPS
cd /home/ubuntu/tirta-backend

# Buat file .env
nano .env
```

Editor `nano` akan terbuka. **Copy-paste konten berikut dan ISI nilai yang benar:**

```env
PORT=3000
NODE_ENV=production

# DeepSeek AI API — DARI https://platform.deepseek.com/api_keys
AI_API_KEY=sk-deepseek-api-key-kamu-di-sini
AI_MODEL=deepseek-v4-flash
AI_BASE_URL=https://api.deepseek.com

# Supabase — DARI Supabase Dashboard > Settings > API
SUPABASE_URL=https://project-id-kamu.supabase.co
SUPABASE_SERVICE_KEY=service_role-key-kamu-di-sini

# Rate Limiting
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=20
```

### Cara mengisi:

| Variable | Dari Mana | Contoh |
|----------|-----------|--------|
| `AI_API_KEY` | **DeepSeek Platform** → https://platform.deepseek.com/api_keys → Buat API key baru | `sk-abc123...` |
| `SUPABASE_URL` | **Supabase Dashboard** → Settings → API → Project URL | `https://abcdef.supabase.co` |
| `SUPABASE_SERVICE_KEY` | **Supabase Dashboard** → Settings → API → service_role key (klik Reveal) | `eyJhbGci...` |

### Cara menyimpan di nano:
1. Setelah selesai mengetik, tekan **`Ctrl+O`** (simpan)
2. Tekan **`Enter`** (konfirmasi nama file)
3. Tekan **`Ctrl+X`** (keluar dari nano)

> **KEAMANAN:** File `.env` berisi API key rahasia. JANGAN PERNAH commit file ini ke Git!

### Install dependencies:

```bash
cd /home/ubuntu/tirta-backend
npm install --production
```

---

## 7. Test Backend

Sebelum setup Nginx, test dulu apakah backend berjalan:

```bash
cd /home/ubuntu/tirta-backend
node server.js
```

Jika berhasil, kamu akan melihat output seperti:
```
TIRTA Backend running on port 3000
```

Buka **terminal baru** (jangan tutup yang lama) dan test:

```bash
curl http://localhost:3000/api/health
```

Harusnya muncul:
```json
{"success":true,"data":{"status":"ok","timestamp":"..."}}
```

Jika muncul response di atas, backend sudah benar! Tekan **`Ctrl+C`** di terminal pertama untuk stop server.

> **Jika error "Cannot find module":** Jalankan `npm install` lagi di folder backend.

---

## 8. Install Nginx

Nginx berfungsi sebagai **reverse proxy** — menerima request dari internet dan meneruskannya ke backend Node.js.

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

---

## 9. Setup Nginx Reverse Proxy

### 9a. Pastikan DNS sudah diarahkan

Sebelum lanjut, pastikan domain `tirta-app.web.id` sudah mengarah ke IP VPS:

1. Login ke panel DNS domain kamu (tempat kamu beli domain)
2. Tambahkan **A Record**:
   - Host: `@` (atau kosongkan)
   - Value/Points to: `103.253.212.55`
   - TTL: 3600 (atau default)
3. Tambahkan **A Record** untuk www:
   - Host: `www`
   - Value/Points to: `103.253.212.55`

> **Cara cek DNS sudah benar:** Di terminal komputer kamu, jalankan:
> ```bash
> ping tirta-app.web.id
> ```
> Harusnya muncul `103.253.212.55`. Jika belum, tunggu beberapa menit/jam untuk propagasi DNS.

### 9b. Buat konfigurasi Nginx

```bash
sudo nano /etc/nginx/sites-available/tirta-api
```

Copy-paste konfigurasi berikut:

```nginx
server {
    listen 80;
    server_name tirta-app.web.id www.tirta-app.web.id;

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
        proxy_connect_timeout 60s;
    }

    # Redirect semua path lain ke /api/health
    location / {
        return 200 '{"success":true,"data":{"app":"TIRTA","status":"running"}}';
        add_header Content-Type application/json;
    }
}
```

Simpan dengan **`Ctrl+O`**, **`Enter`**, **`Ctrl+X`**.

### 9c. Aktifkan konfigurasi

```bash
# Buat symbolic link
sudo ln -s /etc/nginx/sites-available/tirta-api /etc/nginx/sites-enabled/

# Hapus default config (opsional)
sudo rm -f /etc/nginx/sites-enabled/default

# Test konfigurasi
sudo nginx -t
```

Harus muncul:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

```bash
# Reload Nginx
sudo systemctl reload nginx
```

---

## 10. Setup SSL (HTTPS)

SSL membuat koneksi aman (HTTPS). Kita menggunakan **Let's Encrypt** (gratis).

```bash
sudo certbot --nginx -d tirta-app.web.id -d www.tirta-app.web.id
```

Ikuti petunjuknya:
1. Masukkan email kamu (untuk notifikasi SSL)
2. Setuju dengan Terms of Service: ketik `Y`
3. Share email: ketik `N`
4. Pilih redirect HTTP → HTTPS: pilih **`2`** (Redirect)

Jika berhasil, kamu akan melihat:
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/tirta-app.web.id/fullchain.pem
```

> **Auto renewal:** Certbot sudah otomatis mengatur renewal SSL setiap 90 hari. Tidak perlu manual.

---

## 11. Jalankan dengan PM2

PM2 akan menjaga backend tetap berjalan 24/7.

```bash
cd /home/ubuntu/tirta-backend

# Start backend dengan PM2
pm2 start ecosystem.config.js --env production

# Simpan daftar proses PM2 (agar auto-start saat reboot)
pm2 save

# Cek status
pm2 status
```

Harusnya muncul tabel dengan status **"online"**:

```
┌─────┬────────────────┬─────────┬─────────┐
│ id  │ name           │ status  │ cpu     │
├─────┼────────────────┼─────────┼─────────┤
│ 0   │ tirta-backend  │ online  │ 0%      │
└─────┴────────────────┴─────────┴─────────┘
```

### Perintah PM2 yang berguna:

```bash
pm2 logs tirta-backend        # Lihat log real-time
pm2 restart tirta-backend     # Restart backend
pm2 stop tirta-backend        # Stop backend
pm2 monit                     # Monitor CPU & memory
```

---

## 12. Verifikasi

### Test dari browser:
Buka di browser kamu:
```
https://tirta-app.web.id/api/health
```

Harusnya muncul JSON:
```json
{"success":true,"data":{"status":"ok","timestamp":"..."}}
```

### Test dari terminal VPS:
```bash
curl https://tirta-app.web.id/api/health
```

### Test chat endpoint (perlu auth token):
```bash
curl -X POST https://tirta-app.web.id/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_SUPABASE_JWT_TOKEN" \
  -d '{"messages":[{"role":"user","content":"Apa itu TBC?"}]}'
```

> Jika muncul respons AI tentang TBC, berarti **SEMUA BERHASIL!**

---

## Troubleshooting

### Error: "Connection refused" saat akses domain
```bash
# Cek apakah backend berjalan
pm2 status

# Cek apakah Nginx berjalan
sudo systemctl status nginx

# Cek log Nginx
sudo tail -f /var/log/nginx/error.log
```

### Error: "502 Bad Gateway"
Backend tidak berjalan atau port salah:
```bash
pm2 restart tirta-backend
pm2 logs tirta-backend
```

### Error: "Certbot failed"
Pastikan DNS sudah mengarah ke IP VPS:
```bash
dig tirta-app.web.id
```

### Error: "EADDRINUSE: address already in use :::3000"
Port 3000 sudah dipakai proses lain:
```bash
# Cari proses yang pakai port 3000
sudo lsof -i :3000
# Kill proses tersebut (ganti PID)
sudo kill -9 PID_NYA
# Restart PM2
pm2 restart tirta-backend
```

### Cara update kode backend:
```bash
# Upload file baru ke VPS (dari komputer)
scp -r backend/* root@103.253.212.55:/home/ubuntu/tirta-backend/

# Di VPS
cd /home/ubuntu/tirta-backend
npm install --production
pm2 restart tirta-backend
```

### Cara melihat log backend:
```bash
pm2 logs tirta-backend --lines 100
```

---

## Ringkasan URL Backend

| URL | Keterangan |
|-----|-----------|
| `https://tirta-app.web.id/api/health` | Health check (GET) |
| `https://tirta-app.web.id/api/chat` | Chatbot AI (POST, perlu auth) |

> **SELAMAT!** Backend sudah deploy. Lanjutkan ke [Guide Setup Flutter](GUIDE_FLUTTER_SETUP.md).
