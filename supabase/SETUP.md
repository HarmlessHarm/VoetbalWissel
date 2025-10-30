# Supabase Setup Guide

This guide will walk you through setting up your Supabase database for the VoetbalWissels app.

> **Note:** This project uses **Drizzle ORM** for database management. For detailed information about Drizzle, see [DRIZZLE_GUIDE.md](../DRIZZLE_GUIDE.md).

## Step 1: Create a Supabase Project

1. Go to [Supabase](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Fill in the details:
   - **Name**: VoetbalWissels (or your preferred name)
   - **Database Password**: Choose a strong password (save this!)
   - **Region**: Choose the closest region to your users
5. Click "Create new project"
6. Wait for the project to finish setting up (2-3 minutes)

## Step 2: Get Your API Credentials

1. Go to **Project Settings → API**
2. Copy the following values:
   - **Project URL** (under "Project URL")
   - **anon/public key** (under "Project API keys")

## Step 3: Get Your Database Password

1. Go to **Project Settings → Database**
2. Find your database password (this is the password you set when creating the project)
3. If you forgot it, you can reset it from this page

## Step 4: Configure Environment Variables

In your project root, create a `.env.local` file:

```bash
cp .env.example .env.local
```

Edit `.env.local` and add your credentials:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# Database URL for Drizzle ORM
DATABASE_URL=postgresql://postgres:your-db-password@db.your-project-ref.supabase.co:5432/postgres
```

**Important:**
- Replace `your-project-ref` with your actual Supabase project reference
- Replace `your-anon-key` with the anon key from Step 2
- Replace `your-db-password` with the database password from Step 3

## Step 5: Run Database Migrations

We use **Drizzle ORM** to manage database schema and migrations. Simply run:

```bash
npm run db:push
```

This single command will:
- ✅ Create all 7 tables
- ✅ Set up foreign key relationships
- ✅ Add indexes for performance
- ✅ Enable Row Level Security (RLS)
- ✅ Create RLS policies
- ✅ Add triggers for automatic timestamps

### Alternative: Manual Migration (Advanced)

If you prefer to run SQL manually:

1. Go to Supabase Dashboard → **SQL Editor**
2. Click **New query**
3. Copy and paste the contents from these files in order:
   - `drizzle/0000_curious_energizer.sql`
   - `drizzle/0001_add_constraints_and_indexes.sql`
   - `drizzle/0002_enable_rls_policies.sql`
4. Click **Run** after each one

## Step 6: Verify Setup

### Option A: Using Drizzle Studio

```bash
npm run db:studio
```

This opens a visual database browser at http://localhost:4983

### Option B: Using Supabase Dashboard

1. Go to **Table Editor** in Supabase Dashboard
2. You should see these tables:
   - `teams`
   - `players`
   - `games`
   - `game_lineups`
   - `lineup_positions`
   - `substitutions`
   - `player_availability`
3. Click on any table to view its structure
4. Check that RLS (Row Level Security) is enabled (shield icon should be green)

## Step 7: Enable Email Authentication

1. In your Supabase project, go to **Authentication → Providers**
2. Make sure **Email** is enabled (it should be by default)
3. Configure email templates if desired (Authentication → Email Templates)

### Optional: Configure Email Settings

By default, Supabase uses their SMTP server for emails. For production:

1. Go to **Authentication → Settings**
2. Scroll to "SMTP Settings"
3. Configure your own SMTP server (recommended for production)

## Database Schema Overview

The database consists of 7 main tables:

### Core Tables
- **teams** - Stores team information, linked to coaches (auth users)
- **players** - Stores player details for each team
- **games** - Stores match information

### Game Management
- **game_lineups** - Stores formation setup for each game
- **lineup_positions** - Individual player positions within a lineup
- **substitutions** - Tracks player substitutions during games
- **player_availability** - Tracks which players are available for each game

### Security

All tables have Row Level Security (RLS) enabled:
- Coaches can only see and modify their own teams and related data
- All operations are authenticated via Supabase Auth
- Policies ensure data isolation between different coaches

## Troubleshooting

### Connection Issues

**Check that:**
- Your `.env.local` file has the correct credentials
- The file is in the project root directory
- You've restarted your Next.js dev server after adding the env vars

### Build Errors

**"DATABASE_URL is not defined"**
- Make sure `DATABASE_URL` is set in `.env.local`
- Verify the format matches: `postgresql://postgres:PASSWORD@db.PROJECT_REF.supabase.co:5432/postgres`

### Migration Errors

**"relation already exists"**
- Tables are already created
- Run `npm run db:push` again (it will skip existing tables)

**"permission denied"**
- Verify your database password is correct
- Check that you're using the connection string from Supabase settings

### RLS Policy Errors

**Data not showing up:**
- Make sure you're logged in with the same user that created the team
- Check RLS policies in Supabase Dashboard → Authentication → Policies

## Next Steps

After completing this setup:

1. ✅ Start your development server: `npm run dev`
2. ✅ Test authentication by creating an account
3. ✅ The app will now be able to connect to your Supabase database
4. ✅ Continue with Phase 2 development (Player Management)

## Useful Links

- [Supabase Documentation](https://supabase.com/docs)
- [Drizzle ORM Documentation](https://orm.drizzle.team)
- [DRIZZLE_GUIDE.md](../DRIZZLE_GUIDE.md) - Complete Drizzle usage guide
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Auth](https://supabase.com/docs/guides/auth)

## Database Management

### Viewing Your Data
```bash
npm run db:studio
```

### Making Schema Changes

1. Edit `src/lib/db/schema.ts`
2. Generate migration: `npm run db:generate`
3. Review the SQL in `drizzle/`
4. Apply changes: `npm run db:push`

See [DRIZZLE_GUIDE.md](../DRIZZLE_GUIDE.md) for complete documentation.
