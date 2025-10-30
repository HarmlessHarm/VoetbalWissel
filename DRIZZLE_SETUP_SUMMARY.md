# Drizzle ORM Setup Summary

## ✅ What Was Completed

### 1. Installation
- ✅ Installed `drizzle-orm` - TypeScript ORM for PostgreSQL
- ✅ Installed `drizzle-kit` - CLI tool for migrations
- ✅ Installed `postgres` - PostgreSQL driver
- ✅ Installed `dotenv` - Environment variable management

### 2. Configuration Files Created

#### `drizzle.config.ts`
Drizzle configuration file that defines:
- Schema location: `src/lib/db/schema.ts`
- Migrations output: `drizzle/`
- Database dialect: PostgreSQL
- Connection string from `DATABASE_URL`

#### `src/lib/db/schema.ts`
Complete TypeScript schema definitions for all 7 tables:
- `teams` - Team management
- `players` - Player roster
- `games` - Match scheduling
- `game_lineups` - Formation setups
- `lineup_positions` - Player positioning
- `substitutions` - Player swaps
- `player_availability` - Availability tracking

**Features:**
- Type-safe schema definitions
- Automatic TypeScript type inference
- Relations defined for easy querying
- Exported types for Insert and Select operations

#### `src/lib/db/index.ts`
Database client configuration:
- PostgreSQL connection setup
- Drizzle instance with schema
- Ready for import in app code

### 3. Migration Files Generated

#### `drizzle/0000_curious_energizer.sql`
Initial schema migration:
- Creates all 7 tables
- Sets up foreign key relationships
- Defines the `game_status` enum
- Uses UUID primary keys with `gen_random_uuid()`

#### `drizzle/0001_add_constraints_and_indexes.sql`
Additional constraints and performance optimizations:
- Foreign key to `auth.users` for coach authentication
- 10 indexes for query performance
- Unique constraints (jersey numbers, player availability)
- `updated_at` trigger function
- Triggers for automatic timestamp updates

#### `drizzle/0002_enable_rls_policies.sql`
Row Level Security policies:
- Enables RLS on all tables
- Creates policies for all CRUD operations
- Ensures coaches can only access their own data
- Implements multi-level security checks

### 4. Environment Configuration

Updated `.env.local` and `.env.example`:
```env
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
```

### 5. NPM Scripts Added

```json
{
  "db:generate": "drizzle-kit generate",  // Generate migrations
  "db:migrate": "drizzle-kit migrate",    // Run migrations
  "db:push": "drizzle-kit push",          // Push schema to DB
  "db:studio": "drizzle-kit studio"       // Visual database browser
}
```

### 6. Documentation Created

#### `DRIZZLE_GUIDE.md` (Comprehensive Guide)
Complete documentation covering:
- What Drizzle ORM is and why we use it
- Configuration overview
- Database schema explanation
- Type safety examples
- Available scripts usage
- Code examples for:
  - Basic queries (SELECT, INSERT, UPDATE, DELETE)
  - Joins and relations
  - Complex queries with filters
  - Transactions
- Migration workflow
- Best practices
- Server Components vs API Routes
- Troubleshooting guide
- Additional resources

#### Updated `README.md`
- Added Drizzle ORM to tech stack
- Added database setup step
- Added database scripts section
- Added links to Drizzle documentation

## 🎯 How to Use

### Initial Setup

1. **Add Database Password to Environment**
   ```bash
   # Edit .env.local
   DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@db.xfobaqjyksggqiopytyd.supabase.co:5432/postgres
   ```

2. **Push Schema to Database**
   ```bash
   npm run db:push
   ```

   This will:
   - Create all tables
   - Add foreign keys and constraints
   - Create indexes
   - Enable RLS policies

### Development Workflow

1. **Modify Schema**
   Edit `src/lib/db/schema.ts`

2. **Generate Migration**
   ```bash
   npm run db:generate
   ```

3. **Review Generated SQL**
   Check files in `drizzle/` directory

4. **Apply Migration**
   ```bash
   npm run db:push
   ```

### Using in Code

```typescript
import { db } from '@/lib/db';
import { teams, players } from '@/lib/db/schema';
import { eq } from 'drizzle-orm';

// Select all teams for current coach
const myTeams = await db.select()
  .from(teams)
  .where(eq(teams.coachId, userId));

// Create new player
const [newPlayer] = await db.insert(players)
  .values({
    teamId: teamId,
    name: 'John Doe',
    jerseyNumber: 10,
    preferredPosition: 'ST',
  })
  .returning();

// Query with relations
const teamWithPlayers = await db.query.teams.findFirst({
  where: eq(teams.id, teamId),
  with: {
    players: true,
    games: true,
  },
});
```

## 📊 Database Schema Overview

```
┌─────────────────────────────────────────────┐
│                  auth.users                 │
│              (Supabase Auth)                │
└────────────────┬────────────────────────────┘
                 │
                 │ coach_id
                 ▼
         ┌───────────────┐
         │     teams     │
         └───────┬───────┘
                 │
         ┌───────┴────────────┐
         │                    │
         ▼                    ▼
   ┌─────────┐          ┌─────────┐
   │ players │          │  games  │
   └────┬────┘          └────┬────┘
        │                    │
        │              ┌─────┴─────┐
        │              │           │
        │              ▼           ▼
        │      ┌──────────────┐ ┌────────────────┐
        │      │ game_lineups │ │ substitutions  │
        │      └──────┬───────┘ └────────────────┘
        │             │
        │             ▼
        │     ┌──────────────────┐
        └────►│ lineup_positions │
              └──────────────────┘

        ┌────────────────────┐
        │ player_availability│
        └────────────────────┘
```

## 🔒 Security Features

### Row Level Security (RLS)
All tables have RLS enabled to ensure:
- Coaches can only view their own teams
- Coaches can only manage players in their teams
- Coaches can only access games for their teams
- All related data (lineups, substitutions, etc.) follows the same security model

### Type Safety
- TypeScript types automatically generated from schema
- Prevents invalid data insertion
- Autocomplete for table columns
- Compile-time error checking

## 🚀 Next Steps

1. **Set up your database** (follow steps above)
2. **Test the connection** with Drizzle Studio:
   ```bash
   npm run db:studio
   ```
3. **Start developing** Phase 2 features (Player Management)
4. **Use the Drizzle Guide** for reference when writing queries

## 📚 Additional Resources

- **DRIZZLE_GUIDE.md** - Complete usage guide
- **src/lib/db/schema.ts** - Schema definitions
- **drizzle/** - Migration files
- [Drizzle ORM Docs](https://orm.drizzle.team/)

## ⚠️ Important Notes

1. **Don't commit `.env.local`** - It's in `.gitignore`
2. **Run migrations in order** - The numbered files must run sequentially
3. **Review generated migrations** - Always check SQL before applying
4. **Use transactions** - For related operations that should succeed or fail together
5. **Leverage type safety** - Let TypeScript catch errors at compile time

---

**Status:** ✅ Complete and ready to use!
