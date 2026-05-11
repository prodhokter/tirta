# TIRTA — structure.md
# Struktur Proyek Lengkap

---

## Repository Structure (Monorepo)

```
tirta/
├── mobile/                    # Flutter app
├── backend/                   # Node.js VPS backend
├── docs/                      # Dokumentasi
│   ├── prd.md
│   ├── context.md
│   ├── plan.md
│   ├── content.md
│   ├── structure.md
│   ├── AGENTS.md
│   └── prompts/
├── supabase/
│   ├── migrations/            # SQL migration files
│   │   ├── 001_create_profiles.sql
│   │   ├── 002_create_examinations.sql
│   │   ├── 003_create_articles.sql
│   │   └── 004_create_chat.sql
│   └── seed/
│       └── seed_articles.sql
└── README.md
```

---

## Flutter App Structure (`mobile/`)

```
mobile/
├── android/
├── ios/
├── assets/
│   ├── images/
│   │   ├── logo_tirta.png
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   └── splash_bg.png
│   ├── icons/
│   │   └── app_icon.png
│   └── animations/
│       ├── loading.json          # Lottie
│       └── success.json          # Lottie
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # MaterialApp + routing
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   ├── app_routes.dart
│   │   │   └── app_assets.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── text_styles.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── date_formatter.dart
│   │   │   └── extensions.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   └── config/
│   │       └── env_config.dart   # Supabase URL, VPS URL
│   │
│   ├── features/
│   │   │
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       └── auth_remote_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart (abstract)
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in_usecase.dart
│   │   │   │       ├── sign_up_usecase.dart
│   │   │   │       ├── sign_out_usecase.dart
│   │   │   │       └── reset_password_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_screen.dart
│   │   │       │   ├── forgot_password_screen.dart
│   │   │       │   └── profile_screen.dart
│   │   │       └── widgets/
│   │   │           ├── auth_text_field.dart
│   │   │           └── social_login_button.dart
│   │   │
│   │   ├── expert_system/
│   │   │   ├── data/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── examination_repository_impl.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── examination_remote_datasource.dart
│   │   │   │   └── models/
│   │   │   │       ├── question_model.dart
│   │   │   │       └── examination_model.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── question.dart
│   │   │   │   │   └── examination_result.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── examination_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_questions_usecase.dart
│   │   │   │       ├── calculate_result_usecase.dart
│   │   │   │       └── save_examination_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── expert_system_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── expert_system_intro_screen.dart
│   │   │       │   ├── question_screen.dart
│   │   │       │   └── result_screen.dart
│   │   │       └── widgets/
│   │   │           ├── question_card.dart
│   │   │           ├── answer_button.dart
│   │   │           ├── progress_indicator.dart
│   │   │           ├── result_gauge.dart
│   │   │           ├── symptom_list.dart
│   │   │           └── medical_disclaimer_widget.dart
│   │   │
│   │   ├── chatbot/
│   │   │   ├── data/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── chat_repository_impl.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── chat_remote_datasource.dart   # VPS API
│   │   │   │   │   └── chat_local_datasource.dart    # Supabase
│   │   │   │   └── models/
│   │   │   │       └── chat_message_model.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── chat_message.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── chat_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── send_message_usecase.dart
│   │   │   │       └── get_chat_history_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── chat_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── chat_screen.dart
│   │   │       └── widgets/
│   │   │           ├── chat_bubble.dart
│   │   │           ├── chat_input_field.dart
│   │   │           ├── quick_reply_buttons.dart
│   │   │           └── typing_indicator.dart
│   │   │
│   │   ├── education/
│   │   │   ├── data/
│   │   │   │   ├── repositories/
│   │   │   │   │   └── article_repository_impl.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── article_remote_datasource.dart
│   │   │   │   └── models/
│   │   │   │       ├── article_model.dart
│   │   │   │       └── category_model.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── article.dart
│   │   │   │   │   └── category.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── article_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_articles_usecase.dart
│   │   │   │       ├── search_articles_usecase.dart
│   │   │   │       └── get_article_detail_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── education_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── education_screen.dart
│   │   │       │   └── article_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── article_card.dart
│   │   │           ├── article_card_featured.dart
│   │   │           ├── category_chip.dart
│   │   │           └── search_bar_widget.dart
│   │   │
│   │   ├── history/
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── history_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       └── get_examination_history_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── history_provider.dart
│   │   │       └── screens/
│   │   │           ├── history_screen.dart
│   │   │           └── history_detail_screen.dart
│   │   │
│   │   └── dashboard/
│   │       └── presentation/
│   │           ├── screens/
│   │           │   └── dashboard_screen.dart
│   │           └── widgets/
│   │               ├── greeting_header.dart
│   │               ├── last_examination_card.dart
│   │               ├── feature_shortcut_grid.dart
│   │               └── featured_articles_section.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── tirta_app_bar.dart
│       │   ├── tirta_button.dart
│       │   ├── tirta_text_field.dart
│       │   ├── loading_overlay.dart
│       │   ├── error_widget.dart
│       │   ├── empty_state_widget.dart
│       │   └── bottom_navbar.dart
│       └── services/
│           ├── supabase_service.dart   # Singleton Supabase client
│           └── api_service.dart        # Dio client untuk VPS
│
├── pubspec.yaml
├── .env                          # Gitignored
├── .env.example
└── analysis_options.yaml
```

---

## Backend Structure (`backend/`)

