# Supabase Setup Guide

This guide will walk you through setting up your Supabase database for the VoetbalWissels app.

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

1. Go to Project Settings > API
2. Copy the following values (you'll need them for `.env.local`):
   - **Project URL** (under "Project URL")
   - **anon/public key** (under "Project API keys")

## Step 3: Configure Environment Variables

In your project root, create a `.env.local` file:

```bash
NEXT_PUBLIC_SUPABASE_URL=your-project-url-here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

Replace the placeholder values with the credentials you copied in Step 2.

## Step 4: Run Database Migrations

You have two options to set up your database schema:

### Option A: Using Supabase Dashboard (Recommended for beginners)

1. In your Supabase project, go to the **SQL Editor**
2. Click "New query"
3. Open `supabase/migrations/20251030_initial_schema.sql` from this repository
4. Copy the entire contents and paste into the SQL Editor
5. Click "Run" to execute the migration
6. Repeat steps 2-5 for `supabase/migrations/20251030_rls_policies.sql`

### Option B: Using Supabase CLI (Recommended for developers)

1. Install the Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Link your project:
   ```bash
   supabase link --project-ref your-project-ref
   ```
   (Find your project ref in Project Settings > General)

3. Push migrations:
   ```bash
   supabase db push
   ```

## Step 5: Enable Email Authentication

1. In your Supabase project, go to **Authentication** > **Providers**
2. Make sure **Email** is enabled (it should be by default)
3. Configure email templates if desired (Authentication > Email Templates)

### Optional: Configure Email Settings

By default, Supabase uses their SMTP server for emails. For production:

1. Go to **Authentication** > **Settings**
2. Scroll to "SMTP Settings"
3. Configure your own SMTP server (recommended for production)

## Step 6: Verify Setup

You can verify your database is set up correctly:

1. Go to **Table Editor** in Supabase
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

## Database Schema Overview

The database consists of 7 main tables:

### Core Tables
- **teams**: Stores team information, linked to coaches (auth users)
- **players**: Stores player details for each team
- **games**: Stores match information

### Game Management
- **game_lineups**: Stores formation setup for each game
- **lineup_positions**: Individual player positions within a lineup
- **substitutions**: Tracks player substitutions during games
- **player_availability**: Tracks which players are available for each game

### Security

All tables have Row Level Security (RLS) enabled:
- Coaches can only see and modify their own teams and related data
- All operations are authenticated via Supabase Auth
- Policies ensure data isolation between different coaches

## Troubleshooting

### "relation already exists" error
This means tables are already created. Either:
- Drop the existing tables first (be careful!)
- Or skip the initial schema migration

### RLS policy errors
Make sure:
- RLS is enabled on all tables
- You're signed in when testing
- Your user ID matches the coach_id in the teams table

### Connection issues
Check that:
- Your `.env.local` file has the correct credentials
- The file is in the project root directory
- You've restarted your Next.js dev server after adding the env vars

## Next Steps

After completing this setup:

1. Start your development server: `npm run dev`
2. The app will now be able to connect to your Supabase database
3. Continue with Phase 1 development tasks (authentication, etc.)

## Useful Supabase Links

- [Supabase Documentation](https://supabase.com/docs)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Database Functions](https://supabase.com/docs/guides/database/functions)
- [Supabase Auth](https://supabase.com/docs/guides/auth)

## Migration Files Reference

- `20251030_initial_schema.sql` - Creates all tables and indexes
- `20251030_rls_policies.sql` - Sets up Row Level Security policies

Both files are located in the `supabase/migrations/` directory.
