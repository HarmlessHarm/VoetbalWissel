# Drizzle ORM Guide for VoetbalWissels

This guide explains how to use Drizzle ORM with this project for database schema management and queries.

## What is Drizzle ORM?

Drizzle ORM is a TypeScript ORM that provides:
- Type-safe database queries
- Automatic TypeScript types from schema
- SQL-like syntax
- Zero dependencies in production
- Support for migrations

## Project Setup

### Configuration Files

- **`drizzle.config.ts`** - Drizzle configuration
- **`src/lib/db/schema.ts`** - Database schema definitions
- **`src/lib/db/index.ts`** - Database client
- **`drizzle/`** - Generated migrations directory

### Environment Variables

Add your database connection string to `.env.local`:

```env
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
```

Get your database password from:
1. Supabase Dashboard → Project Settings → Database
2. Look for "Database Password" (this is the password you set when creating the project)
3. If you forgot it, you can reset it from the Database Settings page

## Database Schema

The schema is defined in `src/lib/db/schema.ts` with the following tables:

### Tables
- **teams** - Team information
- **players** - Player roster
- **games** - Game/match information
- **game_lineups** - Formation setups
- **lineup_positions** - Player positions in formations
- **substitutions** - Player substitutions during games
- **player_availability** - Player availability per game

### Type Safety

Drizzle automatically generates TypeScript types:

```typescript
import type { Team, NewTeam, Player, NewPlayer } from '@/lib/db/schema';

// Select types (for queried data)
const team: Team = {
  id: '...',
  name: 'FC Example',
  coachId: '...',
  createdAt: new Date(),
  updatedAt: new Date(),
};

// Insert types (for creating new records)
const newTeam: NewTeam = {
  name: 'FC Example',
  coachId: '...',
};
```

## Available Scripts

### Generate Migrations

After modifying `src/lib/db/schema.ts`, generate migration files:

```bash
npm run db:generate
```

This creates SQL migration files in `drizzle/` directory.

### Push Schema to Database

Push schema changes directly to database (useful for development):

```bash
npm run db:push
```

**Warning:** This bypasses migration files. Use for prototyping only.

### Migrate Database

Run pending migrations:

```bash
npm run db:migrate
```

### Drizzle Studio

Launch the visual database browser:

```bash
npm run db:studio
```

Opens a web interface at http://localhost:4983 to browse and edit data.

## Using Drizzle in Your Code

### Basic Queries

```typescript
import { db } from '@/lib/db';
import { teams, players } from '@/lib/db/schema';
import { eq } from 'drizzle-orm';

// Select all teams
const allTeams = await db.select().from(teams);

// Select specific team
const team = await db.select().from(teams).where(eq(teams.id, teamId));

// Insert team
const newTeam = await db.insert(teams).values({
  name: 'FC Example',
  coachId: userId,
}).returning();

// Update team
await db.update(teams)
  .set({ name: 'New Name' })
  .where(eq(teams.id, teamId));

// Delete team
await db.delete(teams).where(eq(teams.id, teamId));
```

### Joins and Relations

```typescript
// Query with relations
const teamWithPlayers = await db.query.teams.findFirst({
  where: eq(teams.id, teamId),
  with: {
    players: true,
    games: true,
  },
});

// Manual join
const result = await db
  .select()
  .from(teams)
  .leftJoin(players, eq(teams.id, players.teamId))
  .where(eq(teams.coachId, userId));
```

### Complex Queries

```typescript
import { and, or, like, gte, lte } from 'drizzle-orm';

// Filter players by position
const defenders = await db
  .select()
  .from(players)
  .where(
    and(
      eq(players.teamId, teamId),
      like(players.preferredPosition, '%CB%')
    )
  );

// Find upcoming games
const upcomingGames = await db
  .select()
  .from(games)
  .where(
    and(
      eq(games.teamId, teamId),
      gte(games.gameDate, new Date()),
      eq(games.status, 'planned')
    )
  )
  .orderBy(games.gameDate);
```

### Transactions

```typescript
await db.transaction(async (tx) => {
  // Create team
  const [team] = await tx.insert(teams).values({
    name: 'FC Example',
    coachId: userId,
  }).returning();

  // Add players to team
  await tx.insert(players).values([
    { teamId: team.id, name: 'Player 1', jerseyNumber: 1 },
    { teamId: team.id, name: 'Player 2', jerseyNumber: 2 },
  ]);
});
```

## Database Migrations

### Migration Files

The project includes 3 migration files:

1. **`0000_curious_energizer.sql`** - Initial schema
   - Creates all tables
   - Defines foreign keys
   - Sets up enums

2. **`0001_add_constraints_and_indexes.sql`** - Constraints and indexes
   - Adds auth.users foreign key
   - Creates indexes for performance
   - Adds unique constraints
   - Sets up updated_at triggers

