# TIRTA — plan.md
# Rencana Pengembangan Aplikasi TIRTA

---

## Ringkasan Timeline

| Minggu | Tanggal | Fase | Status |
|--------|---------|------|--------|
| Ke-9 | 27 Apr – 3 Mei 2026 | Perencanaan & Setup | ✅ Selesai |
| Ke-10 | 4 Mei – 10 Mei 2026 | Development Fitur Inti | ✅ Selesai |
| Ke-11 | 11 Mei – 17 Mei 2026 | Development Lanjutan | 🔄 Sedang Berjalan |
| Ke-12 | 18 Mei – 24 Mei 2026 | Integrasi & Refinement | ⏳ Belum |
| Ke-13 | 25 Mei – 31 Mei 2026 | Testing & Debug | ⏳ Belum |
| Ke-14 | 1 Jun – 7 Jun 2026 | Finalisasi & Pengumpulan | ⏳ Belum |

---

## MINGGU KE-9: Perencanaan & Setup ✅

### Semua Anggota
- [x] Kickoff meeting, pembagian tugas
- [x] Setup repository GitHub (monorepo: `/mobile` + `/backend`)
- [x] Setup proyek Flutter (flutter create + struktur folder)
- [x] Setup Supabase project (auth, database, storage)
- [x] Create semua tabel database + RLS policies
- [x] Setup VPS: Ubuntu, Nginx, Node.js, PM2, SSL
- [x] Create file `.env.example` untuk Flutter dan Backend
- [x] Setup branching strategy: `main`, `develop`, `feature/[nama]`

### Firas (Sistem Pakar)
- [x] Desain knowledge base: 15 pertanyaan + kategori
- [x] Desain logika Forward Chaining (aturan/rule)
- [x] Desain alur tampilan pertanyaan (satu per satu / progress bar)

### Ibnu (Chatbot AI)
- [x] Riset dan pilih AI API provider (Anthropic Claude)
- [x] Setup endpoint backend `/api/chat` di Node.js
- [x] Tes koneksi AI API dari VPS

### Hafizh (Edukasi + UI/UX)
- [x] Kumpulkan 12+ konten artikel TBC
- [x] Desain UI mockup semua halaman (Figma / manual)
- [x] Implementasi tema warna dan typography

---

## MINGGU KE-10: Development Fitur Inti ✅

### Semua Anggota
- [x] Implementasi autentikasi: Register, Login, Logout (Supabase Auth)
- [x] Implementasi splash screen + onboarding
- [x] Implementasi navigasi bottom navbar (Sistem Pakar, Chatbot, Edukasi, Riwayat)
- [x] Setup GoRouter dengan auth guard

### Firas (Sistem Pakar)
- [x] Implementasi model data pertanyaan dan jawaban
- [x] Implementasi UI sesi pertanyaan (15 pertanyaan satu per satu)
- [x] Implementasi progress bar pertanyaan
- [x] Tombol Ya/Tidak + navigasi pertanyaan
- [x] Tombol "Kembali" ke pertanyaan sebelumnya

### Ibnu (Chatbot AI)
- [x] Implementasi UI chat (bubble message, input field)
- [x] Koneksi Flutter → VPS API `/api/chat`
- [x] Handle respons AI dan tampilkan di chat bubble
- [x] Implementasi loading indicator (typing indicator)

### Hafizh (Edukasi)
- [x] Implementasi halaman daftar artikel (ListView)
- [x] Implementasi card artikel (gambar, judul, kategori, estimasi baca)
- [x] Implementasi halaman detail artikel (konten lengkap)
- [x] Seed data artikel ke Supabase (12+ artikel)

---

## MINGGU KE-11: Development Lanjutan ✅

### Semua Anggota
- [x] Dashboard utama: greeting, status pemeriksaan terakhir, shortcut 4 fitur
- [x] Halaman profil pengguna (nama, email, avatar)
- [x] Implementasi Google OAuth (login dengan Google)

### Firas (Sistem Pakar)
- [x] **Implementasi kalkulasi persentase indikasi TBC**
  - Rumus: `(jumlah_ya / 15) * 100`
  - Kategori: Rendah (0–29%), Sedang (30–59%), Tinggi (60–100%)
- [x] **Implementasi logika validasi Valid/Tidak Valid**
  - Valid jika jawaban Ya ≥ 5 dari 15
- [x] **Halaman hasil analisis** — persentase + kategori risiko + daftar gejala + rekomendasi
- [x] **Disclaimer medis** di halaman hasil (WAJIB)
- [x] **Simpan hasil ke Supabase** (tabel `examinations`)
- [x] Integrasi SP ke dashboard (tampil status pemeriksaan terakhir)

### Ibnu (Chatbot AI)
- [x] **Respons real-time** (polling atau streaming dari VPS)
- [x] **Riwayat percakapan** — simpan ke Supabase (`chat_sessions`, `chat_messages`)
- [x] **Error handling** — pesan error yang informatif
- [x] **Quick reply buttons** — Apa itu TBC?, Gejala TBC, Cara penularan
- [x] Rate limiting di VPS (maks 20 req/menit per user)
- [x] System prompt TBC-only di backend

