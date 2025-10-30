# VoetbalWissels - Football Team Management App

A web application for football coaches to manage their teams, create formations, and track player substitutions.

## Tech Stack

- **Framework:** Next.js 16 with TypeScript
- **Database:** Supabase (PostgreSQL)
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
```

### 4. Run Development Server

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

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

## Database Setup

After setting up your Supabase project, you'll need to create the database schema. Follow the detailed guide in [supabase/SETUP.md](./supabase/SETUP.md).

The schema includes:
- Teams
- Players
- Games
- Game Lineups
- Lineup Positions
- Substitutions
- Player Availability

See [DESIGN.md](./DESIGN.md) for the complete data model.

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
