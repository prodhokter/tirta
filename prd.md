# PRD — TIRTA: Aplikasi Pendeteksi Awal TBC
**Mata Kuliah:** Workshop Pengembangan Perangkat Bergerak  
**Institusi:** Politeknik Elektronika Negeri Surabaya (PENS)  
**Versi:** 1.0.0  
**Tanggal:** Mei 2026

---

## 1. Overview

### 1.1 Deskripsi Produk
**TIRTA** (Deteksi Dini, Edukasi, Hidup Sehat) adalah aplikasi mobile berbasis Flutter yang menerapkan Expert System (Sistem Pakar) dengan metode Forward Chaining untuk membantu deteksi awal risiko Tuberkulosis (TBC). Aplikasi ini dilengkapi dengan chatbot AI berbahasa Indonesia, konten edukasi terstruktur, dan riwayat pemeriksaan pengguna.

### 1.2 Latar Belakang
- Sebagian besar penderita TBC baru mengetahui kondisinya saat gejala sudah parah (deteksi terlambat)
- Minimnya edukasi menyebabkan stigma dan keterlambatan mencari pertolongan medis
- Banyak masyarakat kesulitan mendapatkan informasi TBC yang akurat dan mudah dipahami
- Diperlukan solusi digital yang mudah diakses untuk membantu deteksi dini dan edukasi TBC

### 1.3 Target Pengguna
- Masyarakat umum (usia 12+) yang ingin mengetahui risiko TBC
- Pasien yang ingin skrining awal sebelum ke fasilitas kesehatan
- Tenaga medis di lapangan sebagai alat bantu skrining awal

---

## 2. Tech Stack

| Layer | Teknologi |
|---|---|
| Mobile Frontend | Flutter (Dart) |
| State Management | Riverpod / Bloc |
| Database Cloud | Supabase (PostgreSQL) |
| Auth | Supabase Auth (email/password + OAuth) |
| Backend API | Node.js + Express.js (di VPS) |
| AI Chatbot | Anthropic Claude API / OpenAI API (via VPS proxy) |
| VPS | Ubuntu Server + Nginx + PM2 |
| Storage | Supabase Storage (gambar artikel) |
| Versioning | Git + GitHub |

---

## 3. Arsitektur Sistem

```
┌─────────────────────────────────────────────────┐
│               Flutter Mobile App                │
│  ┌──────────┐ ┌──────────┐ ┌────────────────┐  │
│  │  Sistem  │ │ Chatbot  │ │    Edukasi     │  │
│  │  Pakar   │ │    AI    │ │    Artikel     │  │
│  └────┬─────┘ └────┬─────┘ └───────┬────────┘  │
└───────┼─────────────┼──────────────┼────────────┘
        │             │              │
        ▼             ▼              ▼
┌─────────────┐  ┌──────────┐  ┌────────────────┐
│  Supabase   │  │   VPS    │  │   Supabase     │
│  Auth + DB  │  │ API+Proxy│  │    Storage     │
│ (PostgreSQL)│  │(Node.js) │  │  (Gambar/File) │
└─────────────┘  └────┬─────┘  └────────────────┘
                      │
               ┌──────▼──────┐
               │  AI API     │
               │  (Claude /  │
               │   OpenAI)   │
               └─────────────┘
```

---

## 4. Fitur Lengkap

### 4.1 Autentikasi User (WAJIB — tambahan)
**PIC:** Semua anggota (shared setup)

#### Fungsi:
- Registrasi akun baru (email + password + nama lengkap)
- Login dengan email & password
- Login sosial (Google OAuth via Supabase)
- Lupa password (reset via email)
- Logout
- Persistensi sesi (auto-login jika token masih valid)
- Profil pengguna (nama, email, foto avatar)

#### Acceptance Criteria:
- [ ] User dapat mendaftar dengan email valid dan password minimal 8 karakter
- [ ] User menerima email verifikasi setelah registrasi
- [ ] User dapat login dan sesi tersimpan secara lokal
- [ ] User dapat reset password melalui email
- [ ] Halaman profil menampilkan data user
- [ ] Logout menghapus sesi dan redirect ke login

---

### 4.2 Sistem Pakar — Forward Chaining
**PIC:** Firas Rasendriya Athaillah

#### Fungsi:
- 15 pertanyaan gejala TBC dalam format Ya/Tidak
- Implementasi algoritma Forward Chaining
- Kalkulasi persentase indikasi TBC
- Validasi hasil: **Valid** (jika menjawab minimal N pertanyaan) atau **Tidak Valid**
- Tampil daftar gejala yang terdeteksi
- Rekomendasi tindakan medis
- Simpan riwayat pemeriksaan ke Supabase

