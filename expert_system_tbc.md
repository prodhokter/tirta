# Expert System — Pendeteksi Awal TBC (Tuberkulosis)

> **Dokumen ini hanya membahas modul Expert System** menggunakan metode *Forward Chaining* untuk aplikasi TBCare. Tidak membahas fitur Chatbot AI maupun Edukasi.

---

## Daftar Isi

1. [Landasan Teori Singkat](#1-landasan-teori-singkat)
2. [Knowledge Base: Daftar Gejala](#2-knowledge-base-daftar-gejala)
3. [Struktur Pertanyaan (15 Pertanyaan)](#3-struktur-pertanyaan-15-pertanyaan)
4. [Bobot dan Kategori Gejala](#4-bobot-dan-kategori-gejala)
5. [Algoritma Forward Chaining](#5-algoritma-forward-chaining)
6. [Kalkulasi Persentase Indikasi](#6-kalkulasi-persentase-indikasi)
7. [Logika Validasi Hasil (Valid / Tidak Valid)](#7-logika-validasi-hasil-valid--tidak-valid)
8. [Tabel Keputusan (Decision Table)](#8-tabel-keputusan-decision-table)
9. [Rules Lengkap (IF-THEN)](#9-rules-lengkap-if-then)
10. [Contoh Skenario Pengujian](#10-contoh-skenario-pengujian)
11. [Pseudocode Implementasi](#11-pseudocode-implementasi)
12. [Struktur Data (JSON Knowledge Base)](#12-struktur-data-json-knowledge-base)
13. [Catatan Penting & Batasan Sistem](#13-catatan-penting--batasan-sistem)

---

## 1. Landasan Teori Singkat

### Apa itu Expert System?
Sistem pakar (*expert system*) adalah program komputer yang meniru penalaran seorang ahli (dalam hal ini dokter/tenaga medis) untuk menyelesaikan masalah pada domain tertentu. Sistem ini terdiri dari:

- **Knowledge Base** — basis pengetahuan berisi fakta dan aturan medis tentang TBC.
- **Inference Engine** — mesin inferensi yang memproses fakta menggunakan aturan.
- **Working Memory** — menyimpan fakta sementara (jawaban user) selama sesi berlangsung.
- **User Interface** — antarmuka pertanyaan Ya/Tidak.

### Metode: Forward Chaining
*Forward chaining* (penalaran maju) bekerja dari **fakta → kesimpulan**. Prosesnya:

```
Fakta awal (jawaban user) → cocokkan dengan rules → hasilkan fakta baru → ulangi → kesimpulan akhir
```

Berbeda dengan *backward chaining* yang mulai dari hipotesis, forward chaining cocok untuk:
- Screening/skrining awal (tidak tahu diagnosis sebelumnya)
- Pertanyaan bertahap berdasarkan gejala yang diakui user

---

## 2. Knowledge Base: Daftar Gejala

### Klasifikasi Gejala TBC Berdasarkan Literatur Medis

TBC paru memiliki dua kelompok gejala utama:

| Kode | Nama Gejala | Kelompok | Keterangan Klinis |
|------|-------------|----------|-------------------|
| G01 | Batuk terus-menerus ≥ 2 minggu | **Utama** | Gejala cardinal TBC paru |
| G02 | Batuk berdarah (hemoptisis) | **Utama** | Indikator kuat TBC aktif |
| G03 | Demam subfebril (37–38°C) | **Utama** | Biasanya muncul sore/malam |
| G04 | Keringat malam berlebihan | **Utama** | Bukan karena kepanasan ruangan |
| G05 | Penurunan berat badan tanpa sebab jelas | **Utama** | BB turun >5% dalam 1 bulan |
| G06 | Sesak napas / nyeri dada | **Pendukung** | Terutama saat aktivitas |
| G07 | Lemah dan mudah lelah berkepanjangan | **Pendukung** | Berbeda dari kelelahan biasa |
| G08 | Nafsu makan menurun signifikan | **Pendukung** | Berlangsung >1 minggu |
| G09 | Kontak erat dengan pasien TBC positif | **Faktor Risiko** | Serumah atau kontak rutin |
| G10 | Tidak pernah/belum vaksin BCG | **Faktor Risiko** | Terutama pada anak/remaja |
| G11 | Riwayat pengobatan TBC sebelumnya | **Faktor Risiko** | Risiko TBC resisten (MDR) |
| G12 | Imunitas rendah (HIV, DM, kortikosteroid jangka panjang) | **Faktor Risiko** | Komorbiditas imunosupresi |
| G13 | Tinggal/bekerja di lingkungan padat dan kurang ventilasi | **Faktor Risiko** | Rumah kos, penjara, asrama |
| G14 | Pembesaran kelenjar getah bening di leher | **Tambahan** | Indikator TBC ekstraparu |
| G15 | Batuk tidak membaik setelah pengobatan antibiotik umum | **Tambahan** | Peneguh diagnosis banding |

---

## 3. Struktur Pertanyaan (15 Pertanyaan)

Pertanyaan disusun secara **terurut strategis**: dimulai dari gejala utama/cardinal (bobot tinggi), lalu gejala pendukung, faktor risiko, dan gejala tambahan. Ini memaksimalkan akurasi inferensi sejak awal.

---

### Pertanyaan 1 (G01) — Batuk Berkepanjangan
**"Apakah Anda mengalami batuk terus-menerus (baik berdahak maupun kering) yang sudah berlangsung selama 2 minggu atau lebih?"**

> 📌 *Batuk yang dimaksud bisa berdahak atau batuk kering. Bukan batuk sesekali karena iritasi tenggorokan biasa.*

- **YA** → catat G01 = true, lanjut ke pertanyaan 2
- **TIDAK** → catat G01 = false, lanjut ke pertanyaan 2

---

### Pertanyaan 2 (G02) — Batuk Berdarah
**"Apakah batuk Anda pernah disertai darah, atau dahak berwarna merah/coklat tua?"**

> 📌 *Bisa berupa bercak darah pada dahak, atau darah segar saat batuk. Jika belum pernah batuk sama sekali, jawab TIDAK.*

- **YA** → catat G02 = true
- **TIDAK** → catat G02 = false

---

### Pertanyaan 3 (G03) — Demam Subfebril
**"Apakah Anda sering merasa demam ringan (suhu tubuh sekitar 37–38°C), terutama pada sore atau malam hari, yang berlangsung lebih dari seminggu?"**

> 📌 *Bukan demam tinggi mendadak seperti flu biasa. Demam subfebril TBC cenderung berlangsung lama dan tidak terlalu tinggi.*

- **YA** → catat G03 = true
- **TIDAK** → catat G03 = false

---

### Pertanyaan 4 (G04) — Keringat Malam
**"Apakah Anda sering berkeringat banyak di malam hari meskipun ruangan tidak panas, bahkan sampai membasahi pakaian/seprei?"**

> 📌 *Keringat malam yang dimaksud adalah keringat berlebihan yang terjadi saat tidur, bukan karena selimut terlalu tebal atau AC mati.*

- **YA** → catat G04 = true
- **TIDAK** → catat G04 = false

---

### Pertanyaan 5 (G05) — Penurunan Berat Badan
**"Apakah berat badan Anda turun secara signifikan (lebih dari 5% dari berat awal) dalam 1–2 bulan terakhir tanpa sedang diet atau penyakit lain yang diketahui?"**

> 📌 *Contoh: jika berat badan Anda 60 kg, penurunan lebih dari 3 kg dalam sebulan tanpa alasan jelas.*

- **YA** → catat G05 = true
- **TIDAK** → catat G05 = false

---

### Pertanyaan 6 (G06) — Sesak Napas / Nyeri Dada
**"Apakah Anda sering merasakan sesak napas atau nyeri/rasa tidak nyaman di dada, terutama saat beraktivitas ringan hingga sedang?"**

> 📌 *Sesak yang dimaksud bukan karena asma yang sudah terdiagnosis atau penyakit jantung sebelumnya.*

- **YA** → catat G06 = true
- **TIDAK** → catat G06 = false

---

### Pertanyaan 7 (G07) — Kelelahan Berkepanjangan
**"Apakah Anda merasa lemah, lesu, dan mudah lelah secara berlebihan yang sudah berlangsung lebih dari 2 minggu, bahkan setelah istirahat cukup?"**

> 📌 *Berbeda dengan kelelahan biasa setelah kerja keras. Kelelahan TBC terasa menetap meski sudah tidur dan istirahat.*

- **YA** → catat G07 = true
- **TIDAK** → catat G07 = false

---

### Pertanyaan 8 (G08) — Penurunan Nafsu Makan
**"Apakah nafsu makan Anda berkurang secara signifikan (malas makan, cepat kenyang, atau tidak berselera makan) dalam lebih dari 1 minggu terakhir?"**

> 📌 *Bukan karena sedang stres ujian/pekerjaan sesaat, tapi penurunan nafsu makan yang berlangsung terus-menerus.*

- **YA** → catat G08 = true
- **TIDAK** → catat G08 = false

---

### Pertanyaan 9 (G09) — Kontak dengan Pasien TBC
**"Apakah Anda pernah tinggal serumah, bekerja berdekatan, atau melakukan kontak rutin (hampir setiap hari) dengan seseorang yang sudah terdiagnosis TBC dalam 1 tahun terakhir?"**

> 📌 *Kontak sesekali seperti bertemu di pasar sekali waktu tidak termasuk. Yang dihitung adalah kontak intens dan berulang.*

- **YA** → catat G09 = true
- **TIDAK** → catat G09 = false

---

### Pertanyaan 10 (G10) — Status Vaksinasi BCG
**"Apakah Anda tidak yakin atau tidak pernah mendapatkan vaksin BCG (vaksin TBC yang biasanya diberikan saat bayi, meninggalkan bekas bulat kecil di lengan atas)?"**

> 📌 *Jika Anda tidak tahu atau tidak memiliki bekas vaksin BCG di lengan atas kiri, pilih YA. Vaksin BCG tidak melindungi 100% tapi menurunkan risiko signifikan.*

- **YA** → catat G10 = true
- **TIDAK** → catat G10 = false

---

### Pertanyaan 11 (G11) — Riwayat Pengobatan TBC
**"Apakah Anda pernah didiagnosis dan menjalani pengobatan TBC sebelumnya, baik yang selesai tuntas maupun yang tidak diselesaikan (putus obat)?"**

> 📌 *Riwayat TBC sebelumnya, terutama yang putus obat, meningkatkan risiko TBC kambuh atau TBC resisten obat (MDR-TB).*

- **YA** → catat G11 = true
- **TIDAK** → catat G11 = false

---

### Pertanyaan 12 (G12) — Kondisi Imunitas Rendah
**"Apakah Anda saat ini memiliki kondisi yang melemahkan sistem imun, seperti: HIV/AIDS, diabetes melitus yang tidak terkontrol, atau sedang mengonsumsi obat kortikosteroid/imunosupresan jangka panjang?"**

> 📌 *Kondisi imunitas rendah secara signifikan meningkatkan kerentanan terhadap TBC aktif.*

- **YA** → catat G12 = true
- **TIDAK** → catat G12 = false

---

### Pertanyaan 13 (G13) — Lingkungan Padat & Kurang Ventilasi
**"Apakah Anda tinggal atau bekerja di tempat yang padat penghuni dan kurang ventilasi udara, seperti: kos-kosan sempit, lembaga pemasyarakatan, asrama, atau rumah dengan sirkulasi udara buruk?"**

> 📌 *Bakteri TBC (*Mycobacterium tuberculosis*) menyebar melalui udara. Lingkungan padat dan tertutup mempercepat penularan.*

- **YA** → catat G13 = true
- **TIDAK** → catat G13 = false

---

### Pertanyaan 14 (G14) — Pembengkakan Kelenjar Getah Bening
**"Apakah Anda merasakan ada benjolan atau pembengkakan yang tidak nyeri di area leher, ketiak, atau selangkangan yang sudah ada lebih dari 2 minggu?"**

> 📌 *Pembengkakan kelenjar getah bening yang keras, tidak nyeri, dan bertahan lama bisa menjadi tanda TBC kelenjar (limfadenitis TB) atau TBC ekstraparu.*

- **YA** → catat G14 = true
- **TIDAK** → catat G14 = false

---

### Pertanyaan 15 (G15) — Batuk Tidak Respons Antibiotik
**"Apakah batuk yang Anda alami tidak membaik atau bahkan memburuk meskipun sudah mengonsumsi antibiotik umum (seperti amoksisilin, eritromisin, atau sejenisnya) selama 1–2 minggu?"**

> 📌 *TBC tidak akan sembuh dengan antibiotik biasa. Jika belum pernah batuk atau batuk tidak pernah diobati, jawab TIDAK.*

- **YA** → catat G15 = true
- **TIDAK** → catat G15 = false

---

## 4. Bobot dan Kategori Gejala

Setiap gejala memiliki **bobot (weight)** berdasarkan signifikansi klinisnya dalam diagnosis TBC. Bobot ini digunakan untuk menghitung persentase indikasi.

### Tabel Bobot Gejala

| Kode | Gejala | Kategori | Bobot | Justifikasi Klinis |
|------|--------|----------|-------|-------------------|
| G01 | Batuk ≥ 2 minggu | Utama | **10** | Gejala cardinal paling umum TBC paru (>80% kasus) |
| G02 | Batuk berdarah | Utama | **15** | Highly specific untuk TBC aktif, jarang pada penyakit lain |
| G03 | Demam subfebril sore/malam | Utama | **10** | Pola demam khas TBC, berbeda dari infeksi akut |
| G04 | Keringat malam berlebihan | Utama | **10** | Triad klasik TBC bersama demam dan penurunan BB |
| G05 | Penurunan berat badan | Utama | **10** | Bagian dari triad klasik TBC |
| G06 | Sesak napas / nyeri dada | Pendukung | **5** | Gejala lanjut, bisa karena komplikasi paru |
| G07 | Lemah dan mudah lelah | Pendukung | **5** | Gejala sistemik nonspesifik tapi konsisten |
| G08 | Nafsu makan menurun | Pendukung | **5** | Berkorelasi dengan penurunan BB dan kelemahan |
| G09 | Kontak dengan pasien TBC | Faktor Risiko | **10** | Rute transmisi utama, risiko meningkat 20–30x |
| G10 | Tidak vaksin BCG | Faktor Risiko | **5** | Proteksi BCG 60–80% untuk TBC berat |
| G11 | Riwayat TBC sebelumnya | Faktor Risiko | **5** | Risiko relaps/MDR-TB meningkat signifikan |
| G12 | Imunitas rendah | Faktor Risiko | **8** | Imunosupresi → reaktivasi TBC laten |
| G13 | Lingkungan padat/kurang ventilasi | Faktor Risiko | **3** | Faktor transmisi lingkungan |
| G14 | Pembesaran kelenjar getah bening | Tambahan | **5** | Petunjuk TBC ekstraparu |
| G15 | Tidak respons antibiotik umum | Tambahan | **4** | Memperkuat diagnosis banding TBC vs. ISPA biasa |
| | **TOTAL BOBOT MAKSIMAL** | | **110** | |

> **Catatan Normalisasi:** Total bobot maksimal adalah 110 (bukan 100) untuk memberikan granularitas lebih. Persentase dihitung dengan membagi total bobot yang terkumpul dengan 110, lalu dikalikan 100.

---

## 5. Algoritma Forward Chaining

### Cara Kerja

```
INPUT:  Jawaban user (Ya=true / Tidak=false) untuk 15 pertanyaan
PROSES: Cocokkan fakta dengan rules → firing rules → hasilkan kesimpulan
OUTPUT: Persentase indikasi TBC + Level Risiko + Status Validitas
```

### Diagram Alur Forward Chaining

```
┌─────────────────────────────────────────────────────┐
│              WORKING MEMORY (awal kosong)           │
└─────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────┐
│  Tampilkan Pertanyaan 1 → User jawab Ya/Tidak       │
│  Masukkan fakta ke Working Memory                   │
│  Ulangi untuk semua 15 pertanyaan                   │
└─────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────┐
│  INFERENCE ENGINE — Pattern Matching                │
│  Cocokkan fakta di Working Memory dengan            │
│  kondisi di setiap rule (IF part)                   │
└─────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────┐
│  RULE FIRING                                        │
│  Setiap rule yang kondisinya terpenuhi → FIRED      │
│  Tambahkan kesimpulan ke Working Memory             │
└─────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────┐
│  KALKULASI AKHIR                                    │
│  Hitung total bobot gejala yang YA                  │
│  Hitung persentase indikasi                         │
│  Tentukan level risiko                              │
│  Validasi hasil                                     │
└─────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────┐
│  OUTPUT: Laporan hasil deteksi awal TBC             │
└─────────────────────────────────────────────────────┘
```

### Aturan Urutan Firing (Rule Priority)

Rules diproses dalam urutan prioritas berikut:

1. **Rules Gejala Utama** (G01–G05) — dievaluasi pertama
2. **Rules Gejala Pendukung** (G06–G08) — dievaluasi kedua
3. **Rules Faktor Risiko** (G09–G13) — dievaluasi ketiga
4. **Rules Gejala Tambahan** (G14–G15) — dievaluasi terakhir
5. **Rules Validasi** — dievaluasi setelah semua gejala

---

## 6. Kalkulasi Persentase Indikasi

### Formula Dasar

```
Skor Terkumpul = Σ (bobot_gejala × jawaban_user)
                 di mana jawaban_user = 1 jika YA, 0 jika TIDAK

Persentase Raw = (Skor Terkumpul / Total Bobot Maksimal) × 100
               = (Skor Terkumpul / 110) × 100

Persentase Final = ROUND(Persentase Raw, 1)   ← dibulatkan 1 desimal
```

### Contoh Kalkulasi

Misalkan user menjawab YA pada: G01, G03, G04, G05, G07, G09:

```
Skor = 10 + 10 + 10 + 10 + 5 + 10 = 55
Persentase = (55 / 110) × 100 = 50.0%
```

### Level Risiko Berdasarkan Persentase

| Persentase | Level Risiko | Kode Warna | Deskripsi Singkat |
|-----------|-------------|------------|-------------------|
| 0% – 19% | **Risiko Sangat Rendah** | 🟢 Hijau | Gejala tidak konsisten dengan TBC |
| 20% – 39% | **Risiko Rendah** | 🟡 Kuning | Beberapa gejala ringan, pantau kondisi |
| 40% – 59% | **Risiko Sedang** | 🟠 Oranye | Gejala cukup bermakna, disarankan konsultasi |
| 60% – 79% | **Risiko Tinggi** | 🔴 Merah | Gejala kuat, segera ke fasilitas kesehatan |
| 80% – 100% | **Risiko Sangat Tinggi** | 🔴🚨 Merah Tua | Indikasi sangat kuat, pemeriksaan mendesak |

---

## 7. Logika Validasi Hasil (Valid / Tidak Valid)

Hasil dinyatakan **Valid** atau **Tidak Valid** berdasarkan dua kriteria: **konsistensi jawaban** dan **threshold gejala utama**.

### Kondisi VALID ✅

Hasil dinyatakan **VALID** jika **salah satu atau lebih** dari kondisi berikut terpenuhi:

```
KONDISI_VALID_1: G01 = true  
  (Ada batuk ≥ 2 minggu — gejala paling dasar TBC paru)

KONDISI_VALID_2: G02 = true  
  (Ada batuk berdarah — gejala sangat spesifik)

KONDISI_VALID_3: (Jumlah gejala utama true ≥ 3) AND (Jumlah gejala total true ≥ 5)
  (Pola gejala cukup untuk inferensi bermakna)

KONDISI_VALID_4: (G09 = true) AND (Jumlah gejala apa pun true ≥ 2)
  (Ada kontak langsung + minimal 2 gejala lain)
```

> **Validitas TIDAK bergantung pada persentase tinggi/rendah.** Hasil bisa Valid dengan persentase 15% (risiko sangat rendah) asalkan memenuhi kondisi konsistensi di atas.

### Kondisi TIDAK VALID ❌

Hasil dinyatakan **TIDAK VALID** jika:

```
INVALID_1: Semua 15 jawaban = TIDAK (tidak ada gejala sama sekali)
  → Sistem tidak bisa membuat inferensi apapun

INVALID_2: G01 = false AND G02 = false AND (Jumlah gejala total true ≤ 1)
  → Terlalu sedikit informasi untuk menyimpulkan

INVALID_3: (G15 = true) AND (G01 = false) AND (G02 = false)
  → Kontradiksi: Mengaku batuk tidak membaik tapi mengaku tidak batuk
  → Indikasi inkonsistensi jawaban

INVALID_4: Persentase < 5% DAN (G09 = false) DAN (G11 = false) DAN (G12 = false)
  → Skor terlalu rendah dan tidak ada faktor risiko signifikan
  → Sistem tidak cukup percaya diri membuat kesimpulan
```

### Tindak Lanjut Berdasarkan Status Validitas

| Status | Tindak Lanjut yang Ditampilkan kepada User |
|--------|---------------------------------------------|
| **Valid** | Tampilkan hasil persentase + level risiko + rekomendasi medis sesuai level |
| **Tidak Valid** | Tampilkan pesan: *"Hasil tidak dapat divalidasi. Jawaban yang diberikan tidak cukup atau terdapat inkonsistensi. Disarankan untuk mengulang pemeriksaan dengan lebih teliti atau langsung konsultasi ke tenaga medis."* |

---

## 8. Tabel Keputusan (Decision Table)

Tabel ini menunjukkan kombinasi kritis yang **langsung menghasilkan rekomendasi khusus**, terlepas dari total persentase.

### Decision Table — Kondisi Darurat / Urgensi Tinggi

| Kondisi Terpenuhi | Override Rekomendasi |
|-------------------|----------------------|
| G02 = true (batuk berdarah) | ⚠️ Langsung tampilkan: *"Batuk berdarah adalah gejala darurat. Segera ke IGD atau fasilitas kesehatan terdekat."* |
| G02 = true AND G01 = true | Persentase otomatis ≥ 25%, level minimal Risiko Rendah-Sedang |
| G11 = true AND (G01 OR G03 OR G04 = true) | Tambahkan catatan: *"Riwayat TBC sebelumnya meningkatkan risiko TBC resisten obat (MDR-TB). Konsultasi dokter untuk evaluasi lebih lanjut."* |
| G12 = true AND persentase ≥ 30% | Tambahkan catatan: *"Kondisi imun rendah mempercepat progresi TBC. Prioritaskan pemeriksaan segera."* |
| G09 = true AND persentase ≥ 40% | Tambahkan catatan: *"Kontak erat dengan pasien TBC + gejala bermakna. Lakukan tes tuberkulin atau foto rontgen dada."* |

---

## 9. Rules Lengkap (IF-THEN)

Berikut adalah seluruh rules yang digunakan oleh *Inference Engine*:

### Rules Kategori: Gejala Utama

```
RULE_001:
  IF G01 = true (batuk ≥ 2 minggu)
  THEN tambah_fakta("ada_gejala_cardinal_batuk")
       tambah_bobot(10)

RULE_002:
  IF G02 = true (batuk berdarah)
  THEN tambah_fakta("ada_gejala_darurat")
       tambah_fakta("ada_gejala_cardinal_hemoptisis")
       tambah_bobot(15)
       set_flag("urgensi_tinggi")

RULE_003:
  IF G03 = true (demam subfebril)
  THEN tambah_fakta("ada_gejala_sistemik_demam")
       tambah_bobot(10)

RULE_004:
  IF G04 = true (keringat malam)
  THEN tambah_fakta("ada_gejala_sistemik_keringat")
       tambah_bobot(10)

RULE_005:
  IF G05 = true (penurunan BB)
  THEN tambah_fakta("ada_gejala_sistemik_BB_turun")
       tambah_bobot(10)

RULE_006:
  IF G03 = true AND G04 = true AND G05 = true
  THEN tambah_fakta("ada_TRIAD_KLASIK_TBC")
       tambah_bobot(5)  ← bonus bobot karena kombinasi triad klasik
```

### Rules Kategori: Gejala Pendukung

```
RULE_007:
  IF G06 = true (sesak napas/nyeri dada)
  THEN tambah_fakta("ada_gejala_respirasi_lanjut")
       tambah_bobot(5)

RULE_008:
  IF G07 = true (kelelahan berkepanjangan)
  THEN tambah_fakta("ada_gejala_sistemik_lelah")
       tambah_bobot(5)

RULE_009:
  IF G08 = true (nafsu makan turun)
  THEN tambah_fakta("ada_gejala_sistemik_anoreksia")
       tambah_bobot(5)

RULE_010:
  IF G06 = true AND G07 = true AND G08 = true
  THEN tambah_fakta("ada_CLUSTER_GEJALA_PENDUKUNG_LENGKAP")
       ← tidak ada bonus bobot, hanya penanda untuk laporan
```

### Rules Kategori: Faktor Risiko

```
RULE_011:
  IF G09 = true (kontak dengan pasien TBC)
  THEN tambah_fakta("ada_faktor_risiko_kontak")
       tambah_bobot(10)

RULE_012:
  IF G10 = true (tidak vaksin BCG)
  THEN tambah_fakta("ada_faktor_risiko_no_BCG")
       tambah_bobot(5)

RULE_013:
  IF G11 = true (riwayat TBC sebelumnya)
  THEN tambah_fakta("ada_faktor_risiko_riwayat_TBC")
       tambah_bobot(5)
       set_flag("waspadai_MDR_TB")

RULE_014:
  IF G12 = true (imunitas rendah)
  THEN tambah_fakta("ada_faktor_risiko_imunosupresi")
       tambah_bobot(8)

RULE_015:
  IF G13 = true (lingkungan padat)
  THEN tambah_fakta("ada_faktor_risiko_lingkungan")
       tambah_bobot(3)

RULE_016:
  IF G09 = true AND G12 = true
  THEN tambah_fakta("ada_RISIKO_GANDA_TINGGI")
       ← penanda untuk rekomendasi lebih kuat
```

### Rules Kategori: Gejala Tambahan

```
RULE_017:
  IF G14 = true (pembesaran KGB)
  THEN tambah_fakta("ada_gejala_TBC_ekstraparu")
       tambah_bobot(5)

RULE_018:
  IF G15 = true (tidak respons antibiotik) AND G01 = true
  THEN tambah_fakta("ada_gejala_resistansi_antibiotik_biasa")
       tambah_bobot(4)

RULE_019:
  IF G15 = true AND G01 = false
  THEN tambah_fakta("inkonsistensi_jawaban_G15")
       set_flag("perlu_validasi_ulang")
```

### Rules Kategori: Validasi

```
RULE_020 (Validasi VALID):
  IF G01 = true OR G02 = true
  THEN set_status_valid("VALID")

RULE_021 (Validasi VALID dengan cluster):
  IF (count_true(G01,G02,G03,G04,G05) >= 3) AND (count_true_all >= 5)
  THEN set_status_valid("VALID")

RULE_022 (Validasi VALID kontak):
  IF G09 = true AND count_true_all >= 2
  THEN set_status_valid("VALID")

RULE_023 (Validasi TIDAK VALID — kosong):
  IF count_true_all = 0
  THEN set_status_valid("TIDAK_VALID")
       set_pesan("Tidak ada gejala yang dilaporkan. Tidak dapat melakukan analisis.")

RULE_024 (Validasi TIDAK VALID — terlalu sedikit):
  IF G01 = false AND G02 = false AND count_true_all <= 1
  THEN set_status_valid("TIDAK_VALID")
       set_pesan("Informasi gejala terlalu sedikit untuk analisis yang akurat.")

RULE_025 (Validasi TIDAK VALID — inkonsistensi):
  IF "inkonsistensi_jawaban_G15" ada di Working Memory
  THEN set_status_valid("TIDAK_VALID")
       set_pesan("Ditemukan inkonsistensi pada jawaban. Mohon periksa ulang jawaban Anda.")
```

### Rules Kategori: Rekomendasi

```
RULE_026:
  IF status_valid = "VALID" AND persentase >= 0 AND persentase < 20
  THEN rekomendasi = "Gejala Anda saat ini tidak menunjukkan indikasi TBC yang signifikan. 
                      Tetap jaga kesehatan dan konsultasikan ke dokter jika gejala muncul 
                      atau memburuk."
       level = "RISIKO_SANGAT_RENDAH"

RULE_027:
  IF status_valid = "VALID" AND persentase >= 20 AND persentase < 40
  THEN rekomendasi = "Terdapat beberapa faktor risiko ringan. Pantau kondisi Anda. 
                      Disarankan berkonsultasi ke puskesmas atau klinik terdekat 
                      jika gejala berlanjut lebih dari seminggu."
       level = "RISIKO_RENDAH"

RULE_028:
  IF status_valid = "VALID" AND persentase >= 40 AND persentase < 60
  THEN rekomendasi = "Gejala Anda cukup bermakna dan memerlukan perhatian medis. 
                      Segera kunjungi puskesmas atau rumah sakit untuk pemeriksaan 
                      lebih lanjut (foto rontgen dada dan tes dahak)."
       level = "RISIKO_SEDANG"

RULE_029:
  IF status_valid = "VALID" AND persentase >= 60 AND persentase < 80
  THEN rekomendasi = "Pola gejala Anda sangat konsisten dengan TBC. Segera kunjungi 
                      fasilitas kesehatan dalam 1–2 hari ke depan untuk pemeriksaan 
                      definitif. Hindari kontak dekat dengan orang lain sementara waktu."
       level = "RISIKO_TINGGI"

RULE_030:
  IF status_valid = "VALID" AND persentase >= 80
  THEN rekomendasi = "Indikasi TBC sangat kuat. Segera ke dokter atau IGD rumah sakit 
                      hari ini. Jangan tunda pemeriksaan."
       level = "RISIKO_SANGAT_TINGGI"

RULE_031 (Override Darurat):
  IF flag("urgensi_tinggi") ada di Working Memory
  THEN prepend_rekomendasi("⚠️ PERHATIAN: Batuk berdarah adalah gejala yang memerlukan 
                             penanganan segera. Kunjungi IGD atau fasilitas kesehatan 
                             terdekat sekarang.")
```

---

## 10. Contoh Skenario Pengujian

### Skenario A — Risiko Tinggi (Expected: Valid, ~73%)

| Pertanyaan | Gejala | Jawaban | Bobot |
|-----------|--------|---------|-------|
| Q1 | Batuk ≥ 2 minggu | YA | 10 |
| Q2 | Batuk berdarah | TIDAK | 0 |
| Q3 | Demam subfebril | YA | 10 |
| Q4 | Keringat malam | YA | 10 |
| Q5 | Penurunan BB | YA | 10 |
| Q6 | Sesak napas | TIDAK | 0 |
| Q7 | Kelelahan | YA | 5 |
| Q8 | Nafsu makan turun | YA | 5 |
| Q9 | Kontak pasien TBC | YA | 10 |
| Q10 | Tidak vaksin BCG | TIDAK | 0 |
| Q11 | Riwayat TBC | TIDAK | 0 |
| Q12 | Imunitas rendah | TIDAK | 0 |
| Q13 | Lingkungan padat | YA | 3 |
| Q14 | Pembesaran KGB | TIDAK | 0 |
| Q15 | Tidak respons antibiotik | YA | 4 |

**Bonus Rule_006 (Triad Klasik):** G03+G04+G05 semua YA → +5 bobot

```
Skor = 10+10+10+10+5+5+10+3+4 = 67 + bonus 5 = 72
Persentase = (72/110) × 100 = 65.5%  → RISIKO TINGGI
Validasi: G01=true → VALID ✅
```

---

### Skenario B — Risiko Sangat Rendah (Expected: Valid, ~9%)

| Gejala yang YA | G07 (kelelahan), G13 (lingkungan padat) |
|---------------|----------------------------------------|
| Skor | 5 + 3 = 8 |
| Persentase | (8/110) × 100 = 7.3% |
| Validasi | G01=false, G02=false, total YA = 2 > 1 |

> ⚠️ **Edge Case:** G01=false, G02=false, total YA = 2. Cek Rule_024:
> kondisi Rule_024 adalah `count_true_all <= 1`, sedangkan di sini = 2. Maka **TIDAK** memenuhi Rule_024.
> Cek Rule_020–022: tidak ada yang terpenuhi (G01=false, G02=false, G09=false).
> **Hasil: TIDAK VALID** — terlalu sedikit gejala bermakna.

---

### Skenario C — Darurat (Expected: Valid, ~59% + flag urgensi tinggi)

| Gejala yang YA | G01, G02, G03, G07, G09 |
|---------------|-------------------------|
| Skor | 10+15+10+5+10 = 50 |
| Persentase | (50/110) × 100 = 45.5% → Risiko Sedang |
| Validasi | G02=true → VALID ✅ |
| Flag | urgensi_tinggi = true → Override Rekomendasi Darurat |

**Output yang ditampilkan:**
> ⚠️ PERHATIAN: Batuk berdarah adalah gejala yang memerlukan penanganan segera. Kunjungi IGD atau fasilitas kesehatan terdekat sekarang.
>
> Indikasi TBC: **45.5% — Risiko Sedang**. Gejala Anda cukup bermakna...

---

### Skenario D — Tidak Valid / Inkonsistensi

| Jawaban | G15=YA (tidak respons antibiotik), G01=TIDAK, semua lain TIDAK |
|--------|----------------------------------------------------------------|
| Rule_019 | G15=true AND G01=false → inkonsistensi_jawaban_G15 |
| Rule_025 | inkonsistensi ada → status = TIDAK_VALID |
| Output | Pesan inkonsistensi, minta user ulang |

---

## 11. Pseudocode Implementasi

```dart
// ============================================================
// STRUKTUR DATA
// ============================================================

class Symptom {
  String code;         // e.g., "G01"
  String question;     // teks pertanyaan
  String hint;         // penjelasan tambahan
  String category;     // "utama" | "pendukung" | "risiko" | "tambahan"
  int weight;          // bobot gejala
  bool? answer;        // null = belum dijawab, true = YA, false = TIDAK
}

class ExpertSystemResult {
  double percentage;
  String riskLevel;
  String validityStatus;   // "VALID" | "TIDAK_VALID"
  String recommendation;
  List<String> detectedSymptoms;
  List<String> flags;
  bool isUrgent;
}

// ============================================================
// KONSTANTA
// ============================================================

const int TOTAL_MAX_WEIGHT = 110;

const Map<String, int> SYMPTOM_WEIGHTS = {
  "G01": 10, "G02": 15, "G03": 10, "G04": 10, "G05": 10,
  "G06": 5,  "G07": 5,  "G08": 5,  "G09": 10, "G10": 5,
  "G11": 5,  "G12": 8,  "G13": 3,  "G14": 5,  "G15": 4,
};

// ============================================================
// INFERENCE ENGINE
// ============================================================

ExpertSystemResult runForwardChaining(Map<String, bool> answers) {

  // --- WORKING MEMORY ---
  Set<String> workingMemory = {};
  List<String> flags = [];
  int totalScore = 0;
  bool isUrgent = false;

  // ---- PHASE 1: Tambahkan semua fakta dari jawaban user ----
  answers.forEach((code, answer) {
    if (answer == true) {
      workingMemory.add("fact_${code}_true");
    }
  });

  // ---- PHASE 2: Hitung skor dan firing rules gejala ----

  // Gejala Utama
  if (answers["G01"] == true) {
    workingMemory.add("ada_gejala_cardinal_batuk");
    totalScore += 10;
  }
  if (answers["G02"] == true) {
    workingMemory.add("ada_gejala_darurat");
    workingMemory.add("ada_gejala_cardinal_hemoptisis");
    totalScore += 15;
    isUrgent = true;
    flags.add("urgensi_tinggi");
  }
  if (answers["G03"] == true) { workingMemory.add("ada_gejala_sistemik_demam"); totalScore += 10; }
  if (answers["G04"] == true) { workingMemory.add("ada_gejala_sistemik_keringat"); totalScore += 10; }
  if (answers["G05"] == true) { workingMemory.add("ada_gejala_sistemik_BB_turun"); totalScore += 10; }

  // Bonus Triad Klasik (Rule_006)
  if (answers["G03"] == true && answers["G04"] == true && answers["G05"] == true) {
    workingMemory.add("ada_TRIAD_KLASIK_TBC");
    totalScore += 5;  // bonus bobot triad
  }

  // Gejala Pendukung
  if (answers["G06"] == true) { workingMemory.add("ada_gejala_respirasi_lanjut"); totalScore += 5; }
  if (answers["G07"] == true) { workingMemory.add("ada_gejala_sistemik_lelah"); totalScore += 5; }
  if (answers["G08"] == true) { workingMemory.add("ada_gejala_sistemik_anoreksia"); totalScore += 5; }

  // Faktor Risiko
  if (answers["G09"] == true) { workingMemory.add("ada_faktor_risiko_kontak"); totalScore += 10; }
  if (answers["G10"] == true) { workingMemory.add("ada_faktor_risiko_no_BCG"); totalScore += 5; }
  if (answers["G11"] == true) {
    workingMemory.add("ada_faktor_risiko_riwayat_TBC");
    totalScore += 5;
    flags.add("waspadai_MDR_TB");
  }
  if (answers["G12"] == true) { workingMemory.add("ada_faktor_risiko_imunosupresi"); totalScore += 8; }
  if (answers["G13"] == true) { workingMemory.add("ada_faktor_risiko_lingkungan"); totalScore += 3; }

  // Gejala Tambahan
  if (answers["G14"] == true) { workingMemory.add("ada_gejala_TBC_ekstraparu"); totalScore += 5; }
  if (answers["G15"] == true && answers["G01"] == true) {
    workingMemory.add("ada_gejala_resistansi_antibiotik");
    totalScore += 4;
  }
  if (answers["G15"] == true && answers["G01"] == false) {
    workingMemory.add("inkonsistensi_jawaban_G15");
    flags.add("perlu_validasi_ulang");
  }

  // ---- PHASE 3: Hitung persentase ----
  double percentage = (totalScore / TOTAL_MAX_WEIGHT) * 100;
  percentage = double.parse(percentage.toStringAsFixed(1));

  // ---- PHASE 4: Validasi ----
  int countTrue = answers.values.where((v) => v == true).length;
  int countMainSymptomTrue = [answers["G01"], answers["G02"], answers["G03"],
                               answers["G04"], answers["G05"]]
                              .where((v) => v == true).length;

  String validityStatus = "TIDAK_VALID";  // default
  String validityMessage = "";

  // Cek kondisi TIDAK VALID dulu
  if (countTrue == 0) {
    validityMessage = "Tidak ada gejala yang dilaporkan. Tidak dapat melakukan analisis.";
  } else if (answers["G01"] == false && answers["G02"] == false && countTrue <= 1) {
    validityMessage = "Informasi gejala terlalu sedikit untuk analisis yang akurat.";
  } else if (workingMemory.contains("inkonsistensi_jawaban_G15")) {
    validityMessage = "Ditemukan inkonsistensi pada jawaban Anda (Q15). Mohon periksa ulang jawaban Anda.";
  } else if (percentage < 5.0 && answers["G09"] == false &&
             answers["G11"] == false && answers["G12"] == false) {
    validityMessage = "Skor terlalu rendah tanpa faktor risiko signifikan.";
  } else {
    // Cek kondisi VALID
    if (answers["G01"] == true || answers["G02"] == true) {
      validityStatus = "VALID";
    } else if (countMainSymptomTrue >= 3 && countTrue >= 5) {
      validityStatus = "VALID";
    } else if (answers["G09"] == true && countTrue >= 2) {
      validityStatus = "VALID";
    } else {
      validityMessage = "Pola gejala tidak mencukupi untuk validasi. Mohon konsultasi langsung ke tenaga medis.";
    }
  }

  // ---- PHASE 5: Tentukan Level Risiko & Rekomendasi ----
  String riskLevel = "";
  String recommendation = "";

  if (validityStatus == "VALID") {
    if (percentage < 20) {
      riskLevel = "RISIKO_SANGAT_RENDAH";
      recommendation = "Gejala Anda saat ini tidak menunjukkan indikasi TBC yang signifikan. "
                       "Tetap jaga kesehatan dan konsultasikan ke dokter jika gejala muncul atau memburuk.";
    } else if (percentage < 40) {
      riskLevel = "RISIKO_RENDAH";
      recommendation = "Terdapat beberapa faktor risiko ringan. Pantau kondisi Anda selama 1–2 minggu. "
                       "Disarankan berkonsultasi ke puskesmas atau klinik terdekat jika gejala berlanjut.";
    } else if (percentage < 60) {
      riskLevel = "RISIKO_SEDANG";
      recommendation = "Gejala Anda cukup bermakna dan memerlukan perhatian medis. "
                       "Segera kunjungi puskesmas atau rumah sakit untuk pemeriksaan rontgen dada dan tes dahak.";
    } else if (percentage < 80) {
      riskLevel = "RISIKO_TINGGI";
      recommendation = "Pola gejala Anda sangat konsisten dengan TBC. Segera kunjungi fasilitas kesehatan "
                       "dalam 1–2 hari ke depan. Hindari kontak dekat dengan orang lain sementara waktu.";
    } else {
      riskLevel = "RISIKO_SANGAT_TINGGI";
      recommendation = "Indikasi TBC sangat kuat. Segera ke dokter atau IGD rumah sakit hari ini. Jangan tunda.";
    }

    // Tambahan catatan berdasarkan flags
    if (flags.contains("waspadai_MDR_TB")) {
      recommendation += "\n\nCatatan: Riwayat TBC sebelumnya meningkatkan risiko TBC resisten obat (MDR-TB). "
                        "Informasikan riwayat ini kepada dokter.";
    }

    // Override darurat jika ada batuk berdarah
    if (isUrgent) {
      recommendation = "⚠️ PERHATIAN: Batuk berdarah adalah gejala yang memerlukan penanganan segera. "
                       "Kunjungi IGD atau fasilitas kesehatan terdekat sekarang.\n\n" + recommendation;
    }
  } else {
    recommendation = validityMessage.isNotEmpty
        ? validityMessage
        : "Hasil tidak dapat divalidasi. Disarankan untuk mengulang pemeriksaan atau langsung konsultasi ke tenaga medis.";
  }

  // ---- PHASE 6: Kumpulkan gejala yang terdeteksi ----
  List<String> detectedSymptoms = [];
  answers.forEach((code, answer) {
    if (answer == true) {
      detectedSymptoms.add(SYMPTOM_LABELS[code] ?? code);
    }
  });

  return ExpertSystemResult(
    percentage: percentage,
    riskLevel: riskLevel,
    validityStatus: validityStatus,
    recommendation: recommendation,
    detectedSymptoms: detectedSymptoms,
    flags: flags,
    isUrgent: isUrgent,
  );
}
```

---

## 12. Struktur Data (JSON Knowledge Base)

File ini dapat disimpan sebagai `knowledge_base.json` dan di-load oleh aplikasi Flutter.

```json
{
  "metadata": {
    "version": "1.0.0",
    "total_max_weight": 110,
    "total_questions": 15,
    "created_by": "TBCare Expert System",
    "reference": "Pedoman Nasional Penanggulangan Tuberkulosis, Kemenkes RI"
  },
  "symptoms": [
    {
      "code": "G01",
      "order": 1,
      "category": "utama",
      "weight": 10,
      "question": "Apakah Anda mengalami batuk terus-menerus (baik berdahak maupun kering) yang sudah berlangsung selama 2 minggu atau lebih?",
      "hint": "Batuk yang dimaksud bisa berdahak atau batuk kering. Bukan batuk sesekali karena iritasi tenggorokan biasa.",
      "icon": "lungs"
    },
    {
      "code": "G02",
      "order": 2,
      "category": "utama",
      "weight": 15,
      "question": "Apakah batuk Anda pernah disertai darah, atau dahak berwarna merah/coklat tua?",
      "hint": "Bisa berupa bercak darah pada dahak, atau darah segar saat batuk. Jika belum pernah batuk sama sekali, jawab TIDAK.",
      "icon": "blood_drop",
      "is_urgent_trigger": true
    },
    {
      "code": "G03",
      "order": 3,
      "category": "utama",
      "weight": 10,
      "question": "Apakah Anda sering merasa demam ringan (suhu tubuh sekitar 37–38°C), terutama pada sore atau malam hari, yang berlangsung lebih dari seminggu?",
      "hint": "Bukan demam tinggi mendadak seperti flu biasa. Demam subfebril TBC cenderung berlangsung lama dan tidak terlalu tinggi.",
      "icon": "thermometer"
    },
    {
      "code": "G04",
      "order": 4,
      "category": "utama",
      "weight": 10,
      "question": "Apakah Anda sering berkeringat banyak di malam hari meskipun ruangan tidak panas, bahkan sampai membasahi pakaian/seprei?",
      "hint": "Keringat malam yang dimaksud adalah keringat berlebihan yang terjadi saat tidur, bukan karena selimut terlalu tebal.",
      "icon": "sweat"
    },
    {
      "code": "G05",
      "order": 5,
      "category": "utama",
      "weight": 10,
      "question": "Apakah berat badan Anda turun secara signifikan (lebih dari 5% dari berat awal) dalam 1–2 bulan terakhir tanpa sedang diet atau penyakit lain yang diketahui?",
      "hint": "Contoh: jika berat badan Anda 60 kg, penurunan lebih dari 3 kg dalam sebulan tanpa alasan jelas.",
      "icon": "scale"
    },
    {
      "code": "G06",
      "order": 6,
      "category": "pendukung",
      "weight": 5,
      "question": "Apakah Anda sering merasakan sesak napas atau nyeri/rasa tidak nyaman di dada, terutama saat beraktivitas ringan hingga sedang?",
      "hint": "Sesak yang dimaksud bukan karena asma yang sudah terdiagnosis atau penyakit jantung sebelumnya.",
      "icon": "chest"
    },
    {
      "code": "G07",
      "order": 7,
      "category": "pendukung",
      "weight": 5,
      "question": "Apakah Anda merasa lemah, lesu, dan mudah lelah secara berlebihan yang sudah berlangsung lebih dari 2 minggu, bahkan setelah istirahat cukup?",
      "hint": "Berbeda dengan kelelahan biasa setelah kerja keras. Kelelahan TBC terasa menetap meski sudah tidur dan istirahat.",
      "icon": "fatigue"
    },
    {
      "code": "G08",
      "order": 8,
      "category": "pendukung",
      "weight": 5,
      "question": "Apakah nafsu makan Anda berkurang secara signifikan (malas makan, cepat kenyang, atau tidak berselera makan) dalam lebih dari 1 minggu terakhir?",
      "hint": "Bukan karena sedang stres sesaat, tapi penurunan nafsu makan yang berlangsung terus-menerus.",
      "icon": "food_cross"
    },
    {
      "code": "G09",
      "order": 9,
      "category": "risiko",
      "weight": 10,
      "question": "Apakah Anda pernah tinggal serumah, bekerja berdekatan, atau melakukan kontak rutin (hampir setiap hari) dengan seseorang yang sudah terdiagnosis TBC dalam 1 tahun terakhir?",
      "hint": "Kontak sesekali tidak termasuk. Yang dihitung adalah kontak intens dan berulang.",
      "icon": "person_contact"
    },
    {
      "code": "G10",
      "order": 10,
      "category": "risiko",
      "weight": 5,
      "question": "Apakah Anda tidak yakin atau tidak pernah mendapatkan vaksin BCG (vaksin TBC yang biasanya diberikan saat bayi, meninggalkan bekas bulat kecil di lengan atas)?",
      "hint": "Jika Anda tidak tahu atau tidak memiliki bekas vaksin BCG di lengan atas kiri, pilih YA.",
      "icon": "syringe_cross"
    },
    {
      "code": "G11",
      "order": 11,
      "category": "risiko",
      "weight": 5,
      "question": "Apakah Anda pernah didiagnosis dan menjalani pengobatan TBC sebelumnya, baik yang selesai tuntas maupun yang tidak diselesaikan (putus obat)?",
      "hint": "Riwayat TBC sebelumnya, terutama yang putus obat, meningkatkan risiko TBC kambuh atau TBC resisten obat (MDR-TB).",
      "icon": "history_pill",
      "triggers_flag": "waspadai_MDR_TB"
    },
    {
      "code": "G12",
      "order": 12,
      "category": "risiko",
      "weight": 8,
      "question": "Apakah Anda saat ini memiliki kondisi yang melemahkan sistem imun, seperti: HIV/AIDS, diabetes melitus yang tidak terkontrol, atau sedang mengonsumsi obat kortikosteroid/imunosupresan jangka panjang?",
      "hint": "Kondisi imunitas rendah secara signifikan meningkatkan kerentanan terhadap TBC aktif.",
      "icon": "immune_low"
    },
    {
      "code": "G13",
      "order": 13,
      "category": "risiko",
      "weight": 3,
      "question": "Apakah Anda tinggal atau bekerja di tempat yang padat penghuni dan kurang ventilasi udara, seperti: kos-kosan sempit, lembaga pemasyarakatan, asrama, atau rumah dengan sirkulasi udara buruk?",
      "hint": "Bakteri TBC menyebar melalui udara. Lingkungan padat dan tertutup mempercepat penularan.",
      "icon": "building_crowded"
    },
    {
      "code": "G14",
      "order": 14,
      "category": "tambahan",
      "weight": 5,
      "question": "Apakah Anda merasakan ada benjolan atau pembengkakan yang tidak nyeri di area leher, ketiak, atau selangkangan yang sudah ada lebih dari 2 minggu?",
      "hint": "Pembengkakan kelenjar getah bening yang keras, tidak nyeri, dan bertahan lama bisa menjadi tanda TBC kelenjar atau TBC ekstraparu.",
      "icon": "lymph_node"
    },
    {
      "code": "G15",
      "order": 15,
      "category": "tambahan",
      "weight": 4,
      "question": "Apakah batuk yang Anda alami tidak membaik atau bahkan memburuk meskipun sudah mengonsumsi antibiotik umum (seperti amoksisilin, eritromisin, atau sejenisnya) selama 1–2 minggu?",
      "hint": "TBC tidak akan sembuh dengan antibiotik biasa. Jika belum pernah batuk atau batuk tidak pernah diobati, jawab TIDAK.",
      "icon": "medicine_cross",
      "consistency_check_with": "G01"
    }
  ],
  "bonus_rules": [
    {
      "rule_id": "BONUS_TRIAD",
      "description": "Bonus bobot jika triad klasik TBC terpenuhi",
      "conditions": ["G03", "G04", "G05"],
      "operator": "AND",
      "bonus_weight": 5
    }
  ],
  "thresholds": {
    "risiko_sangat_rendah": { "min": 0,  "max": 19.9 },
    "risiko_rendah":        { "min": 20, "max": 39.9 },
    "risiko_sedang":        { "min": 40, "max": 59.9 },
    "risiko_tinggi":        { "min": 60, "max": 79.9 },
    "risiko_sangat_tinggi": { "min": 80, "max": 100  }
  },
  "validity_rules": {
    "valid_conditions": [
      { "id": "V1", "description": "G01 atau G02 bernilai true", "logic": "G01 OR G02" },
      { "id": "V2", "description": "Minimal 3 gejala utama + 5 total gejala", "logic": "count(G01..G05) >= 3 AND count_all >= 5" },
      { "id": "V3", "description": "Ada kontak TBC + minimal 2 gejala", "logic": "G09 AND count_all >= 2" }
    ],
    "invalid_conditions": [
      { "id": "I1", "description": "Semua jawaban TIDAK", "logic": "count_all == 0" },
      { "id": "I2", "description": "Tidak ada gejala batuk dan terlalu sedikit gejala lain", "logic": "NOT G01 AND NOT G02 AND count_all <= 1" },
      { "id": "I3", "description": "Inkonsistensi G15 dan G01", "logic": "G15 AND NOT G01" },
      { "id": "I4", "description": "Skor terlalu rendah tanpa faktor risiko", "logic": "percentage < 5 AND NOT G09 AND NOT G11 AND NOT G12" }
    ]
  }
}
```

---

## 13. Catatan Penting & Batasan Sistem

### ⚠️ Disclaimer Medis (WAJIB ditampilkan di UI)

> **Aplikasi ini adalah alat bantu skrining awal, bukan alat diagnosis medis.** Hasil yang ditampilkan hanya bersifat indikatif berdasarkan gejala yang dilaporkan secara mandiri oleh pengguna. Sistem pakar ini tidak dapat menggantikan pemeriksaan fisik, tes laboratorium (kultur dahak, BTA), atau pencitraan medis (foto rontgen dada) yang dilakukan oleh tenaga kesehatan berlisensi. **Selalu konsultasikan hasil ini kepada dokter atau puskesmas terdekat.**

---

### Batasan Sistem yang Perlu Dipahami Pengembang

| Batasan | Penjelasan | Mitigasi |
|---------|-----------|---------|
| **Subjektivitas Jawaban** | User mungkin tidak mengetahui persisnya apakah gejala berlangsung ≥2 minggu | Teks hint di setiap pertanyaan membantu klarifikasi |
| **Tidak mendeteksi TBC laten** | Sistem hanya mendeteksi gejala aktif, TBC laten tidak bergejala | Tambahkan saran tes tuberkulin pada faktor risiko tinggi |
| **Tidak ada konteks usia/jenis kelamin** | Beberapa gejala memiliki prevalensi berbeda berdasarkan usia | Pertimbangkan penambahan data demografis di versi mendatang |
| **Gejala overlap dengan penyakit lain** | Batuk + demam + keringat malam bisa juga dari limfoma, pneumonia, dll. | Disclaimer dan rekomendasi konsultasi dokter sangat penting |
| **Tidak ada data serial** | Sistem tidak membandingkan hasil antar waktu | Fitur riwayat pemeriksaan perlu disimpan untuk monitoring |
| **Total bobot 110 (bukan 100)** | Persentase >100% tidak mungkin karena bonus hanya aktif jika gejala utama sudah dihitung | Tetap validasi output: clamp persentase ke 0–100 |

---

### Panduan Pengembangan Selanjutnya

- **Versi 1.1:** Tambahkan pertanyaan demografis (usia, jenis kelamin) untuk penyesuaian bobot.
- **Versi 1.2:** Integrasikan dengan database kasus TBC lokal (kabupaten/kota) untuk konteks epidemiologi.
- **Versi 2.0:** Pertimbangkan metode *Certainty Factor* (CF) sebagai pelengkap Forward Chaining untuk menangani ketidakpastian jawaban.
- **Evaluasi Akurasi:** Lakukan pengujian dengan minimal 50 kasus terverifikasi medis untuk menghitung sensitivitas dan spesifisitas sistem.

---

*Dokumen ini dibuat untuk keperluan pengembangan tugas akhir TBCare — PENS. Semua referensi medis berdasarkan Pedoman Nasional Penanggulangan Tuberkulosis Kementerian Kesehatan Republik Indonesia.*
