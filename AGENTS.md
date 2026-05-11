# TIRTA — AGENTS.md
# Panduan untuk AI Coding Agent

Dokumen ini adalah panduan utama untuk AI agent yang membantu pengembangan aplikasi TIRTA.  
**Baca SELURUH dokumen ini sebelum mulai mengerjakan apapun.**

---

## 0. Perintah Pertama (SELALU LAKUKAN INI)

Sebelum mengerjakan task apapun:
1. Baca `context.md` — memahami stack, arsitektur, dan state proyek
2. Baca `prd.md` — memahami requirement fitur yang dikerjakan
3. Baca `structure.md` — memahami di mana file harus dibuat/diubah
4. Cek `plan.md` — pahami apa yang sudah selesai dan apa yang perlu dikerjakan

---

## 1. Identitas Proyek

- **Aplikasi:** TIRTA — Pendeteksi Awal TBC
- **Stack:** Flutter + Supabase + Node.js (VPS)
- **Semester:** Tugas kuliah WPPA PENS
- **Deadline:** 7 Juni 2026

---

## 2. Cara AI Agent Beroperasi

### Mode Operasi

**MODE A: Tulis Kode Baru**
- Buat file di lokasi yang sesuai dengan `structure.md`
- Ikuti konvensi naming dan pattern yang ada
- Selalu sertakan komentar untuk logika yang kompleks

**MODE B: Debug & Fix**
- Identifikasi root cause sebelum fix
- Jelaskan apa yang salah dan mengapa
- Berikan fix minimal (jangan ubah hal yang tidak perlu)

**MODE C: Review**
- Periksa keamanan (API key exposure, RLS, validasi input)
- Periksa kesesuaian dengan `prd.md`
- Berikan feedback konkret

---

## 3. Aturan Wajib (JANGAN DILANGGAR)

### Keamanan
- **TIDAK BOLEH** meletakkan API key (AI API, Supabase service key) di dalam kode Flutter
- **TIDAK BOLEH** skip RLS (Row Level Security) di Supabase
- **TIDAK BOLEH** mengekspos endpoint backend tanpa autentikasi (kecuali `/api/health`)
- **WAJIB** validasi semua input user sebelum dikirim ke backend/database

### Medis & Etika
- **WAJIB** menyertakan disclaimer medis di semua halaman hasil pemeriksaan
- **TIDAK BOLEH** mengklaim bahwa TIRTA adalah alat diagnosis medis resmi
- Disclaimer standar:
  ```
  "TIRTA adalah alat bantu skrining awal dan BUKAN pengganti diagnosis medis. 
  Hasil ini bersifat indikatif. Konsultasikan dengan tenaga kesehatan."
  ```

### Code Quality
- **WAJIB** handle error state di setiap widget (empty state, error state, loading state)
- **WAJIB** gunakan `try-catch` untuk semua network call
- **TIDAK BOLEH** `print()` di production — gunakan logger yang proper
- **WAJIB** semua teks UI dalam Bahasa Indonesia

### Git
- Gunakan branch `feature/[nama-fitur]` untuk fitur baru
- Commit message format: `feat(scope): deskripsi singkat`
- Contoh: `feat(auth): implement Google OAuth login`

---

## 4. Panduan Per Fitur

### 4.1 Autentikasi (Supabase Auth)

**File utama:**
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`

**Implementasi:**
```dart
// Gunakan Supabase Auth client
final supabase = Supabase.instance.client;

// Register
await supabase.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': fullName},
);

// Login
await supabase.auth.signInWithPassword(email: email, password: password);

// Google OAuth
await supabase.auth.signInWithOAuth(OAuthProvider.google);

// Logout
await supabase.auth.signOut();

// Stream auth state
supabase.auth.onAuthStateChange.listen((data) {
  final AuthChangeEvent event = data.event;
  final Session? session = data.session;
});
```

**Auth Guard dengan GoRouter:**
```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authStateProvider).value != null;
  final isGoingToLogin = state.matchedLocation == AppRoutes.login;
  if (!isLoggedIn && !isGoingToLogin) return AppRoutes.login;
  if (isLoggedIn && isGoingToLogin) return AppRoutes.dashboard;
  return null;
},
```

---

### 4.2 Sistem Pakar (Forward Chaining)

**File utama:**
- `lib/features/expert_system/domain/entities/question.dart`
- `lib/features/expert_system/data/models/examination_model.dart`
- `lib/features/expert_system/presentation/providers/expert_system_provider.dart`
- `lib/features/expert_system/presentation/screens/question_screen.dart`
- `lib/features/expert_system/presentation/screens/result_screen.dart`

**Model Pertanyaan:**
```dart
class Question {
  final int id;
  final String text;
  final String category; // 'pernapasan' | 'sistemik' | 'risiko' | 'riwayat'
  