### Hafizh (Edukasi + UI/UX)
- [x] **Kategorisasi artikel** — filter by kategori (chip selector)
- [x] **Fitur pencarian** — real-time search by judul
- [x] **Artikel featured** — tampilkan di dashboard (2 artikel terbaru)
- [x] **Penyempurnaan UI/UX** semua halaman
- [x] **Icon + splash screen** final

---

## MINGGU KE-12: Integrasi & Refinement ⏳

### Semua Anggota
- [ ] Integrasi semua fitur dalam navigasi yang kohesif
- [ ] Routing antar fitur (dari dashboard ke SP, dari hasil SP ke chatbot, dll.)
- [ ] Penyempurnaan UI/UX berdasarkan review bersama
- [ ] Implementasi halaman riwayat pemeriksaan

### Firas (Sistem Pakar)
- [ ] Integrasi SP ke halaman utama (status pemeriksaan terakhir)
- [ ] Simpan & load riwayat pemeriksaan dari Supabase
- [ ] Halaman detail riwayat (lihat hasil pemeriksaan lama)
- [ ] Tombol "Periksa Ulang" dari halaman hasil

### Ibnu (Chatbot AI)
- [ ] Integrasi chatbot ke navbar (tab chatbot)
- [ ] Persistent chat history per user
- [ ] Uji berbagai skenario percakapan
- [ ] Optimasi latency respons AI

### Hafizh (Edukasi + UI/UX)
- [ ] Integrasi halaman edukasi dengan link ke chatbot dan SP
- [ ] Animasi dan micro-interaction (loading, transitions)
- [ ] Responsive layout untuk berbagai ukuran layar
- [ ] Final design review semua halaman

---

## MINGGU KE-13: Testing & Debug ⏳

### Semua Anggota
- [ ] User testing (minimal 5 responden eksternal)
- [ ] Bug fixing dari hasil testing
- [ ] Review keamanan (tidak ada API key terekspos, RLS aktif)

### Firas (Sistem Pakar)
- [ ] Uji akurasi Forward Chaining — semua 15 kombinasi jawaban
- [ ] Uji edge case: semua Ya, semua Tidak, minimal jawaban
- [ ] Uji simpan/load riwayat dari Supabase

### Ibnu (Chatbot AI)
- [ ] Uji berbagai skenario pertanyaan user
- [ ] Uji respons off-topic (chatbot harus menolak topik di luar TBC)
- [ ] Uji behavior saat offline/API error
- [ ] Uji rate limiting

### Hafizh (Edukasi + UI/UX)
- [ ] Review semua konten artikel — akurasi medis
- [ ] Uji pencarian dan filter artikel
- [ ] Uji responsivitas di berbagai device/emulator
- [ ] Accessibility check (font size, contrast)

---

## MINGGU KE-14: Finalisasi & Pengumpulan ⏳

### Semua Anggota
- [ ] Final build APK (release mode)
- [ ] Final deployment VPS backend
- [ ] Dokumentasi API (Postman collection)
- [ ] Tulis laporan akhir

### Firas (Sistem Pakar)
- [ ] Final demo sistem pakar
- [ ] Dokumentasi algoritma Forward Chaining
- [ ] Screenshot semua halaman sistem pakar

### Ibnu (Chatbot AI)
- [ ] Final demo chatbot
- [ ] Dokumentasi API endpoint VPS
- [ ] Screenshot semua skenario chat

### Hafizh (Edukasi + UI/UX)
- [ ] Final artikel dan kategori lengkap
- [ ] Dokumentasi desain UI/UX
- [ ] Video demo aplikasi

---

## Prioritas Task (Untuk AI Agent)

Urutan pengerjaan berdasarkan dependensi:

```
1. Auth (Register/Login) ← DASAR, semua fitur bergantung pada ini
2. Supabase setup (schema + RLS) ← Diperlukan semua fitur
3. VPS Backend (Node.js) ← Diperlukan chatbot
4. Sistem Pakar (pertanyaan + forward chaining + hasil)
5. Chatbot AI (UI + VPS integration)
6. Edukasi (artikel + search + filter)
7. Dashboard (agregasi semua fitur)
8. Riwayat Pemeriksaan
9. Profil User
10. Polish UI + testing
```

---

## Definition of Done (DoD)

Sebuah fitur dianggap selesai jika:
- [ ] Kode berjalan tanpa error di debug mode
- [ ] Berjalan di minimal 1 Android emulator dan 1 iOS simulator
- [ ] Data tersimpan/terambil dengan benar dari Supabase
- [ ] Tidak ada API key terekspos di kode Flutter
- [ ] Disclaimer medis ada di semua halaman hasil kesehatan
- [ ] Error state ditangani (UI tidak crash saat API gagal)
- [ ] Review dan approve oleh minimal 1 anggota tim lain
