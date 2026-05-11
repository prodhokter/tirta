# Guide Setup Supabase — TIRTA

> Panduan langkah demi langkah untuk setup Supabase sebagai database, autentikasi, dan storage untuk aplikasi TIRTA. Ditulis untuk pemula.

---

## Daftar Isi

1. [Buat Akun Supabase](#1-buat-akun-supabase)
2. [Buat Project Baru](#2-buat-project-baru)
3. [Ambil Kredensial (URL & Key)](#3-ambil-kredensial-url--key)
4. [Setup Database (Jalankan SQL)](#4-setup-database-jalankan-sql)
5. [Seed Data (Artikel)](#5-seed-data-artikel)
6. [Setup Auth (Google OAuth)](#6-setup-auth-google-oauth)
7. [Setup Storage](#7-setup-storage)
8. [Verifikasi Semuanya Berhasil](#8-verifikasi-semuanya-berhasil)

---

## 1. Buat Akun Supabase

1. Buka browser, kunjungi **https://supabase.com**
2. Klik tombol **"Start your project"** di pojok kanan atas
3. Klik **"Sign in with GitHub"** (paling mudah)
   - Jika belum punya akun GitHub, buat dulu di https://github.com/signup
4. Setelah login, kamu akan masuk ke **Supabase Dashboard**

> **Tips:** Jika tidak punya GitHub, bisa juga sign up pakai email biasa.

---

## 2. Buat Project Baru

1. Di Supabase Dashboard, klik tombol **"New project"**
2. Isi form berikut:

| Field | Isi | Contoh |
|-------|-----|--------|
| **Name** | Nama project | `tirta-app` |
| **Database Password** | Password kuat (SIMPAN BAIK-BAIK!) | `MyStr0ngP@ssw0rd!` |
| **Region** | Pilih terdekat | `Southeast Asia (Singapore)` |
| **Plan** | Free (cukup untuk tugas kuliah) | Free |

3. Klik **"Create new project"**
4. Tunggu sekitar **2 menit** sampai project selesai dibuat
5. Setelah selesai, kamu akan melihat dashboard project

> **PENTING:** Simpan Database Password di tempat aman! Kamu tidak bisa melihatnya lagi setelah ini.

---

## 3. Ambil Kredensial (URL & Key)

Kredensial ini dibutuhkan di Flutter app dan VPS backend.

1. Di dashboard project, klik **⚙️ Settings** (ikon gear) di sidebar kiri
2. Klik **"API"** di menu settings
3. Kamu akan melihat dua nilai penting:

```
Project URL:     https://abcdefghijk.supabase.co
anon public:     eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role:    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  (KLIK "Reveal" UNTUK MELIHAT)
```

4. **SIMPAN KEDUA NILAI INI** — kamu akan membutuhkannya nanti:
   - `Project URL` → untuk Flutter dan VPS
   - `anon public` key → untuk Flutter app
   - `service_role` key → **HANYA untuk VPS backend** (jangan pernah taruh di Flutter!)

> **KEAMANAN:** `service_role` key bisa bypass semua security. JANGAN PERNAH share atau taruh di kode Flutter!

---

## 4. Setup Database (Jalankan SQL)

Kita perlu membuat tabel database dengan struktur yang benar. Supabase sudah menyediakan SQL Editor untuk ini.

### Langkah-langkah:

1. Di sidebar kiri dashboard, klik **"SQL Editor"** (ikon dengan simbol `</>`)
2. Klik **"New query"** di pojok kanan atas
3. **Copy SELURUH isi file** `supabase/migrations/001_create_profiles.sql` dan paste ke SQL Editor
4. Klik tombol **"Run"** (atau tekan `Ctrl+Enter`)
5. Tunggu sampai muncul pesan **"Success"**
6. Ulangi langkah 2-5 untuk file migration berikutnya:

| Urutan | File | Yang Dibuat |
|--------|------|-------------|
| 1 | `001_create_profiles.sql` | Tabel profiles + auto-create trigger |
| 2 | `002_create_examinations.sql` | Tabel examinations (hasil pemeriksaan) |
| 3 | `003_create_articles.sql` | Tabel article_categories + articles |
| 4 | `004_create_chat.sql` | Tabel chat_sessions + chat_messages |

> **CARA COPY FILE:** Buka file `.sql` di VS Code, tekan `Ctrl+A` (select all), lalu `Ctrl+C` (copy), lalu paste ke SQL Editor.

### Verifikasi tabel berhasil dibuat:

1. Klik **"Table Editor"** di sidebar kiri
2. Kamu harusnya melihat tabel-tabel berikut:
   - `profiles`
   - `examinations`
   - `article_categories`
   - `articles`
   - `chat_sessions`
   - `chat_messages`

> Jika ada tabel yang tidak muncul, jalankan ulang SQL untuk migration tersebut.

---

## 5. Seed Data (Artikel)

Setelah tabel dibuat, kita perlu mengisi data artikel edukasi TBC.

1. Buka **SQL Editor** lagi
2. Klik **"New query"**
3. **Copy SELURUH isi file** `supabase/seed/seed_articles.sql` dan paste ke editor
4. Klik **"Run"**
5. Tunggu sampai muncul **"Success"**

### Verifikasi seed data:

1. Klik **"Table Editor"** di sidebar
2. Klik tabel **`article_categories`** → harus ada **6 kategori**
3. Klik tabel **`articles`** → harus ada **12 artikel**

> Jika ada error "duplicate key", itu berarti data sudah ada — tidak masalah.

---

## 6. Setup Auth (Google OAuth)

### 6a. Dapatkan Google OAuth Credentials

1. Buka **https://console.cloud.google.com/**
2. Login dengan akun Google kamu
3. Klik **"Select a project"** → **"New Project"**
4. Isi nama project: `TIRTA App` → klik **"Create"**
5. Setelah project dibuat, pastikan project ini yang terpilih
6. Buka menu **"APIs & Services"** → **"Credentials"**
   - Jika belum muncul, buka: `https://console.cloud.google.com/apis/credentials`
7. Klik **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
8. Jika diminta configure consent screen:
   - Pilih **"External"** → klik **"Create"**
   - Isi App name: `TIRTA`
   - User support email: email kamu
   - Developer contact: email kamu
   - Klik **"Save and Continue"** sampai selesai semua step
9. Kembali ke **Credentials** → **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
10. Pilih:
    - Application type: **"Android"** (untuk Flutter Android)
    - Name: `TIRTA Android`
    - Package name: `com.tirta.tirta`
    - SHA-1: Kosongkan dulu (bisa ditambahkan nanti)
11. Klik **"Create"**
12. **SIMPAN** `Client ID` yang muncul

### 6b. Setup di Supabase

1. Kembali ke **Supabase Dashboard**
2. Klik **⚙️ Settings** → **"Authentication"**
3. Di bawah **"Providers"**, cari **"Google"**
4. Aktifkan (toggle ON)
5. Isi:
   - **Client ID:** paste dari Google Cloud Console
   - **Client Secret:** dari Google Cloud Console (jika ada)
6. Klik **"Save"**

> **Catatan:** Untuk tugas kuliah, kamu bisa skip Google OAuth dan cukup pakai email/password auth yang sudah aktif secara default.

---

## 7. Setup Storage

Storage digunakan untuk menyimpan gambar artikel (opsional untuk saat ini).

1. Di sidebar, klik **"Storage"**
2. Klik **"New bucket"**
3. Isi:
   - Name: `articles`
   - Public bucket: **YES** (centang)
4. Klik **"Create bucket"**

---

## 8. Verifikasi Semuanya Berhasil

### Checklist:
- [ ] Project Supabase berhasil dibuat
- [ ] `Project URL` dan `anon key` tersimpan
- [ ] `service_role key` tersimpan (untuk VPS)
- [ ] Semua 4 migration SQL berhasil dijalankan
- [ ] 6 tabel muncul di Table Editor
- [ ] 6 kategori artikel di tabel `article_categories`
- [ ] 12 artikel di tabel `articles`
- [ ] Google OAuth terkonfigurasi (opsional)
- [ ] Storage bucket `articles` dibuat

### Kredensial yang harus kamu simpan:

```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbG...
SUPABASE_SERVICE_KEY=eyJhbG...   (HANYA untuk VPS!)
```

> **SELAMAT!** Supabase sudah siap. Lanjutkan ke [Guide Deploy VPS](GUIDE_VPS_DEPLOY.md).

---

## Troubleshooting

### Error: "relation already exists"
Artinya tabel sudah ada. Tidak masalah, bisa di-skip.

### Error: "permission denied for schema public"
Jalankan SQL ini di SQL Editor:
```sql
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;
```

### Tabel tidak muncul di Table Editor
Refresh halaman browser (F5). Jika masih tidak muncul, cek di SQL Editor apakah ada error saat menjalankan migration.