  const Question({required this.id, required this.text, required this.category});
}
```

**Implementasi Forward Chaining:**
```dart
class ForwardChainingEngine {
  static ExaminationResult analyze(List<bool> answers) {
    assert(answers.length == 15, 'Harus tepat 15 jawaban');
    
    final score = answers.where((a) => a).length;
    final percentage = (score / 15) * 100;
    final isValid = score >= 5;
    
    // Klasifikasi risiko
    String riskLevel;
    if (percentage < 30) {
      riskLevel = 'rendah';
    } else if (percentage < 60) {
      riskLevel = 'sedang';
    } else {
      riskLevel = 'tinggi';
    }
    
    // Forward Chaining Rules
    final hasMainSymptom = answers[0]; // Batuk >2 minggu
    final systemicCount = [answers[4], answers[5], answers[6], answers[7], answers[8]]
        .where((a) => a).length;
    final hasRiskFactor = [answers[9], answers[10], answers[11], answers[12]]
        .any((a) => a);
    
    // Rule evaluation
    String conclusion;
    if (hasMainSymptom && systemicCount >= 3 && hasRiskFactor) {
      conclusion = 'TERINDIKASI TBC - Segera konsultasi dokter';
    } else if (hasMainSymptom && systemicCount >= 2) {
      conclusion = 'SUSPEK TBC - Dianjurkan periksa ke puskesmas';
    } else if (percentage >= 30) {
      conclusion = 'RISIKO SEDANG - Pantau gejala dan konsultasi jika memburuk';
    } else {
      conclusion = 'RISIKO RENDAH - Tetap jaga pola hidup sehat';
    }
    
    // Gejala yang terdeteksi
    final detectedSymptoms = <String>[];
    final questionTexts = ExpertSystemData.questions.map((q) => q.text).toList();
    for (int i = 0; i < answers.length; i++) {
      if (answers[i]) detectedSymptoms.add(questionTexts[i]);
    }
    
    return ExaminationResult(
      score: score,
      percentage: percentage,
      riskLevel: riskLevel,
      isValid: isValid,
      conclusion: conclusion,
      detectedSymptoms: detectedSymptoms,
    );
  }
}
```

**Simpan ke Supabase:**
```dart
await supabase.from('examinations').insert({
  'user_id': supabase.auth.currentUser!.id,
  'score': result.score,
  'percentage': result.percentage,
  'risk_level': result.riskLevel,
  'is_valid': result.isValid,
  'answers': answers.map((a) => {'answer': a}).toList(),
  'detected_symptoms': result.detectedSymptoms,
});
```

---

### 4.3 Chatbot AI (via VPS)

**File utama:**
- `lib/features/chatbot/data/datasources/chat_remote_datasource.dart`
- `lib/features/chatbot/presentation/screens/chat_screen.dart`
- `backend/src/routes/chat.routes.js`
- `backend/src/services/ai.service.js`

**Flutter → VPS (Dio):**
```dart
Future<String> sendMessage(List<Map<String, String>> messages) async {
  final response = await dio.post(
    '$vpsBaseUrl/api/chat',
    data: {
      'messages': messages,
    },
    options: Options(
      headers: {
        'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
        'Content-Type': 'application/json',
      },
    ),
  );
  return response.data['data']['response'] as String;
}
```

**VPS Backend (chat.routes.js):**
```javascript
router.post('/chat', authMiddleware, rateLimitMiddleware, async (req, res) => {
  try {
    const { messages } = req.body;
    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ success: false, error: 'Invalid messages format' });
    }
    
    const response = await aiService.chat(messages);
    res.json({ success: true, data: { response } });
  } catch (error) {
    logger.error('Chat error:', error);
    res.status(500).json({ success: false, error: 'AI service unavailable' });
  }
});
```

**VPS AI Service (ai.service.js):**
```javascript
const Anthropic = require('@anthropic-ai/sdk');
const client = new Anthropic({ apiKey: process.env.AI_API_KEY });

const SYSTEM_PROMPT = `Kamu adalah TIRTA Assistant, asisten kesehatan virtual 
yang HANYA membahas topik seputar Tuberkulosis (TBC) dan kesehatan paru-paru.
Gunakan Bahasa Indonesia yang ramah dan mudah dipahami. 
Maksimal 200 kata per respons. Selalu tambahkan disclaimer bahwa kamu bukan dokter.`;

async function chat(messages) {
  const response = await client.messages.create({
    model: process.env.AI_MODEL || 'claude-sonnet-4-20250514',
    max_tokens: 500,
    system: SYSTEM_PROMPT,
    messages: messages,
  });
  return response.content[0].text;
}

