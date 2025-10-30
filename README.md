# VoetbalWissels - Football Team Management App

A web application for football coaches to manage their teams, create formations, and track player substitutions.

## Tech Stack

- **Framework:** Next.js 16 with TypeScript
- **Database:** Supabase (PostgreSQL)
- **ORM:** Drizzle ORM
- **Authentication:** Supabase Auth
- **Styling:** Tailwind CSS
- **Hosting:** Vercel

## Getting Started

### Prerequisites

- Node.js 18+ installed
- A Supabase account ([sign up here](https://supabase.com))
- A Vercel account for deployment ([sign up here](https://vercel.com))

### 1. Clone and Install

```bash
npm install
```

### 2. Set up Supabase

1. Go to [Supabase](https://supabase.com) and create a new project
2. Wait for the project to finish setting up
3. Go to Project Settings > API
4. Copy your project URL and anon/public key

### 3. Configure Environment Variables

Create a `.env.local` file in the root directory:

```bash
cp .env.example .env.local
```

Edit `.env.local` and add your Supabase credentials:

```env
NEXT_PUBLIC_SUPABASE_URL=your-project-url.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
DATABASE_URL=postgresql://postgres:your-db-password@db.your-project-ref.supabase.co:5432/postgres
```

**Note:** Get your database password from Supabase Dashboard → Project Settings → Database

### 4. Set Up Database Schema

Run the database migrations using Drizzle:

```bash
npm run db:push
```

Or manually run the SQL files in Supabase SQL Editor (see [DRIZZLE_GUIDE.md](./DRIZZLE_GUIDE.md) for details).

### 5. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) (or the port shown in terminal) to view the app.

## Project Structure

```
src/
├── app/              # Next.js App Router pages
│   ├── layout.tsx    # Root layout
│   ├── page.tsx      # Home page
│   └── globals.css   # Global styles
├── lib/              # Utility libraries
│   └── supabase/     # Supabase client configurations
│       ├── client.ts # Client-side Supabase client
│       └── server.ts # Server-side Supabase client
└── middleware.ts     # Next.js middleware for auth
```

## Development Roadmap

See [DESIGN.md](./DESIGN.md) for the complete design document and development roadmap.

### Phase 1: Foundation ✅
- [x] Set up Next.js project with TypeScript
- [x] Configure Supabase project (database, auth, storage)
- [x] Set up Vercel deployment pipeline
- [x] Implement authentication (login/signup)
- [x] Create database schema and migrations
- [x] Set up Supabase Row Level Security (RLS) policies

### Phase 2-6: Core Features (Coming Soon)
- Player Management
- Game Management
- Formation Builder
- Substitution System
- Polish & Testing

## Available Scripts

### Development
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

### Database (Drizzle ORM)
- `npm run db:generate` - Generate migrations from schema changes
- `npm run db:push` - Push schema changes to database
- `npm run db:migrate` - Run pending migrations
- `npm run db:studio` - Open Drizzle Studio (visual database browser)

See [DRIZZLE_GUIDE.md](./DRIZZLE_GUIDE.md) for detailed Drizzle ORM usage.

## Database Setup

This project uses **Drizzle ORM** for type-safe database operations and migrations.

### Quick Start
```bash
npm run db:push
```

### Schema Overview
The database includes 7 tables:
- **Teams** - Team information
- **Players** - Player roster
- **Games** - Game/match information
- **Game Lineups** - Formation setups
- **Lineup Positions** - Player positions in formations
- **Substitutions** - Player substitutions during games
- **Player Availability** - Player availability per game

### Documentation
- [DRIZZLE_GUIDE.md](./DRIZZLE_GUIDE.md) - Complete Drizzle ORM usage guide
- [supabase/SETUP.md](./supabase/SETUP.md) - Alternative manual setup guide
- [DESIGN.md](./DESIGN.md) - Complete data model and design decisions

## Deployment

The app is designed to be deployed on Vercel. For detailed deployment instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md).

Quick steps:
1. Push your code to GitHub
2. Import the repository in Vercel
3. Add environment variables in Vercel project settings
4. Deploy

For troubleshooting and best practices, refer to the [deployment guide](./DEPLOYMENT.md).

## Contributing

This is a prototype project. Contributions and suggestions are welcome!

## License

ISC