3. **`0002_enable_rls_policies.sql`** - Row Level Security
   - Enables RLS on all tables
   - Creates policies for coaches to access only their data

### Running Migrations on Supabase

#### Option 1: Using Supabase Dashboard (Recommended)

1. Go to your Supabase project
2. Navigate to **SQL Editor**
3. Click **New query**
4. Copy and paste the contents of each migration file in order:
   - First: `drizzle/0000_curious_energizer.sql`
   - Second: `drizzle/0001_add_constraints_and_indexes.sql`
   - Third: `drizzle/0002_enable_rls_policies.sql`
5. Click **Run** for each file

#### Option 2: Using Drizzle Kit

1. Make sure `DATABASE_URL` is set in `.env.local`
2. Run: `npm run db:push`

This will apply all schema changes to your database.

### Creating New Migrations

When you modify the schema:

1. **Update schema** in `src/lib/db/schema.ts`
   ```typescript
   export const players = pgTable('players', {
     // ... existing fields
     profileImage: varchar('profile_image', { length: 500 }), // new field
   });
   ```

2. **Generate migration**
   ```bash
   npm run db:generate
   ```

3. **Review** the generated SQL in `drizzle/` directory

4. **Apply migration**
   ```bash
   npm run db:push
   ```
   Or manually run it in Supabase SQL Editor

## Best Practices

### 1. Use Prepared Statements

```typescript
// Good - prepared statement
const getTeamById = db.select().from(teams).where(eq(teams.id, teamId)).prepare();
const team = await getTeamById.execute();

// Also good - Drizzle automatically prepares
const team = await db.select().from(teams).where(eq(teams.id, teamId));
```

### 2. Always Use Transactions for Related Operations

```typescript
// Create game with lineup
await db.transaction(async (tx) => {
  const [game] = await tx.insert(games).values(gameData).returning();
  const [lineup] = await tx.insert(gameLineups).values({
    gameId: game.id,
    formation: '4-4-2',
  }).returning();
  await tx.insert(lineupPositions).values(positions);
});
```

### 3. Use Relations for Complex Queries

```typescript
// Instead of manual joins
const teamData = await db.query.teams.findFirst({
  where: eq(teams.id, teamId),
  with: {
    players: {
      where: eq(players.jerseyNumber, 10),
    },
    games: {
      orderBy: (games, { desc }) => [desc(games.gameDate)],
      limit: 5,
    },
  },
});
```

### 4. Handle Errors Properly

```typescript
try {
  await db.insert(teams).values(newTeam);
} catch (error) {
  if (error.code === '23505') {
    // Unique constraint violation
    console.error('Team already exists');
  } else {
    throw error;
  }
}
```

### 5. Use Enums for Type Safety

```typescript
import { gameStatusEnum } from '@/lib/db/schema';

// TypeScript will enforce valid values
const game = await db.insert(games).values({
  // ... other fields
  status: 'planned', // ✓ Valid
  // status: 'invalid', // ✗ TypeScript error
});
```

## Server Components vs Client Components

### Server Components (Recommended)

```typescript
// app/teams/page.tsx
import { db } from '@/lib/db';
import { teams } from '@/lib/db/schema';

export default async function TeamsPage() {
  const allTeams = await db.select().from(teams);

  return <div>{/* render teams */}</div>;
}
```

### API Routes (for Client Components)

```typescript
// app/api/teams/route.ts
import { db } from '@/lib/db';
import { teams } from '@/lib/db/schema';
import { NextResponse } from 'next/server';

export async function GET() {
  const allTeams = await db.select().from(teams);
  return NextResponse.json(allTeams);
}
```

## Troubleshooting

### Migration Errors

**Error: relation "teams" already exists**
- The table was created outside Drizzle
- Solution: Drop existing tables or use `db:push` instead

**Error: permission denied for schema public**
- RLS is blocking the operation
- Solution: Check RLS policies or use service role key for admin operations

### Connection Errors

**Error: connection refused**
- Check `DATABASE_URL` in `.env.local`
- Verify Supabase project is running
- Check if database password is correct

**Error: too many connections**
- Close unused connections
- Use connection pooling
- Check for connection leaks in your code

### Type Errors

**Type 'X' is not assignable to type 'Y'**
- Regenerate types: `npm run db:generate`
- Restart TypeScript server in your IDE
- Check schema definition matches usage

## Additional Resources

- [Drizzle ORM Documentation](https://orm.drizzle.team/docs/overview)
- [Drizzle with Supabase Guide](https://orm.drizzle.team/docs/get-started-postgresql#supabase)
- [Drizzle Studio](https://orm.drizzle.team/drizzle-studio/overview)
- [SQL Operators](https://orm.drizzle.team/docs/operators)

## Examples

### Complete CRUD Example

See `src/lib/db/examples.ts` for complete examples of:
- Creating teams and players
- Querying with filters
- Updating records
- Deleting with cascades
- Using transactions
- Working with relations
