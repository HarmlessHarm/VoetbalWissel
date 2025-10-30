-- VoetbalWissels Initial Database Schema
-- This migration creates all the necessary tables for the football team management app

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Teams table
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  coach_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Players table
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  jersey_number INTEGER,
  preferred_position VARCHAR(50),
  contact_info JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(team_id, jersey_number)
);

-- Games table
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  opponent_name VARCHAR(255) NOT NULL,
  game_date TIMESTAMP WITH TIME ZONE NOT NULL,
  location VARCHAR(255),
  status VARCHAR(50) DEFAULT 'planned' CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Game Lineups table
CREATE TABLE game_lineups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  formation VARCHAR(50) NOT NULL, -- e.g., "4-4-2", "4-3-3"
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(game_id)
);

-- Lineup Positions table
CREATE TABLE lineup_positions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lineup_id UUID NOT NULL REFERENCES game_lineups(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  position VARCHAR(50) NOT NULL, -- e.g., "GK", "CB", "LB", "RB", "CM", "ST"
  position_x DECIMAL(5,2), -- X coordinate for visual positioning (0-100)
  position_y DECIMAL(5,2), -- Y coordinate for visual positioning (0-100)
  is_starter BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Substitutions table
CREATE TABLE substitutions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  player_out_id UUID NOT NULL REFERENCES players(id),
  player_in_id UUID NOT NULL REFERENCES players(id),
  minute INTEGER NOT NULL CHECK (minute >= 0 AND minute <= 120),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Player Availability table
CREATE TABLE player_availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  is_available BOOLEAN DEFAULT true,
  reason VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(player_id, game_id)
);

-- Create indexes for better query performance
CREATE INDEX idx_teams_coach_id ON teams(coach_id);
CREATE INDEX idx_players_team_id ON players(team_id);
CREATE INDEX idx_games_team_id ON games(team_id);
CREATE INDEX idx_games_date ON games(game_date);
CREATE INDEX idx_game_lineups_game_id ON game_lineups(game_id);
CREATE INDEX idx_lineup_positions_lineup_id ON lineup_positions(lineup_id);
CREATE INDEX idx_lineup_positions_player_id ON lineup_positions(player_id);
CREATE INDEX idx_substitutions_game_id ON substitutions(game_id);
CREATE INDEX idx_player_availability_player_id ON player_availability(player_id);
CREATE INDEX idx_player_availability_game_id ON player_availability(game_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at columns
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_games_updated_at BEFORE UPDATE ON games
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_game_lineups_updated_at BEFORE UPDATE ON game_lineups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_availability_updated_at BEFORE UPDATE ON player_availability
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add comments to tables for documentation
COMMENT ON TABLE teams IS 'Stores team information for coaches';
COMMENT ON TABLE players IS 'Stores player information for each team';
COMMENT ON TABLE games IS 'Stores game/match information';
COMMENT ON TABLE game_lineups IS 'Stores formation setup for each game';
COMMENT ON TABLE lineup_positions IS 'Stores individual player positions in a lineup';
COMMENT ON TABLE substitutions IS 'Tracks substitutions made during games';
COMMENT ON TABLE player_availability IS 'Tracks player availability for specific games';
