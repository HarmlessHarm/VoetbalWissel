import { pgTable, uuid, varchar, timestamp, integer, decimal, boolean, jsonb, pgEnum } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Enums
export const gameStatusEnum = pgEnum('game_status', ['planned', 'in_progress', 'completed', 'cancelled']);

// Teams table
export const teams = pgTable('teams', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 255 }).notNull(),
  // References auth.users table managed by Supabase Auth
  // Foreign key constraint will be added in custom migration
  coachId: uuid('coach_id').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// Players table
export const players = pgTable('players', {
  id: uuid('id').primaryKey().defaultRandom(),
  teamId: uuid('team_id').notNull().references(() => teams.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 255 }).notNull(),
  jerseyNumber: integer('jersey_number'),
  preferredPosition: varchar('preferred_position', { length: 50 }),
  contactInfo: jsonb('contact_info').$type<{
    email?: string;
    phone?: string;
    emergencyContact?: string;
  }>().default({}),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// Games table
export const games = pgTable('games', {
  id: uuid('id').primaryKey().defaultRandom(),
  teamId: uuid('team_id').notNull().references(() => teams.id, { onDelete: 'cascade' }),
  opponentName: varchar('opponent_name', { length: 255 }).notNull(),
  gameDate: timestamp('game_date', { withTimezone: true }).notNull(),
  location: varchar('location', { length: 255 }),
  status: gameStatusEnum('status').default('planned').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// Game Lineups table
export const gameLineups = pgTable('game_lineups', {
  id: uuid('id').primaryKey().defaultRandom(),
  gameId: uuid('game_id').notNull().references(() => games.id, { onDelete: 'cascade' }).unique(),
  formation: varchar('formation', { length: 50 }).notNull(), // e.g., "4-4-2", "4-3-3"
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// Lineup Positions table
export const lineupPositions = pgTable('lineup_positions', {
  id: uuid('id').primaryKey().defaultRandom(),
  lineupId: uuid('lineup_id').notNull().references(() => gameLineups.id, { onDelete: 'cascade' }),
  playerId: uuid('player_id').notNull().references(() => players.id, { onDelete: 'cascade' }),
  position: varchar('position', { length: 50 }).notNull(), // e.g., "GK", "CB", "LB", "RB", "CM", "ST"
  positionX: decimal('position_x', { precision: 5, scale: 2 }), // X coordinate for visual positioning (0-100)
  positionY: decimal('position_y', { precision: 5, scale: 2 }), // Y coordinate for visual positioning (0-100)
  isStarter: boolean('is_starter').default(true).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

// Substitutions table
export const substitutions = pgTable('substitutions', {
  id: uuid('id').primaryKey().defaultRandom(),
  gameId: uuid('game_id').notNull().references(() => games.id, { onDelete: 'cascade' }),
  playerOutId: uuid('player_out_id').notNull().references(() => players.id),
  playerInId: uuid('player_in_id').notNull().references(() => players.id),
  minute: integer('minute').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

// Player Availability table
export const playerAvailability = pgTable('player_availability', {
  id: uuid('id').primaryKey().defaultRandom(),
  playerId: uuid('player_id').notNull().references(() => players.id, { onDelete: 'cascade' }),
  gameId: uuid('game_id').notNull().references(() => games.id, { onDelete: 'cascade' }),
  isAvailable: boolean('is_available').default(true).notNull(),
  reason: varchar('reason', { length: 255 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// Relations
export const teamsRelations = relations(teams, ({ many }) => ({
  players: many(players),
  games: many(games),
}));

export const playersRelations = relations(players, ({ one, many }) => ({
  team: one(teams, {
    fields: [players.teamId],
    references: [teams.id],
  }),
  lineupPositions: many(lineupPositions),
  availability: many(playerAvailability),
  substitutionsOut: many(substitutions, {
    relationName: 'playerOut',
  }),
  substitutionsIn: many(substitutions, {
    relationName: 'playerIn',
  }),
}));

export const gamesRelations = relations(games, ({ one, many }) => ({
  team: one(teams, {
    fields: [games.teamId],
    references: [teams.id],
  }),
  lineup: one(gameLineups),
  substitutions: many(substitutions),
  playerAvailability: many(playerAvailability),
}));

export const gameLineupsRelations = relations(gameLineups, ({ one, many }) => ({
  game: one(games, {
    fields: [gameLineups.gameId],
    references: [games.id],
  }),
  positions: many(lineupPositions),
}));

export const lineupPositionsRelations = relations(lineupPositions, ({ one }) => ({
  lineup: one(gameLineups, {
    fields: [lineupPositions.lineupId],
    references: [gameLineups.id],
  }),
  player: one(players, {
    fields: [lineupPositions.playerId],
    references: [players.id],
  }),
}));

export const substitutionsRelations = relations(substitutions, ({ one }) => ({
  game: one(games, {
    fields: [substitutions.gameId],
    references: [games.id],
  }),
  playerOut: one(players, {
    fields: [substitutions.playerOutId],
    references: [players.id],
    relationName: 'playerOut',
  }),
  playerIn: one(players, {
    fields: [substitutions.playerInId],
    references: [players.id],
    relationName: 'playerIn',
  }),
}));

export const playerAvailabilityRelations = relations(playerAvailability, ({ one }) => ({
  player: one(players, {
    fields: [playerAvailability.playerId],
    references: [players.id],
  }),
  game: one(games, {
    fields: [playerAvailability.gameId],
    references: [games.id],
  }),
}));

// Type exports
export type Team = typeof teams.$inferSelect;
export type NewTeam = typeof teams.$inferInsert;

export type Player = typeof players.$inferSelect;
export type NewPlayer = typeof players.$inferInsert;

export type Game = typeof games.$inferSelect;
export type NewGame = typeof games.$inferInsert;

export type GameLineup = typeof gameLineups.$inferSelect;
export type NewGameLineup = typeof gameLineups.$inferInsert;

export type LineupPosition = typeof lineupPositions.$inferSelect;
export type NewLineupPosition = typeof lineupPositions.$inferInsert;

export type Substitution = typeof substitutions.$inferSelect;
export type NewSubstitution = typeof substitutions.$inferInsert;

export type PlayerAvailability = typeof playerAvailability.$inferSelect;
export type NewPlayerAvailability = typeof playerAvailability.$inferInsert;