```
backend/
├── src/
│   ├── routes/
│   │   ├── index.js              # Mount semua routes
│   │   ├── chat.routes.js        # POST /api/chat
│   │   └── health.routes.js      # GET /api/health
│   │
│   ├── middleware/
│   │   ├── auth.middleware.js    # Verifikasi Supabase JWT
│   │   ├── ratelimit.middleware.js
│   │   └── cors.middleware.js
│   │
│   ├── services/
│   │   └── ai.service.js         # Panggil Anthropic/OpenAI API
│   │
│   └── utils/
│       ├── logger.js             # Winston logger
│       └── response.js           # Standard response helper
│
├── app.js                        # Express setup, middleware mount
├── server.js                     # Start server (listen port)
├── ecosystem.config.js           # PM2 config
├── .env
├── .env.example
├── package.json
└── README.md
```

---

## Supabase SQL Migrations (`supabase/migrations/`)

### 001_create_profiles.sql
```sql
-- Enable UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL DEFAULT '',
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', ''));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### 002_create_examinations.sql
```sql
CREATE TABLE examinations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 15),
  percentage FLOAT NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
  risk_level TEXT NOT NULL CHECK (risk_level IN ('rendah', 'sedang', 'tinggi')),
  is_valid BOOLEAN NOT NULL DEFAULT false,
  answers JSONB NOT NULL DEFAULT '[]',
  detected_symptoms JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE examinations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own examinations"
  ON examinations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own examinations"
  ON examinations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own examinations"
  ON examinations FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_examinations_user_id ON examinations(user_id);
CREATE INDEX idx_examinations_created_at ON examinations(created_at DESC);
```

### 003_create_articles.sql
```sql
CREATE TABLE article_categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  icon TEXT,
  color TEXT DEFAULT '#1565C0'
);

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
  is_featured BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE article_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read categories"
  ON article_categories FOR SELECT TO authenticated USING (true);

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read articles"
  ON articles FOR SELECT TO authenticated USING (true);

CREATE INDEX idx_articles_category ON articles(category_id);
CREATE INDEX idx_articles_featured ON articles(is_featured) WHERE is_featured = true;
CREATE INDEX idx_articles_published ON articles(published_at DESC);
```

### 004_create_chat.sql
```sql
CREATE TABLE chat_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT DEFAULT 'Sesi Chat Baru',
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES chat_sessions(id) ON DELETE CASCADE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own chat sessions"
  ON chat_sessions FOR ALL USING (auth.uid() = user_id);

ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can access messages in own sessions"
  ON chat_messages FOR ALL
  USING (
    session_id IN (
      SELECT id FROM chat_sessions WHERE user_id = auth.uid()
    )
  );

CREATE INDEX idx_chat_messages_session ON chat_messages(session_id, created_at);
```

---

## VPS Directory Structure

```
/home/ubuntu/tirta-backend/
├── src/
├── app.js
├── server.js
├── ecosystem.config.js
├── .env
├── node_modules/
└── logs/
    ├── app.log
    └── error.log

/etc/nginx/sites-available/
└── tirta-api              # Nginx config file

/etc/nginx/sites-enabled/
└── tirta-api -> ../sites-available/tirta-api
```

### Nginx Config (`/etc/nginx/sites-available/tirta-api`)
```nginx
server {
    listen 80;
    server_name [DOMAIN_VPS];
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name [DOMAIN_VPS];

    ssl_certificate /etc/letsencrypt/live/[DOMAIN_VPS]/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/[DOMAIN_VPS]/privkey.pem;

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
    }
}
```

### PM2 Config (`ecosystem.config.js`)
```js
module.exports = {
  apps: [{
    name: 'tirta-backend',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    log_file: './logs/app.log',
    error_file: './logs/error.log',
    time: true
  }]
};
```

---

## pubspec.yaml (Flutter Dependencies)

```yaml
name: tirta
description: Aplikasi Pendeteksi Awal TBC
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Routing
  go_router: ^13.0.0
  
  # Supabase
  supabase_flutter: ^2.3.0
  
  # HTTP
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.2
  hive_flutter: ^1.1.0
  
  # UI
  flutter_screenutil: ^5.9.0
  cached_network_image: ^3.3.1
  lottie: ^3.0.0
  flutter_svg: ^2.0.9
  google_fonts: ^6.1.0
  
  # Utils
  intl: ^0.19.0
  uuid: ^4.3.3
  equatable: ^2.0.5
  dartz: ^0.10.1     # Either type for error handling
  
  # Environment
  envied: ^0.5.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.3
  envied_generator: ^0.5.3
```

---

## package.json (Node.js Backend)

```json
{
  "name": "tirta-backend",
  "version": "1.0.0",
  "description": "TIRTA Backend API — Chatbot AI Proxy",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "pm2:start": "pm2 start ecosystem.config.js --env production",
    "pm2:restart": "pm2 restart tirta-backend",
    "pm2:logs": "pm2 logs tirta-backend"
  },
  "dependencies": {
    "express": "^4.18.2",
    "@anthropic-ai/sdk": "^0.24.0",
    "openai": "^4.47.1",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express-rate-limit": "^7.2.0",
    "helmet": "^7.1.0",
    "winston": "^3.11.0",
    "@supabase/supabase-js": "^2.42.0",
    "jsonwebtoken": "^9.0.2"
  },
  "devDependencies": {
    "nodemon": "^3.1.0"
  }
}
```
