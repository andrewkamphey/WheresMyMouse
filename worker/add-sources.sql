-- Adds source tracking to a stats database created before 30 Oct 2026. Run once:
--   npx wrangler d1 execute wheresmymouse-stats --remote --file worker/add-sources.sql
-- Safe before or after deploying the worker: until it runs, the worker keeps counting as before
-- and /stats says source stats aren't available. Tables are documented in worker/schema.sql.

ALTER TABLE seen ADD COLUMN src TEXT;

CREATE TABLE IF NOT EXISTS breakdown (
  day    TEXT NOT NULL,
  metric TEXT NOT NULL,
  dim    TEXT NOT NULL,
  value  TEXT NOT NULL,
  n      INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (day, metric, dim, value)
);
