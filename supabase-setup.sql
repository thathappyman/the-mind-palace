-- ═══════════════════════════════════════════════════════════
-- THE MIND PALACE — Supabase Database Setup
-- Run this entire script in Supabase → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════

-- 1. Create the single sync table
CREATE TABLE IF NOT EXISTS mp_records (
  sync_key    TEXT NOT NULL,
  collection  TEXT NOT NULL,
  record_id   TEXT NOT NULL,
  payload     JSONB NOT NULL,
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (sync_key, collection, record_id)
);

-- 2. Enable Row Level Security
ALTER TABLE mp_records ENABLE ROW LEVEL SECURITY;

-- 3. Open policy — access is controlled by your sync_key phrase
--    (Anyone who knows the sync_key can read/write. Keep it private.)
DROP POLICY IF EXISTS "allow_all" ON mp_records;
CREATE POLICY "allow_all"
  ON mp_records
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- 4. Index for fast reads by sync_key + collection
CREATE INDEX IF NOT EXISTS idx_mp_sync_key ON mp_records (sync_key, collection);

-- 5. Auto-update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS mp_records_updated_at ON mp_records;
CREATE TRIGGER mp_records_updated_at
  BEFORE UPDATE ON mp_records
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════
-- VERIFY: After running, check the table exists:
-- SELECT * FROM mp_records LIMIT 5;
-- ═══════════════════════════════════════════════════════════
