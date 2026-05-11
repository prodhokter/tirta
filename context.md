# TIRTA — context.md
# Konteks Proyek untuk AI Agent

Dokumen ini menjelaskan konteks lengkap proyek TIRTA untuk digunakan oleh AI coding agent.  
**Baca dokumen ini terlebih dahulu sebelum melakukan apapun.**

---

## Identitas Proyek

- **Nama Aplikasi:** TIRTA (Deteksi Dini, Edukasi, Hidup Sehat)
- **Jenis:** Aplikasi Mobile (Flutter/Dart)
- **Tujuan:** Deteksi dini risiko TBC berbasis Sistem Pakar + Edukasi + Chatbot AI
- **Mata Kuliah:** Workshop Pengembangan Perangkat Bergerak
- **Institusi:** Politeknik Elektronika Negeri Surabaya (PENS)
- **Deadline:** 7 Juni 2026

---

## Tim Pengembang

| Nama | Role | Fitur Utama |
|------|------|------------|
| Firas Rasendriya Athaillah | AI/Expert System Dev | Sistem Pakar (Forward Chaining) |
| Ibnu Habib Ridwansyah | AI Integration Developer | Chatbot AI |
| Hafizh Hamas Muntazar | Education Content Developer | Fitur Edukasi + UI/UX |

---

## Tech Stack (WAJIB DIIKUTI — jangan ubah tanpa konfirmasi)

```yaml
Mobile:
  framework: Flutter (Dart)
  min_sdk: Android 5.0 (API 21) / iOS 12
  state_management: Riverpod 2.x
  routing: GoRouter
  http: dio
  local_storage: shared_preferences + hive
  ui_components: flutter_screenutil, cached_network_image, lottie

Backend (VPS):
  runtime: Node.js 20 LTS
  framework: Express.js
  process_manager: PM2
  web_server: Nginx (reverse proxy)
  ssl: Let's Encrypt (Certbot)
  port_internal: 3000

Database & Auth:
  provider: Supabase
  database: PostgreSQL 15
  auth: Supabase Auth (email/password + Google OAuth)
  storage: Supabase Storage (untuk gambar artikel)
  realtime: Supabase Realtime (opsional untuk chat)

AI:
  provider: Anthropic Claude API (claude-sonnet-4-20250514) atau OpenAI
  proxy: Via VPS Node.js backend (API key TIDAK boleh di Flutter)
```

---

## Arsitektur

```
Flutter App
├── Berkomunikasi dengan Supabase langsung untuk:
│   ├── Auth (login, register, logout)
│   ├── Database CRUD (examinations, articles, profiles, chat_messages)
│   └── Storage (gambar artikel)
│
└── Berkomunikasi dengan VPS Backend untuk:
    └── Chatbot AI (POST /api/chat) — karena API key harus disembunyikan

VPS Backend (Node.js + Express)
├── Menerima request dari Flutter
├── Menambahkan API key AI secara server-side
├── Meneruskan ke AI API (Anthropic/OpenAI)
└── Mengembalikan respons ke Flutter

Supabase
├── auth.users — data user (managed by Supabase Auth)
├── profiles — profil pengguna (trigger auto-create saat register)
├── examinations — hasil pemeriksaan sistem pakar
├── article_categories — kategori artikel
├── articles — konten artikel edukasi
├── chat_sessions — sesi chat per user
└── chat_messages — pesan dalam sesi chat
```

---

## Konvensi Kode Flutter (WAJIB DIIKUTI)

### Struktur Folder
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_routes.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── errors/
│       └── failures.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── expert_system/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── chatbot/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── education/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── history/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── dashboard/
│       └── presentation/
└── shared/
    ├── widgets/
    ├── models/
    └── services/
        ├── supabase_service.dart
        └── api_service.dart
```

### Naming Conventions
- File: `snake_case.dart`
- Class: `PascalCase`
- Variable/Method: `camelCase`
- Konstanta: `SCREAMING_SNAKE_CASE` atau `kCamelCase`
- Provider Riverpod: suffix `Provider` (contoh: `authStateProvider`)
- Notifier: suffix `Notifier` (contoh: `ExpertSystemNotifier`)

### State Management Pattern (Riverpod)
```dart
// Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Notifier untuk state kompleks
final expertSystemNotifier = NotifierProvider<ExpertSystemNotifier, ExpertSystemState>(
  ExpertSystemNotifier.new,
);
```

---

## Konvensi Kode Backend Node.js (WAJIB DIIKUTI)

### Struktur
```
backend/
├── src/
│   ├── routes/
│   │   ├── chat.routes.js
│   │   └── health.routes.js
│   ├── middleware/
│   │   ├── auth.middleware.js
│   │   └── ratelimit.middleware.js
│   ├── services/
│   │   └── ai.service.js
│   └── utils/
│       └── logger.js
├── app.js
├── server.js
├── .env
├── .env.example
└── package.json
```

### Response Format API
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional message"
}
```

