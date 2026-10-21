CREATE TABLE IF NOT EXISTS players (
  id TEXT PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS game_scores (
  id BIGSERIAL PRIMARY KEY,
  player_id TEXT NOT NULL REFERENCES players(id),
  game_id TEXT NOT NULL CHECK (game_id IN ('troll-run', 'stop-at-100')),
  score INTEGER NOT NULL CHECK (score >= 0),
  duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS game_scores_leaderboard_idx ON game_scores (game_id, score DESC, created_at ASC);
