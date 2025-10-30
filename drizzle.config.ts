import { defineConfig } from 'drizzle-kit';
import * as dotenv from 'dotenv';

dotenv.config({ path: '.env.local' });

export default defineConfig({
  schema: './src/lib/db/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
    // Force IPv4 to avoid network unreachable errors
    ssl: { rejectUnauthorized: false },
  },
  verbose: true,
  strict: true,
});
