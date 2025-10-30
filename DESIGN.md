# Football Team Management App - Design Document

## Project Overview

A web application designed for football coaches and trainers to efficiently manage their teams, create game setups, and handle player substitutions. Built as a prototype with core features that can be expanded in future iterations.

**Target Users:** Football coaches and trainers
**Platform:** Web application
**Status:** Prototype

---

## Tech Stack

- **Framework:** Next.js (React)
- **Database:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **Storage:** Supabase Storage
- **Hosting:** Vercel
- **Language:** TypeScript (recommended for type safety)

---

## Core Features

### 1. Player Management
**Purpose:** Allow coaches to maintain their team roster and track player availability

**Key Capabilities:**
- Add/edit/remove players from the team roster
- Store player information (name, number, position, contact details)
- Mark players as available/unavailable for specific games
- View player statistics and history

**User Stories:**
- As a coach, I want to add new players to my roster so I can manage the full team
- As a coach, I want to mark players as unavailable so I know who can't play in the next game
- As a coach, I want to view all my players in one place so I can make informed decisions

---

### 2. Game Setup & Formations
**Purpose:** Enable coaches to create and visualize playing formations

**Key Capabilities:**
- Create game/match entries
- Select formation type (4-4-2, 4-3-3, 3-5-2, etc.)
- Assign players to specific positions on the field
- Save multiple formation templates
- Visual representation of the field with player positions

**User Stories:**
- As a coach, I want to create a starting lineup for a game so I can plan ahead
- As a coach, I want to see my formation visually so I can spot tactical issues
- As a coach, I want to save formations I use frequently so I can reuse them

---

### 3. Player Swap Management
**Purpose:** Manage substitutions during games efficiently

**Key Capabilities:**
- Track substitutions made during a game
- Record time of substitution
- Manage substitution limits (typically 3-5 subs per game depending on rules)
- Show substitution history for a game
- Quick swap interface for during-game changes

**User Stories:**
- As a coach, I want to record when I substitute a player so I can track game time
- As a coach, I want to see how many substitutions I have left so I don't exceed the limit
- As a coach, I want to quickly swap players during a game without complex navigation

---

## Data Model (Initial)

### Teams
```
- id (uuid)
- name (string)
- coach_id (uuid, references users)
- created_at (timestamp)
```

### Players
```
- id (uuid)
- team_id (uuid, references teams)
- name (string)
- jersey_number (integer)
- preferred_position (string)
- contact_info (json)
- created_at (timestamp)
```

### Games
```
- id (uuid)
- team_id (uuid, references teams)
- opponent_name (string)
- date (timestamp)
- location (string)
- status (enum: planned, in_progress, completed)
- created_at (timestamp)
```

### Game Lineups
```
- id (uuid)
- game_id (uuid, references games)
- formation (string, e.g., "4-4-2")
- created_at (timestamp)
```

### Lineup Positions
```
- id (uuid)
- lineup_id (uuid, references game_lineups)
- player_id (uuid, references players)
- position (string, e.g., "GK", "CB", "ST")
- position_x (float, for visual positioning)
- position_y (float, for visual positioning)
- is_starter (boolean)
```

### Substitutions
```
- id (uuid)
- game_id (uuid, references games)
- player_out_id (uuid, references players)
- player_in_id (uuid, references players)
- minute (integer)
- created_at (timestamp)
```

### Player Availability
```
- id (uuid)
- player_id (uuid, references players)
- game_id (uuid, references games)
- is_available (boolean)
- reason (string, optional)
```

---

## User Flow

### Initial Setup Flow
1. Coach signs up / logs in
2. Coach creates a team
3. Coach adds players to the roster

### Pre-Game Flow
1. Coach creates a new game
2. Coach marks players as available/unavailable
3. Coach selects formation
4. Coach assigns available players to positions
5. Coach reviews and saves lineup

### During Game Flow
1. Coach opens the game
2. Coach views current lineup
3. When substitution needed:
   - Coach selects player to come off
   - Coach selects player to come on
   - System records time and validates substitution limit