module.exports = { chat };
```

---

### 4.4 Edukasi (Artikel)

**File utama:**
- `lib/features/education/data/datasources/article_remote_datasource.dart`
- `lib/features/education/presentation/screens/education_screen.dart`

**Ambil artikel dari Supabase:**
```dart
// Semua artikel
Future<List<Article>> getArticles({String? categorySlug, String? search}) async {
  var query = supabase
    .from('articles')
    .select('*, article_categories(name, slug, color, icon)')
    .order('published_at', ascending: false);
  
  if (categorySlug != null && categorySlug != 'semua') {
    query = query.eq('article_categories.slug', categorySlug);
  }
  
  if (search != null && search.isNotEmpty) {
    query = query.ilike('title', '%$search%');
  }
  
  final data = await query;
  return data.map((json) => Article.fromJson(json)).toList();
}

// Featured articles untuk dashboard
Future<List<Article>> getFeaturedArticles() async {
  final data = await supabase
    .from('articles')
    .select('*, article_categories(name, slug, color)')
    .eq('is_featured', true)
    .order('published_at', ascending: false)
    .limit(2);
  return data.map((json) => Article.fromJson(json)).toList();
}
```

---

## 5. Error Handling Pattern

Selalu gunakan pattern ini untuk operasi async:

```dart
// Dalam Notifier/Provider
Future<void> doSomething() async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final result = await repository.doSomething();
    state = state.copyWith(isLoading: false, data: result);
  } on PostgrestException catch (e) {
    state = state.copyWith(isLoading: false, error: 'Database error: ${e.message}');
  } on DioException catch (e) {
    state = state.copyWith(isLoading: false, error: 'Koneksi gagal. Cek internet kamu.');
  } catch (e) {
    state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan. Coba lagi.');
  }
}
```

---

## 6. Testing Checklist (Sebelum Submit)

Setiap fitur HARUS lolos checklist ini:

### Auth
- [ ] Register dengan email valid → sukses + email verifikasi
- [ ] Register dengan email duplikat → error message yang jelas
- [ ] Login dengan kredensial salah → error message yang jelas
- [ ] Login sukses → redirect ke dashboard
- [ ] Logout → redirect ke login, data lokal dibersihkan

### Sistem Pakar
- [ ] Semua 15 pertanyaan tampil berurutan
- [ ] Progress bar update setiap pertanyaan
- [ ] Bisa kembali ke pertanyaan sebelumnya
- [ ] Semua Ya → 100%, Risiko Tinggi, Valid
- [ ] Semua Tidak → 0%, Risiko Rendah, Tidak Valid
- [ ] 5 Ya → Valid, persentase sesuai
- [ ] Hasil tersimpan ke Supabase
- [ ] Disclaimer medis tampil

### Chatbot
- [ ] Kirim pesan → respons AI muncul
- [ ] Pertanyaan off-topic → chatbot menolak
- [ ] Saat offline → error message yang jelas (bukan crash)
- [ ] Riwayat chat tersimpan

### Edukasi
- [ ] Daftar artikel tampil
- [ ] Filter kategori berfungsi
- [ ] Search berfungsi
- [ ] Detail artikel tampil dengan konten lengkap

---

## 7. VPS Setup Commands

```bash
# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2
npm install -g pm2
pm2 startup systemd

# Clone dan setup backend
cd /home/ubuntu
git clone [REPO_URL] tirta-backend
cd tirta-backend/backend
npm install
cp .env.example .env
nano .env   # Isi semua env variable

# Start dengan PM2
pm2 start ecosystem.config.js --env production
pm2 save

# Setup Nginx
sudo apt install nginx certbot python3-certbot-nginx
sudo nano /etc/nginx/sites-available/tirta-api
# (paste config dari structure.md)
sudo ln -s /etc/nginx/sites-available/tirta-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# SSL dengan Certbot
sudo certbot --nginx -d [DOMAIN_VPS]
```

---

## 8. Debugging Tips

### Flutter
- Gunakan `flutter run --debug` dan pantau log di terminal
- Untuk Supabase error: cek `PostgrestException.message` dan `PostgrestException.code`
- Untuk network: tambahkan interceptor Dio untuk log request/response

### Backend
```bash
pm2 logs tirta-backend --lines 100   # Lihat log terakhir
pm2 monit                             # Monitor real-time
curl https://[DOMAIN_VPS]/api/health  # Test endpoint
```

### Supabase
- Buka Supabase Dashboard → SQL Editor untuk test query langsung
- Pastikan RLS policy tidak memblokir query yang seharusnya berhasil
- Gunakan Supabase Dashboard → Logs untuk debug

---

## 9. Setelah Selesai Mengerjakan Task

Selalu lakukan ini:
1. Jalankan `flutter analyze` — pastikan tidak ada warning/error
2. Test di emulator Android
3. Commit dengan format yang benar
4. Update status di `plan.md` (centang yang sudah selesai)
5. Dokumentasikan perubahan database di `structure.md` jika ada
