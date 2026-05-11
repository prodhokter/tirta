-- ============================================================================
-- Migration: 002_create_examinations.sql
-- Description: Create examinations table for expert system results with RLS
-- ============================================================================

-- Create examinations table
CREATE TABLE IF NOT EXISTS examinations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  score INTEGER NOT NULL,              -- jumlah jawaban "Ya"
  percentage FLOAT NOT NULL,           -- (score/15)*100
  risk_level TEXT NOT NULL,            -- 'rendah' | 'sedang' | 'tinggi'
  is_valid BOOLEAN NOT NULL,           -- score >= 5
  answers JSONB NOT NULL,              -- array 15 jawaban {q_id, answer}
  detected_symptoms JSONB,             -- gejala yang terdeteksi
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE examinations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own examinations
CREATE POLICY "Users can view own examinations"
  ON examinations
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own examinations
CREATE POLICY "Users can insert own examinations"
  ON examinations
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own examinations
CREATE POLICY "Users can delete own examinations"
  ON examinations
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- Indexes for performance
-- ============================================================================

-- Index on user_id for fast user-scoped queries
CREATE INDEX IF NOT EXISTS idx_examinations_user_id ON examinations(user_id);

-- Index on created_at for sorting by date (newest first)
CREATE INDEX IF NOT EXISTS idx_examinations_created_at ON examinations(created_at DESC);

-- Composite index for user's examinations sorted by date
CREATE INDEX IF NOT EXISTS idx_examinations_user_created ON examinations(user_id, created_at DESC);

-- ============================================================================
-- Comments
-- ============================================================================

COMMENT ON TABLE examinations IS 'Stores expert system (Forward Chaining) examination results for each user';
COMMENT ON COLUMN examinations.score IS 'Number of "Ya" answers out of 15 questions';
COMMENT ON COLUMN examinations.percentage IS 'Percentage score: (score/15)*100';
COMMENT ON COLUMN examinations.risk_level IS 'Risk category: rendah (0-29%), sedang (30-59%), tinggi (60-100%)';
COMMENT ON COLUMN examinations.is_valid IS 'Whether the result is valid (score >= 5)';
COMMENT ON COLUMN examinations.answers IS 'JSON array of all 15 answers with question IDs';
COMMENT ON COLUMN examinations.detected_symptoms IS 'JSON array of detected symptom descriptions';