4. Changes are reflected in real-time

---

## UI/UX Considerations

### Key Pages
1. **Dashboard** - Overview of upcoming games, recent activity
2. **Players** - List and manage all players
3. **Games** - View all games (past, upcoming)
4. **Game Detail** - Specific game with lineup and substitutions
5. **Formation Builder** - Visual interface to create lineups

### Design Principles
- **Mobile-first:** Coaches often use devices on the sideline
- **Quick actions:** Minimize clicks for common tasks (especially substitutions)
- **Visual clarity:** Clear representation of field positions
- **Offline-capable:** Consider offline functionality for poor connectivity at fields

---

## Future Enhancements (Post-Prototype)

- [ ] Player performance tracking and statistics
- [ ] Training session management
- [ ] Multi-team management for coaches with multiple teams
- [ ] Parent/player portal for communication
- [ ] Attendance tracking
- [ ] Match reports and analytics
- [ ] Team sharing/assistant coach access
- [ ] Export lineup images for social media
- [ ] Integration with league schedules
- [ ] Mobile app (React Native)

---

## Development Todo List

### Phase 1: Foundation
- [ ] Set up Next.js project with TypeScript
- [ ] Configure Supabase project (database, auth, storage)
- [ ] Set up Vercel deployment pipeline
- [ ] Implement authentication (login/signup)
- [ ] Create database schema and migrations
- [ ] Set up Supabase Row Level Security (RLS) policies

### Phase 2: Player Management
- [ ] Create players table and API routes
- [ ] Build player list page
- [ ] Implement add/edit/delete player functionality
- [ ] Add player availability toggle
- [ ] Create player detail view

### Phase 3: Game Management
- [ ] Create games table and API routes
- [ ] Build games list page
- [ ] Implement create/edit game functionality
- [ ] Add game detail page
- [ ] Implement game status management

### Phase 4: Formation Builder
- [ ] Create lineup and position tables
- [ ] Design formation templates (4-4-2, 4-3-3, etc.)
- [ ] Build visual field component
- [ ] Implement drag-and-drop player positioning
- [ ] Add save/load formation functionality
- [ ] Connect lineup with available players

### Phase 5: Substitution System
- [ ] Create substitutions table
- [ ] Build substitution interface
- [ ] Implement substitution validation (limits, timing)
- [ ] Add substitution history view
- [ ] Create quick-swap UI for live games

### Phase 6: Polish & Testing
- [ ] Responsive design testing (mobile/tablet/desktop)
- [ ] User testing with coaches
- [ ] Performance optimization
- [ ] Error handling and validation
- [ ] Documentation and help content
- [ ] Deploy to production

---

## Success Metrics

**Prototype Success Criteria:**
- Coach can create a team and add 11+ players in under 5 minutes
- Coach can create a game lineup in under 3 minutes
- Coach can execute a substitution in under 30 seconds
- App works smoothly on mobile devices
- No critical bugs in core flows

---

## Notes & Considerations

- **Substitution Rules:** Different leagues have different rules (3, 5, or unlimited subs). Consider making this configurable per game.
- **Position Flexibility:** Players often play multiple positions. Consider allowing multiple preferred positions.
- **Data Privacy:** Be mindful of storing player data, especially if players are minors. Check GDPR/privacy requirements.
- **Real-time Updates:** Consider if multiple coaches/assistants need to see updates simultaneously (would require real-time subscriptions).
- **Formation Validation:** Ensure formations are valid (e.g., must have 1 goalkeeper, correct number of players).

---

## Resources & References

- [Next.js Documentation](https://nextjs.org/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Vercel Deployment Guide](https://vercel.com/docs)
- Common Football Formations: 4-4-2, 4-3-3, 3-5-2, 4-2-3-1, 5-3-2

---

**Document Version:** 1.0
**Last Updated:** 2025-10-30
**Author:** Project Team
