# TIRTA — Aplikasi Pendeteksi Awal TBC

> **TIRTA** (Deteksi Dini, Edukasi, Hidup Sehat) adalah aplikasi mobile berbasis Flutter yang menerapkan Expert System (Sistem Pakar) dengan metode Forward Chaining untuk membantu deteksi awal risiko Tuberkulosis (TBC). Aplikasi ini dilengkapi dengan chatbot AI berbahasa Indonesia, konten edukasi terstruktur, dan riwayat pemeriksaan pengguna.

---

## Tim Pengembang

| Nama | Role | Fitur Utama |
|------|------|------------|
| Firas Rasendriya Athaillah | AI/Expert System Dev | Sistem Pakar (Forward Chaining) |
| Ibnu Habib Ridwansyah | AI Integration Developer | Chatbot AI + Backend |
| Hafizh Hamas Muntazar | Education Content Developer | Fitur Edukasi + UI/UX |

---

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Mobile Frontend | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Routing | GoRouter |
| Database & Auth | Supabase (PostgreSQL) |
| Backend API | Node.js + Express.js |
| AI Chatbot | DeepSeek API (deepseek-v4-flash) |
| VPS | Ubuntu Server + Nginx + PM2 |
| Domain | tirta-app.web.id |

---

## Struktur Proyek (Monorepo)

```
tirta/
├── mobile/              # Flutter app
│   ├── lib/
│   │   ├── core/        # Config, constants, theme, utils, errors
│   │   ├── features/
│   │   │   ├── auth/              # Autentikasi (login, register, OAuth)
│   │   │   ├── expert_system/     # Sistem Pakar Forward Chaining
│   │   │   ├── chatbot/           # Chatbot AI via VPS
│   │   │   ├── education/         # Artikel edukasi TBC
│   │   │   ├── history/           # Riwayat pemeriksaan
│   │   │   └── dashboard/         # Dashboard utama
│   │   └── shared/       # Shared widgets & services
│   └── pubspec.yaml
├── backend/             # Node.js VPS backend
│   ├── src/
│   │   ├── routes/       # API routes (chat, health)
│   │   ├── middleware/    # Auth, rate limit, CORS
│   │   ├── services/      # DeepSeek AI service
│   │   └── utils/         # Logger, response helpers
│   ├── app.js
│   ├── server.js
│   └── package.json
├── supabase/            # SQL migrations & seed data
│   ├── migrations/       # 001-004 table definitions + RLS
│   └── seed/             # 12 artikel edukasi
├── docs/                # Dokumentasi
│   ├── GUIDE_SUPABASE.md
│   ├── GUIDE_VPS_DEPLOY.md
│   └── GUIDE_FLUTTER_SETUP.md
└── README.md
```

---

## Fitur Utama

### 1. Sistem Pakar (Forward Chaining)
- 15 pertanyaan gejala TBC (pernapasan, sistemik, risiko, riwayat medis)
- Algoritma Forward Chaining dengan 4 aturan inferensi
- Kalkulasi persentase risiko (0–100%) dan kategori (Rendah/Sedang/Tinggi)
- Disclaimer medis di setiap hasil pemeriksaan
- Simpan riwayat ke Supabase

### 2. Chatbot AI
- Chat interaktif berbahasa Indonesia tentang TBC
- Powered by DeepSeek API (via VPS proxy)
- Context TBC-only (system prompt membatasi topik)
- Riwayat percakapan per sesi
- Quick reply buttons

### 3. Edukasi
- 12 artikel edukasi TBC terstruktur
- 6 kategori: Pengenalan, Gejala, Penularan, Pencegahan, Pengobatan, Sosialisasi
- Filter kategori dan pencarian real-time

### 4. Dashboard & Riwayat
- Greeting dinamis berdasarkan waktu
- Status pemeriksaan terakhir
- 4 shortcut fitur
- Riwayat pemeriksaan lengkap

---

## Quick Start

### Prasyarat
- Flutter SDK 3.x
- Node.js 20 LTS
- Supabase account
- VPS dengan Ubuntu 22.04
- Domain yang sudah diarahkan ke VPS

### Setup Guides
1. [Guide Setup Supabase](docs/GUIDE_SUPABASE.md)
2. [Guide Deploy VPS + Backend](docs/GUIDE_VPS_DEPLOY.md)
3. [Guide Setup Flutter App](docs/GUIDE_FLUTTER_SETUP.md)

---

## Arsitektur

```
┌─────────────────────────────────────────┐
│           Flutter Mobile App            │
│  ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │ Sistem   │ │ Chatbot  │ │ Edukasi │ │
│  │ Pakar    │ │   AI     │ │ Artikel │ │
│  └────┬─────┘ └────┬─────┘ └────┬────┘ │
└───────┼─────────────┼────────────┼──────┘
        │             │            │
        ▼             ▼            ▼
┌─────────────┐ ┌───────────┐ ┌──────────┐
│  Supabase   │ │  VPS      │ │ Supabase │
│  Auth + DB  │ │  Backend  │ │ Storage  │
│ (PostgreSQL)│ │(Node.js)  │ │(Gambar)  │
└─────────────┘ └─────┬─────┘ └──────────┘
                       │
                ┌──────▼──────┐
                │ DeepSeek AI │
                │   API       │
                └─────────────┘
```

---

## Lisensi

Proyek ini dibuat untuk tugas kuliah **Workshop Pengembangan Perangkat Bergerak** di **Politeknik Elektronika Negeri Surabaya (PENS)**.
