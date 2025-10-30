-- Add foreign key constraint for teams.coach_id to auth.users
ALTER TABLE "teams" ADD CONSTRAINT "teams_coach_id_auth_users_id_fk"
  FOREIGN KEY ("coach_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

-- Create indexes for better query performance
CREATE INDEX "idx_teams_coach_id" ON "teams"("coach_id");
CREATE INDEX "idx_players_team_id" ON "players"("team_id");
CREATE INDEX "idx_games_team_id" ON "games"("team_id");
CREATE INDEX "idx_games_date" ON "games"("game_date");
CREATE INDEX "idx_game_lineups_game_id" ON "game_lineups"("game_id");
CREATE INDEX "idx_lineup_positions_lineup_id" ON "lineup_positions"("lineup_id");
CREATE INDEX "idx_lineup_positions_player_id" ON "lineup_positions"("player_id");
CREATE INDEX "idx_substitutions_game_id" ON "substitutions"("game_id");
CREATE INDEX "idx_player_availability_player_id" ON "player_availability"("player_id");
CREATE INDEX "idx_player_availability_game_id" ON "player_availability"("game_id");

-- Add unique constraint for player jersey numbers within a team
ALTER TABLE "players" ADD CONSTRAINT "players_team_id_jersey_number_unique"
  UNIQUE ("team_id", "jersey_number");

-- Add unique constraint for player availability per game
ALTER TABLE "player_availability" ADD CONSTRAINT "player_availability_player_id_game_id_unique"
  UNIQUE ("player_id", "game_id");

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at columns
CREATE TRIGGER update_teams_updated_at
  BEFORE UPDATE ON "teams"
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at
  BEFORE UPDATE ON "players"
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_games_updated_at
  BEFORE UPDATE ON "games"
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_game_lineups_updated_at
  BEFORE UPDATE ON "game_lineups"
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_availability_updated_at
  BEFORE UPDATE ON "player_availability"
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
