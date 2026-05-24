-- ============================================================================
-- Migration: 005_update_examinations_expert_system.sql
-- Description: Update examinations table for new weighted Forward Chaining
--              expert system (expert_system_tbc.md)
-- ============================================================================

-- Add new columns for the enhanced expert system
ALTER TABLE examinations ADD COLUMN IF NOT EXISTS conclusion TEXT DEFAULT '';
ALTER TABLE examinations ADD COLUMN IF NOT EXISTS flags JSONB DEFAULT '[]';
ALTER TABLE examinations ADD COLUMN IF NOT EXISTS is_urgent BOOLEAN DEFAULT false;

-- Update comments to reflect new system
COMMENT ON COLUMN examinations.score IS 'Weighted score (max 110) based on symptom weights';
COMMENT ON COLUMN examinations.percentage IS 'Percentage: (weighted_score/110)*100';
COMMENT ON COLUMN examinations.risk_level IS 'Risk level: sangat_rendah | rendah | sedang | tinggi | sangat_tinggi';
COMMENT ON COLUMN examinations.is_valid IS 'Whether the result passes validation rules (not just threshold)';
COMMENT ON COLUMN examinations.answers IS 'JSON map of gejala code (G01-G15) to boolean answer';
COMMENT ON COLUMN examinations.conclusion IS 'Recommendation text from the forward chaining engine';
COMMENT ON COLUMN examinations.flags IS 'JSON array of flags (e.g. urgensi_tinggi, waspadai_MDR_TB)';
COMMENT ON COLUMN examinations.is_urgent IS 'Whether urgent symptoms (batuk berdarah) were detected';