#### 15 Pertanyaan Sistem Pakar:
| No | Pertanyaan | Kategori |
|---|---|---|
| 1 | Apakah kamu mengalami batuk terus-menerus lebih dari 2 minggu (berdahak atau kering)? | Gejala Pernapasan |
| 2 | Apakah dahak yang kamu keluarkan terkadang disertai darah? | Gejala Pernapasan |
| 3 | Apakah kamu sering merasa sesak napas? | Gejala Pernapasan |
| 4 | Apakah kamu merasakan nyeri di dada? | Gejala Pernapasan |
| 5 | Apakah kamu mengalami demam ringan (meriang) yang berlangsung lebih dari sebulan? | Gejala Sistemik |
| 6 | Apakah kamu berkeringat di malam hari meskipun tidak beraktivitas? | Gejala Sistemik |
| 7 | Apakah nafsu makan kamu menurun drastis? | Gejala Sistemik |
| 8 | Apakah berat badanmu turun tanpa sebab yang jelas? | Gejala Sistemik |
| 9 | Apakah kamu sering merasa lemah dan mudah lelah? | Gejala Sistemik |
| 10 | Apakah ada anggota keluarga / orang serumah yang menderita atau pernah menderita TBC? | Faktor Risiko |
| 11 | Apakah kamu tinggal di lingkungan yang padat penduduk atau kurang ventilasi? | Faktor Risiko |
| 12 | Apakah kamu merokok aktif atau pernah merokok? | Faktor Risiko |
| 13 | Apakah kamu memiliki riwayat HIV/AIDS atau kondisi imun yang lemah? | Faktor Risiko |
| 14 | Apakah kamu pernah didiagnosis atau diobati TBC sebelumnya? | Riwayat Medis |
| 15 | Apakah gejala batuk kamu tidak membaik meskipun sudah minum obat batuk biasa? | Riwayat Medis |

#### Logika Forward Chaining:
```
Rule 1: Batuk >2 minggu → Suspek Gejala Utama
Rule 2: Gejala Utama + 2 gejala sistemik → Risiko Sedang
Rule 3: Gejala Utama + 3+ gejala sistemik → Risiko Tinggi
Rule 4: Risiko Tinggi + Faktor Risiko ≥1 → TERINDIKASI TBC
Rule 5: Jawaban Ya ≥ 8 dari 15 → Valid

Persentase = (jumlah_ya / 15) * 100
Status Valid = jumlah_ya >= 5 (minimal menjawab Ya 5 dari 15)
Kategori:
  0–29%  → Risiko Rendah
  30–59% → Risiko Sedang (konsultasi dianjurkan)
  60–100%→ Risiko Tinggi (SEGERA konsultasi dokter)
```

#### Acceptance Criteria:
- [ ] 15 pertanyaan tampil satu per satu dengan progress bar
- [ ] User dapat kembali ke pertanyaan sebelumnya
- [ ] Persentase dihitung otomatis setelah semua pertanyaan dijawab
- [ ] Hasil menampilkan: persentase, kategori risiko, daftar gejala terdeteksi, rekomendasi
- [ ] Hasil tersimpan ke tabel `examinations` di Supabase
- [ ] Disclaimer medis ditampilkan di halaman hasil

---

### 4.3 Chatbot AI
**PIC:** Ibnu Habib Ridwansyah

#### Fungsi:
- Chat interaktif berbahasa Indonesia tentang TBC
- Integrasi AI API via VPS proxy (API key tidak exposed ke client)
- Context TBC-only (sistem prompt membatasi topik)
- Riwayat percakapan per sesi
- Quick reply buttons (Apa itu TBC?, Gejala TBC, Cara penularan)
- Indikator loading / typing
- Error handling (jika API gagal)

#### Acceptance Criteria:
- [ ] Chat UI dengan bubble message (user kiri, bot kanan)
- [ ] Respons AI muncul real-time (streaming / polling)
- [ ] Riwayat chat tersimpan per user ke Supabase
- [ ] Quick reply buttons untuk pertanyaan umum
- [ ] Pesan error yang informatif jika koneksi gagal
- [ ] Chatbot hanya menjawab topik seputar TBC/kesehatan paru

---

### 4.4 Fitur Edukasi
**PIC:** Hafizh Hamas Muntazar

#### Fungsi:
- Daftar artikel edukasi TBC terstruktur
- Kategori: Pengenalan, Gejala, Penularan, Pencegahan, Pengobatan OAT, Sosialisasi
- Fitur pencarian artikel
- Filter berdasarkan kategori
- Halaman detail artikel (dengan gambar, konten panjang)
- Artikel pilihan / featured di dashboard
- Estimasi waktu baca