Error:
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

---

## Database Supabase — Aturan Keamanan (Row Level Security)

Semua tabel WAJIB menggunakan RLS. Contoh policy:
```sql
-- User hanya bisa akses data miliknya sendiri
CREATE POLICY "Users can only access own data"
ON examinations
FOR ALL
USING (auth.uid() = user_id);
```

---

## Warna & Tema Aplikasi

```dart
// Primary Colors
static const Color primary = Color(0xFF1565C0);      // Biru tua
static const Color primaryLight = Color(0xFF1E88E5); // Biru medium
static const Color accent = Color(0xFFFFC107);        // Kuning (PENS)

// Risk Level Colors
static const Color riskLow = Color(0xFF2E7D32);      // Hijau
static const Color riskMedium = Color(0xFFF57C00);   // Orange
static const Color riskHigh = Color(0xFFB71C1C);     // Merah

// Backgrounds
static const Color bgLight = Color(0xFFF5F7FA);
static const Color cardBg = Color(0xFFFFFFFF);
```

---

## Environment Variables

### Flutter (.env atau dart-define)
```
SUPABASE_URL=https://[project-id].supabase.co
SUPABASE_ANON_KEY=[anon-key]
VPS_API_BASE_URL=https://[domain-vps]/api
```

### VPS Backend (.env)
```
PORT=3000
NODE_ENV=production
AI_PROVIDER=anthropic
AI_API_KEY=sk-ant-...
AI_MODEL=claude-sonnet-4-20250514
SUPABASE_URL=https://[project-id].supabase.co
SUPABASE_SERVICE_KEY=[service-role-key]
ALLOWED_ORIGINS=*
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=20
```

---

## System Prompt Chatbot (Context TBC Only)

```
Kamu adalah TIRTA Assistant, asisten kesehatan virtual yang HANYA membahas topik 
seputar Tuberkulosis (TBC/TB) dan kesehatan paru-paru.

Aturan yang WAJIB kamu ikuti:
1. Hanya jawab pertanyaan tentang TBC, kesehatan paru, dan topik terkait
2. Jika ditanya topik di luar TBC, sopan tolak dan arahkan kembali ke topik TBC
3. Gunakan Bahasa Indonesia yang ramah, mudah dipahami masyarakat awam
4. Selalu tambahkan disclaimer bahwa kamu bukan pengganti dokter
5. Jika ada pertanyaan darurat medis, arahkan ke fasilitas kesehatan terdekat
6. Jangan memberikan dosis obat spesifik — arahkan ke dokter/apoteker

Gaya komunikasi:
- Hangat dan empatik
- Gunakan bahasa sederhana, hindari jargon medis berlebihan
- Berikan informasi berbasis bukti ilmiah
- Singkat namun informatif (maks 200 kata per respons)
```

---

## Hal yang TIDAK Boleh Dilakukan AI Agent

- ❌ Mengubah tech stack tanpa instruksi eksplisit
- ❌ Meletakkan API key AI di dalam kode Flutter
- ❌ Membuat tabel Supabase baru tanpa mendokumentasikannya
- ❌ Mengabaikan RLS (Row Level Security) di Supabase
- ❌ Menghapus disclaimer medis dari hasil pemeriksaan
- ❌ Mengubah logika Forward Chaining tanpa konfirmasi
- ❌ Push ke main branch langsung (gunakan feature branch)

---

## Status Proyek Saat Ini (Minggu Ke-11: 11–17 Mei 2026)

- [x] Planning & arsitektur selesai
- [x] Setup proyek Flutter
- [x] Setup Supabase (auth, database schema)
- [x] Setup VPS + Nginx
- [x] Implementasi Forward Chaining + 15 pertanyaan ✅
- [x] Build UI Chat + koneksi AI API (DeepSeek) ✅
- [x] Halaman daftar & detail artikel ✅
- [x] Kalkulasi persentase & Valid/Tidak Valid ✅
- [x] Respons real-time chatbot ✅
- [x] Kategorisasi & search artikel ✅
- [x] Dashboard + History + Profile ✅
- [x] Backend Node.js (Express + DeepSeek + rate limiting) ✅
- [x] SQL Migrations + Seed data (12 artikel) ✅
- [x] Splash screen + Onboarding ✅
- [x] Dokumentasi deployment (Supabase, VPS, Flutter) ✅
