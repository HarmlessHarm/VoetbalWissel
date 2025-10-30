CREATE TYPE "public"."game_status" AS ENUM('planned', 'in_progress', 'completed', 'cancelled');--> statement-breakpoint
CREATE TABLE "game_lineups" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"game_id" uuid NOT NULL,
	"formation" varchar(50) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "game_lineups_game_id_unique" UNIQUE("game_id")
);
--> statement-breakpoint
CREATE TABLE "games" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid NOT NULL,
	"opponent_name" varchar(255) NOT NULL,
	"game_date" timestamp with time zone NOT NULL,
	"location" varchar(255),
	"status" "game_status" DEFAULT 'planned' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "lineup_positions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"lineup_id" uuid NOT NULL,
	"player_id" uuid NOT NULL,
	"position" varchar(50) NOT NULL,
	"position_x" numeric(5, 2),
	"position_y" numeric(5, 2),
	"is_starter" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "player_availability" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"player_id" uuid NOT NULL,
	"game_id" uuid NOT NULL,
	"is_available" boolean DEFAULT true NOT NULL,
	"reason" varchar(255),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "players" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid NOT NULL,
	"name" varchar(255) NOT NULL,
	"jersey_number" integer,
	"preferred_position" varchar(50),
	"contact_info" jsonb DEFAULT '{}'::jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "substitutions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"game_id" uuid NOT NULL,
	"player_out_id" uuid NOT NULL,
	"player_in_id" uuid NOT NULL,
	"minute" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "teams" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" varchar(255) NOT NULL,
	"coach_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "game_lineups" ADD CONSTRAINT "game_lineups_game_id_games_id_fk" FOREIGN KEY ("game_id") REFERENCES "public"."games"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "games" ADD CONSTRAINT "games_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "lineup_positions" ADD CONSTRAINT "lineup_positions_lineup_id_game_lineups_id_fk" FOREIGN KEY ("lineup_id") REFERENCES "public"."game_lineups"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "lineup_positions" ADD CONSTRAINT "lineup_positions_player_id_players_id_fk" FOREIGN KEY ("player_id") REFERENCES "public"."players"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "player_availability" ADD CONSTRAINT "player_availability_player_id_players_id_fk" FOREIGN KEY ("player_id") REFERENCES "public"."players"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "player_availability" ADD CONSTRAINT "player_availability_game_id_games_id_fk" FOREIGN KEY ("game_id") REFERENCES "public"."games"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "players" ADD CONSTRAINT "players_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "substitutions" ADD CONSTRAINT "substitutions_game_id_games_id_fk" FOREIGN KEY ("game_id") REFERENCES "public"."games"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "substitutions" ADD CONSTRAINT "substitutions_player_out_id_players_id_fk" FOREIGN KEY ("player_out_id") REFERENCES "public"."players"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "substitutions" ADD CONSTRAINT "substitutions_player_in_id_players_id_fk" FOREIGN KEY ("player_in_id") REFERENCES "public"."players"("id") ON DELETE no action ON UPDATE no action;-- Add foreign key constraint for teams.coach_id to auth.users
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
