-- Row Level Security (RLS) Policies for VoetbalWissels
-- This ensures users can only access and modify their own data

-- Enable RLS on all tables
ALTER TABLE "teams" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "players" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "games" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "game_lineups" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "lineup_positions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "substitutions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "player_availability" ENABLE ROW LEVEL SECURITY;

-- ============================================
-- TEAMS POLICIES
-- ============================================

CREATE POLICY "Coaches can view own teams"
  ON "teams" FOR SELECT
  USING (auth.uid() = coach_id);

CREATE POLICY "Coaches can create teams"
  ON "teams" FOR INSERT
  WITH CHECK (auth.uid() = coach_id);

CREATE POLICY "Coaches can update own teams"
  ON "teams" FOR UPDATE
  USING (auth.uid() = coach_id)
  WITH CHECK (auth.uid() = coach_id);

CREATE POLICY "Coaches can delete own teams"
  ON "teams" FOR DELETE
  USING (auth.uid() = coach_id);

-- ============================================
-- PLAYERS POLICIES
-- ============================================

CREATE POLICY "Coaches can view own players"
  ON "players" FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "players"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can add players"
  ON "players" FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "players"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can update own players"
  ON "players" FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "players"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "players"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can delete own players"
  ON "players" FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "players"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

-- ============================================
-- GAMES POLICIES
-- ============================================

CREATE POLICY "Coaches can view own games"
  ON "games" FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "games"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can create games"
  ON "games" FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "games"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can update own games"
  ON "games" FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "games"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "games"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can delete own games"
  ON "games" FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM "teams"
      WHERE "teams"."id" = "games"."team_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

-- ============================================
-- GAME LINEUPS POLICIES
-- ============================================

CREATE POLICY "Coaches can view own lineups"
  ON "game_lineups" FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "game_lineups"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can create lineups"
  ON "game_lineups" FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "game_lineups"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can update own lineups"
  ON "game_lineups" FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "game_lineups"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "game_lineups"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can delete own lineups"
  ON "game_lineups" FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "game_lineups"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

-- ============================================
-- LINEUP POSITIONS POLICIES
-- ============================================

CREATE POLICY "Coaches can view own lineup positions"
  ON "lineup_positions" FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM "game_lineups"
      JOIN "games" ON "games"."id" = "game_lineups"."game_id"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "game_lineups"."id" = "lineup_positions"."lineup_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can create lineup positions"
  ON "lineup_positions" FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "game_lineups"
      JOIN "games" ON "games"."id" = "game_lineups"."game_id"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "game_lineups"."id" = "lineup_positions"."lineup_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can update own lineup positions"
  ON "lineup_positions" FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM "game_lineups"
      JOIN "games" ON "games"."id" = "game_lineups"."game_id"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "game_lineups"."id" = "lineup_positions"."lineup_id"
      AND "teams"."coach_id" = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "game_lineups"
      JOIN "games" ON "games"."id" = "game_lineups"."game_id"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "game_lineups"."id" = "lineup_positions"."lineup_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can delete own lineup positions"
  ON "lineup_positions" FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM "game_lineups"
      JOIN "games" ON "games"."id" = "game_lineups"."game_id"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "game_lineups"."id" = "lineup_positions"."lineup_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

-- ============================================
-- SUBSTITUTIONS POLICIES
-- ============================================

CREATE POLICY "Coaches can view own substitutions"
  ON "substitutions" FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "substitutions"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can create substitutions"
  ON "substitutions" FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "substitutions"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can update own substitutions"
  ON "substitutions" FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "substitutions"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "substitutions"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can delete own substitutions"
  ON "substitutions" FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM "games"
      JOIN "teams" ON "teams"."id" = "games"."team_id"
      WHERE "games"."id" = "substitutions"."game_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

-- ============================================
-- PLAYER AVAILABILITY POLICIES
-- ============================================

CREATE POLICY "Coaches can view own player availability"
  ON "player_availability" FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM "players"
      JOIN "teams" ON "teams"."id" = "players"."team_id"
      WHERE "players"."id" = "player_availability"."player_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can create player availability"
  ON "player_availability" FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "players"
      JOIN "teams" ON "teams"."id" = "players"."team_id"
      WHERE "players"."id" = "player_availability"."player_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can update own player availability"
  ON "player_availability" FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM "players"
      JOIN "teams" ON "teams"."id" = "players"."team_id"
      WHERE "players"."id" = "player_availability"."player_id"
      AND "teams"."coach_id" = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM "players"
      JOIN "teams" ON "teams"."id" = "players"."team_id"
      WHERE "players"."id" = "player_availability"."player_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );

CREATE POLICY "Coaches can delete own player availability"
  ON "player_availability" FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM "players"
      JOIN "teams" ON "teams"."id" = "players"."team_id"
      WHERE "players"."id" = "player_availability"."player_id"
      AND "teams"."coach_id" = auth.uid()
    )
  );
