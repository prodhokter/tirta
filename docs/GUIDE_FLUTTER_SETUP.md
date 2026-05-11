# Guide Setup Flutter App — TIRTA

> Panduan langkah demi langkah untuk menjalankan aplikasi Flutter TIRTA di komputer lokal dan membuild APK. Ditulis untuk pemula.

---

## Daftar Isi

1. [Prasyarat](#1-prasyarat)
2. [Konfigurasi Environment](#2-konfigurasi-environment)
3. [Install Dependencies](#3-install-dependencies)
4. [Jalankan di Emulator](#4-jalankan-di-emulator)
5. [Jalankan di Device Fisik](#5-jalankan-di-device-fisik)
6. [Build APK (Release)](#6-build-apk-release)
7. [Struktur Kode Penting](#7-struktur-kode-penting)
8. [Troubleshooting](#troubleshooting)

---

## 1. Prasyarat

Pastikan kamu sudah menginstall:

| Software | Versi | Cara Cek | Download |
|----------|-------|----------|----------|
| **Flutter SDK** | 3.x | `flutter --version` | https://docs.flutter.dev/get-started/install |
| **Android Studio** | Terbaru | - | https://developer.android.com/studio |
| **VS Code** | Terbaru | - | https://code.visualstudio.com/ |
| **Git** | Terbaru | `git --version` | https://git-scm.com/ |

### Setup Android Studio:

1. Install Android Studio
2. Buka Android Studio → **More Actions** → **SDK Manager**
3. Di tab **SDK Platforms**, centang:
   - Android 14 (API 34)
   - Android 13 (API 33)
4. Di tab **SDK Tools**, centang:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
5. Klik **Apply** → install semua

### Setup Flutter:

```bash
# Cek apakah Flutter terinstall dengan benar
flutter doctor
```

Pastikan semuanya ada centang hijau (✓). Jika ada tanda seru (!) atau silang (✗), ikuti petunjuk yang diberikan.

> **Tips:** Jika Flutter belum ada di PATH, tambahkan folder Flutter `bin` ke System Environment Variables.

---

## 2. Konfigurasi Environment

Aplikasi TIRTA membutuhkan 3 konfigurasi: Supabase URL, Supabase Anon Key, dan VPS API URL. Caranya sangat mudah — cukup edit file `.env`.

### Langkah-langkah:

1. Buka file **`mobile/.env`** di VS Code
2. Isi nilai yang benar:

```env
SUPABASE_URL=https://project-id-kamu.supabase.co
SUPABASE_ANON_KEY=eyJhbGci_kamu_di_sini
VPS_API_BASE_URL=https://tirta-app.web.id/api
```

### Nilai yang harus diisi:

| Variable | Dari Mana | Contoh |
|----------|-----------|--------|
| `SUPABASE_URL` | Supabase Dashboard → Settings → API → Project URL | `https://abcdef.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → Settings → API → anon public key | `eyJhbGci...` |
| `VPS_API_BASE_URL` | Setelah VPS berhasil deploy | `https://tirta-app.web.id/api` |

> **PENTING:** File `.env` berisi kredensial — sudah otomatis di-ignore oleh Git, jadi tidak akan ter-upload ke GitHub.

> **Untuk testing tanpa VPS:** Gunakan `https://tirta-app.web.id/api` sebagai URL. Chatbot tidak akan berfungsi sampai VPS terdeploy, tapi fitur lain tetap jalan.

Setelah file `.env` diisi, kamu tinggal `flutter run` — tanpa parameter tambahan apapun.

---

## 3. Install Dependencies

Buka terminal di folder `mobile/`:

```bash
cd "C:\Users\Ibnu Habib\Documents\Kuliah\Tugas\Workshop Perangkat Bergerak\tirta\mobile"

# Install semua dependencies Flutter
flutter pub get
```

Tunggu sampai selesai. Jika ada error, jalankan:
```bash
flutter clean
flutter pub get
```

---

## 4. Jalankan di Emulator

### Setup Emulator Android:

1. Buka **Android Studio**
2. Klik **More Actions** → **Virtual Device Manager**
3. Klik **"Create Device"**
4. Pilih **Pixel 6** → klik **Next**
5. Pilih system image: **API 34** (atau yang tersedia) → klik **Next**
6. Klik **Finish**
7. Klik tombol **Play** (▶) untuk menjalankan emulator

### Jalankan Flutter:

```bash
cd "C:\Users\Ibnu Habib\Documents\Kuliah\Tugas\Workshop Perangkat Bergerak\tirta\mobile"

flutter run
```

Tunggu sampai aplikasi muncul di emulator. Proses pertama kali bisa memakan waktu **3-5 menit**.

> **Hot Reload:** Saat app berjalan, tekan **`r`** di terminal untuk hot reload, atau **`R`** untuk hot restart.

---

## 5. Jalankan di Device Fisik

### Persiapan HP Android:

1. Aktifkan **Developer Options**:
   - Buka **Settings** → **About Phone**
   - Tap **"Build Number"** 7 kali
   - Muncul notifikasi "You are now a developer!"
2. Aktifkan **USB Debugging**:
   - Buka **Settings** → **Developer Options**
   - Aktifkan **"USB Debugging"**
3. Hubungkan HP ke komputer dengan kabel USB
4. Saat muncul dialog di HP, centang **"Always allow"** → klik **OK**

### Jalankan:

```bash
# Cek apakah HP terdeteksi
flutter devices

# Jalankan app di HP
flutter run -d NAMA_DEVICE_KAMU
```

---

## 6. Build APK (Release)

Untuk membuat file APK yang bisa diinstall di HP manapun:

```bash
cd "C:\Users\Ibnu Habib\Documents\Kuliah\Tugas\Workshop Perangkat Bergerak\tirta\mobile"

flutter build apk --release
```

File APK akan ada di:
```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Kamu bisa copy file ini ke HP dan install langsung.

> **Ukuran APK:** Sekitar 30-50 MB. Ini normal untuk Flutter app.

---

## 7. Struktur Kode Penting

### Cara navigasi kode di VS Code:

| Yang Kamu Cari | File Lokasi |
|----------------|-------------|
| **Warna tema** | `lib/core/constants/app_colors.dart` |
| **Teks UI (Bahasa Indonesia)** | `lib/core/constants/app_strings.dart` |
| **Route/halaman** | `lib/core/constants/app_routes.dart` |
| **15 pertanyaan TBC** | `lib/features/expert_system/data/models/question_model.dart` |
| **Forward Chaining engine** | `lib/features/expert_system/domain/usecases/calculate_result_usecase.dart` |
| **System prompt chatbot** | `backend/src/services/ai.service.js` |
| **Login screen** | `lib/features/auth/presentation/screens/login_screen.dart` |
| **Chat screen** | `lib/features/chatbot/presentation/screens/chat_screen.dart` |
| **Dashboard** | `lib/features/dashboard/presentation/screens/dashboard_screen.dart` |
| **Konfigurasi Supabase/VPS** | `lib/core/config/env_config.dart` |
| **Routing utama** | `lib/app.dart` |

### Cara mengubah sesuatu:

**Mengubah warna tema:**
→ Edit `lib/core/constants/app_colors.dart`

**Menambah/edit teks:**
→ Edit `lib/core/constants/app_strings.dart`

**Mengubah pertanyaan TBC:**
→ Edit `lib/features/expert_system/data/models/question_model.dart`

**Mengubah logika Forward Chaining:**
→ Edit `lib/features/expert_system/domain/usecases/calculate_result_usecase.dart`

**Mengubah system prompt chatbot:**
→ Edit `backend/src/services/ai.service.js` (lalu redeploy VPS)

---

## Troubleshooting

### Error: "Flutter SDK not found"
Flutter belum ada di PATH. Tambahkan ke Environment Variables:
1. Search "Environment Variables" di Windows
2. Klik "Edit the system environment variables"
3. Klik "Environment Variables"
4. Di "User variables", cari "Path" → Edit
5. Tambahkan path ke folder Flutter `bin`, contoh: `C:\flutter\bin`
6. Restart terminal

### Error: "No connected devices"
- Emulator: Pastikan emulator sudah running di Android Studio
- HP fisik: Pastikan USB Debugging aktif dan HP terdeteksi (`flutter devices`)

### Error: "Gradle build failed"
```bash
cd mobile/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "Supabase initialization failed"
- Cek apakah `SUPABASE_URL` dan `SUPABASE_ANON_KEY` sudah benar
- Cek apakah project Supabase masih aktif (buka Supabase Dashboard)

### Error: "Chatbot not responding"
- Cek apakah VPS backend sudah deploy dan bisa diakses: `https://tirta-app.web.id/api/health`
- Cek log VPS: `pm2 logs tirta-backend`
- Pastikan `AI_API_KEY` di `.env` VPS sudah benar

### Build APK error: "Keystore file not found"
Untuk debug build (tanpa keystore):
```bash
flutter build apk --debug --dart-define=...
```

Untuk release build, kamu perlu setup signing key. Quick fix:
```bash
flutter build apk --release --dart-define=...
```
Flutter akan menggunakan debug signing key secara otomatis.

---

## Checklist Final

- [ ] Flutter SDK terinstall (`flutter doctor` ✓ semua)
- [ ] Android Studio terinstall + SDK + Emulator
- [ ] `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `VPS_API_BASE_URL` sudah diisi
- [ ] `flutter pub get` berhasil tanpa error
- [ ] App bisa jalan di emulator
- [ ] Login/Register berfungsi
- [ ] Sistem Pakar 15 pertanyaan bisa dijawab + hasil muncul
- [ ] Chatbot AI merespons (jika VPS sudah deploy)
- [ ] Artikel edukasi muncul
- [ ] Dashboard menampilkan semua komponen
- [ ] APK berhasil di-build

> **SELAMAT!** Aplikasi TIRTA sudah siap! 🎉