#### Acceptance Criteria:
- [ ] Minimal 12 artikel tersedia di database
- [ ] Filter kategori berfungsi
- [ ] Search real-time berdasarkan judul artikel
- [ ] Detail artikel menampilkan konten lengkap dengan formatting
- [ ] Gambar artikel di-load dari Supabase Storage
- [ ] Artikel tampil di dashboard (featured 2 artikel terbaru)

---

### 4.5 Dashboard Utama
**PIC:** Hafizh Hamas Muntazar (UI), Firas (integrasi SP)

#### Komponen:
- Greeting user (nama + waktu)
- Status pemeriksaan terakhir (persentase + tanggal)
- Tombol "Periksa Sekarang" → masuk ke Sistem Pakar
- 4 shortcut fitur: Sistem Pakar, Chatbot AI, Edukasi, Riwayat
- Artikel terbaru (2 artikel)
- Notifikasi / banner info TBC

---

### 4.6 Riwayat Pemeriksaan
**PIC:** Firas Rasendriya Athaillah

#### Fungsi:
- List semua riwayat pemeriksaan user (dari Supabase)
- Filter riwayat (risiko tinggi/rendah)
- Tap untuk lihat detail hasil pemeriksaan
- Hapus riwayat pemeriksaan

---

## 5. Database Schema (Supabase PostgreSQL)

### Tabel: `profiles`
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabel: `examinations`
```sql
CREATE TABLE examinations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  score INTEGER NOT NULL,           -- jumlah jawaban "Ya"
  percentage FLOAT NOT NULL,         -- (score/15)*100
  risk_level TEXT NOT NULL,          -- 'rendah' | 'sedang' | 'tinggi'
  is_valid BOOLEAN NOT NULL,         -- score >= 5
  answers JSONB NOT NULL,            -- array 15 jawaban {q_id, answer}
  detected_symptoms JSONB,           -- gejala yang terdeteksi
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabel: `article_categories`
```sql
CREATE TABLE article_categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  icon TEXT,
  color TEXT
);
```

### Tabel: `articles`
```sql
CREATE TABLE articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  excerpt TEXT,
  content TEXT NOT NULL,
  image_url TEXT,
  category_id INTEGER REFERENCES article_categories(id),
  read_time_minutes INTEGER DEFAULT 3,
  author TEXT DEFAULT 'Tim TIRTA',
  is_featured BOOLEAN DEFAULT FALSE,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabel: `chat_sessions`
```sql
CREATE TABLE chat_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabel: `chat_messages`
```sql
CREATE TABLE chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES chat_sessions(id) NOT NULL,
  role TEXT NOT NULL,               -- 'user' | 'assistant'
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 6. VPS Configuration

### Server Spec (Minimum):
- OS: Ubuntu 22.04 LTS
- RAM: 1 GB+
- Storage: 20 GB+
- Domain/IP: dikonfigurasi dengan SSL (Let's Encrypt)

### Services di VPS:
```
VPS
├── Nginx (reverse proxy, SSL termination)
├── PM2 (process manager)
└── Node.js Backend API
    ├── POST /api/chat          — proxy ke AI API (Chatbot)
    ├── GET  /api/health        — health check
    └── POST /api/expert/analyze— opsional: validasi server-side
```

### Environment Variables (VPS):
```
AI_API_KEY=sk-...
AI_MODEL=claude-sonnet-4-20250514
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_KEY=...
PORT=3000
NODE_ENV=production
ALLOWED_ORIGINS=*
```

---

## 7. Non-Functional Requirements

| Aspek | Requirement |
|---|---|
| Performance | Response chatbot < 5 detik |
| Offline | Artikel ter-cache lokal (minimal 5 artikel) |
| Security | API key tidak di-hardcode di Flutter, semua via VPS |
| Compatibility | Android 5.0+ / iOS 12+ |
| Accessibility | Font minimum 14sp, contrast ratio WCAG AA |
| Disclaimer | Setiap hasil pemeriksaan WAJIB ada disclaimer medis |

---

## 8. Hal yang Di Luar Scope (Out of Scope)
- Telemedicine / konsultasi dokter langsung
- Diagnosa medis resmi (TIRTA hanya alat skrining)
- Push notification
- Multi-bahasa (hanya Bahasa Indonesia)
- Fitur untuk anak < 12 tahun (metode scoring berbeda)

---

## 9. Disclaimer Wajib Aplikasi
> "TIRTA adalah alat bantu skrining awal dan bukan pengganti diagnosis medis profesional. Hasil pemeriksaan ini bersifat indikatif dan tidak dapat dijadikan dasar diagnosis. Segera konsultasikan dengan tenaga kesehatan jika kamu mengalami gejala yang mengkhawatirkan."
