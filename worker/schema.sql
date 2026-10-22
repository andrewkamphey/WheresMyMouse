-- D1 schema for wheresmymouse.com stats. Apply with:
--   npx wrangler d1 execute wheresmymouse-stats --remote --file worker/schema.sql

-- One row per UTC day and metric: 'view' (page view), 'visitor' (unique visitor that day), 'download'.
CREATE TABLE IF NOT EXISTS daily (
  day    TEXT NOT NULL,
  metric TEXT NOT NULL,
  n      INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (day, metric)
);

-- Salted hashes of IP + user agent, kept only for the current day, so visitors are counted once per day
-- without cookies or storing anything that identifies them.
CREATE TABLE IF NOT EXISTS seen (
  day TEXT NOT NULL,
  h   TEXT NOT NULL,
  PRIMARY KEY (day, h)
);
