-- D1 schema for wheresmymouse.com stats. Apply with:
--   npx wrangler d1 execute wheresmymouse-stats --remote --file worker/schema.sql
-- A database created before source tracking (30 Oct 2026) needs worker/add-sources.sql instead.

-- One row per UTC day and metric: 'view' (page view), 'visitor' (unique visitor that day), 'download'.
CREATE TABLE IF NOT EXISTS daily (
  day    TEXT NOT NULL,
  metric TEXT NOT NULL,
  n      INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (day, metric)
);

-- Salted hashes of IP + user agent, kept only for the current day, so visitors are counted once per day
-- without cookies or storing anything that identifies them. src is where that visit came from (JSON:
-- source, ref, utm, campaign, landing), so a download later that day can be credited to it.
CREATE TABLE IF NOT EXISTS seen (
  day TEXT NOT NULL,
  h   TEXT NOT NULL,
  src TEXT,
  PRIMARY KEY (day, h)
);

-- Daily totals of visitors and downloads split by where they came from and what they used. metric is
-- 'visitor' or 'download'; dim is one of source, ref (referring domain), utm ('source / medium'), campaign,
-- landing (first page), country, os, browser, source_mac (source of Mac visitors), file (downloads only).
CREATE TABLE IF NOT EXISTS breakdown (
  day    TEXT NOT NULL,
  metric TEXT NOT NULL,
  dim    TEXT NOT NULL,
  value  TEXT NOT NULL,
  n      INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (day, metric, dim, value)
);
