# Manual Database Migration Guide

If `npm run db:push` fails due to network issues (IPv6, timeouts, etc.), you can manually run the migrations using the Supabase SQL Editor.

## Steps

### 1. Open Supabase SQL Editor

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: **VoetbalWissels** (or your project name)
3. Navigate to **SQL Editor** in the left sidebar
4. Click **New query**

### 2. Run Migrations in Order

Copy and paste each migration file **one at a time** and click **Run** after each one.

---

## Migration 1: Initial Schema

**File:** `drizzle/0000_curious_energizer.sql`

```sql
-- Copy the ENTIRE contents of drizzle/0000_curious_energizer.sql
```

To copy the file:
```bash
cat drizzle/0000_curious_energizer.sql
```

Or open it in your code editor and copy all contents.

---

## Migration 2: Constraints and Indexes

**File:** `drizzle/0001_add_constraints_and_indexes.sql`

```sql
-- Copy the ENTIRE contents of drizzle/0001_add_constraints_and_indexes.sql
```

To copy the file:
```bash
cat drizzle/0001_add_constraints_and_indexes.sql
```

---

## Migration 3: Row Level Security

**File:** `drizzle/0002_enable_rls_policies.sql`

```sql
-- Copy the ENTIRE contents of drizzle/0002_enable_rls_policies.sql
```

To copy the file:
```bash
cat drizzle/0002_enable_rls_policies.sql
```

---

## 3. Verify Setup

After running all three migrations, verify in Supabase:

1. Go to **Table Editor**
2. You should see these tables:
   - ✅ teams
   - ✅ players
   - ✅ games
   - ✅ game_lineups
   - ✅ lineup_positions
   - ✅ substitutions
   - ✅ player_availability

3. Click on any table and verify:
   - RLS (Row Level Security) is enabled (green shield icon)
   - Columns match the schema
   - Indexes are created

---

## Alternative: Combined Migration Script

Here's all three migrations combined into one script for convenience:

### Combined Migration (Run in Supabase SQL Editor)

```bash
# Generate a combined migration file
cat drizzle/0000_curious_energizer.sql \
    drizzle/0001_add_constraints_and_indexes.sql \
    drizzle/0002_enable_rls_policies.sql \
    > combined_migration.sql
```

Then copy `combined_migration.sql` into Supabase SQL Editor and run it once.

---

## Troubleshooting

### "relation already exists" error
- Some tables were already created
- Solution: Skip to the next migration or manually drop existing tables first

### "permission denied" error
- RLS might be blocking the operation
- Solution: Make sure you're running the query as the postgres user (should be default in SQL Editor)

### Foreign key errors
- Migration order is important
- Solution: Run migrations in the exact order: 0000 → 0001 → 0002

---

## After Migration

Once migrations are complete:

1. Your database is fully set up with all tables, indexes, and RLS policies
2. You can start using Drizzle ORM in your application code
3. For future schema changes, use `npm run db:generate` and manually run the new migration files

## Network Issues (IPv6/Timeout)

If you continue to have issues with `npm run db:push`, this is likely due to:

- **IPv6 networking issues** (common in WSL2)
- **Firewall blocking direct database connections**
- **Network timeouts**

**Solution:** Always use the Supabase SQL Editor for migrations. You can still use Drizzle ORM in your application code - only the `db:push` command needs network access.

Your application will connect fine using the Supabase client library (which goes through the Supabase API, not direct database connection).
