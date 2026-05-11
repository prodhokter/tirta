-- ============================================================================
-- Migration: 003_create_articles.sql
-- Description: Create article_categories and articles tables with RLS
-- ============================================================================

-- ============================================================================
-- Article Categories
-- ============================================================================

CREATE TABLE IF NOT EXISTS article_categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  icon TEXT,
  color TEXT
);

-- Enable RLS (read-only for authenticated users)
ALTER TABLE article_categories ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view categories
CREATE POLICY "Authenticated users can view categories"
  ON article_categories
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Anon users can view categories (for browse-before-login)
CREATE POLICY "Anon users can view categories"
  ON article_categories
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Service role full access (for seeding)
CREATE POLICY "Service role full access on categories"
  ON article_categories
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- Articles
-- ============================================================================

CREATE TABLE IF NOT EXISTS articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  excerpt TEXT,
  content TEXT NOT NULL,
  image_url TEXT,
  category_id INTEGER REFERENCES article_categories(id) ON DELETE SET NULL,
  read_time_minutes INTEGER DEFAULT 3,
  author TEXT DEFAULT 'Tim TIRTA',
  is_featured BOOLEAN DEFAULT FALSE,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view articles
CREATE POLICY "Authenticated users can view articles"
  ON articles
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Anon users can view articles (for browse-before-login)
CREATE POLICY "Anon users can view articles"
  ON articles
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Service role full access (for seeding and management)
CREATE POLICY "Service role full access on articles"
  ON articles
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- Indexes for performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_articles_category_id ON articles(category_id);
CREATE INDEX IF NOT EXISTS idx_articles_featured ON articles(is_featured) WHERE is_featured = TRUE;
CREATE INDEX IF NOT EXISTS idx_articles_published_at ON articles(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_articles_slug ON articles(slug);

-- ============================================================================
-- Comments
-- ============================================================================

COMMENT ON TABLE article_categories IS 'Categories for educational articles about TB';
COMMENT ON TABLE articles IS 'Educational articles about tuberculosis (TB) for the TIRTA app';
COMMENT ON COLUMN articles.is_featured IS 'Whether this article is featured on the dashboard';
COMMENT ON COLUMN articles.read_time_minutes IS 'Estimated reading time in minutes';
