# Deployment Guide

This guide will walk you through deploying VoetbalWissels to Vercel.

## Prerequisites

- A GitHub account
- A Vercel account ([sign up here](https://vercel.com))
- Completed Supabase setup (see [supabase/SETUP.md](./supabase/SETUP.md))

## Step 1: Push Code to GitHub

If you haven't already, initialize a Git repository and push to GitHub:

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: VoetbalWissels app setup"

# Add your GitHub repository as remote
git remote add origin https://github.com/yourusername/voetbalwissels.git

# Push to GitHub
git push -u origin main
```

## Step 2: Import Project to Vercel

### Option A: Using Vercel Dashboard (Recommended)

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click "Add New Project"
3. Import your GitHub repository:
   - Click "Import" next to your repository
   - If you don't see it, click "Adjust GitHub App Permissions" to grant access
4. Configure your project:
   - **Project Name**: voetbalwissels (or your preferred name)
   - **Framework Preset**: Next.js (should be auto-detected)
   - **Root Directory**: ./
   - **Build Command**: `npm run build` (should be auto-filled)
   - **Output Directory**: `.next` (should be auto-filled)

### Option B: Using Vercel CLI

1. Install Vercel CLI:
   ```bash
   npm install -g vercel
   ```

2. Login to Vercel:
   ```bash
   vercel login
   ```

3. Deploy:
   ```bash
   vercel
   ```

4. Follow the prompts to link your project

## Step 3: Configure Environment Variables

In your Vercel project settings:

1. Go to your project in Vercel Dashboard
2. Click on "Settings" tab
3. Click on "Environment Variables" in the sidebar
4. Add the following variables:

### Required Environment Variables

| Variable Name | Value | Description |
|--------------|-------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Your Supabase project URL | From Supabase Dashboard → Settings → API |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Your Supabase anon key | From Supabase Dashboard → Settings → API |
| `NEXT_PUBLIC_SITE_URL` | Your Vercel URL | e.g., `https://voetbalwissels.vercel.app` |

### Optional Environment Variables

| Variable Name | Value | Description |
|--------------|-------|-------------|
| `SUPABASE_SERVICE_ROLE_KEY` | Your Supabase service role key | Only if needed for admin operations |

**Important Notes:**
- Make sure to add these for all environments (Production, Preview, Development)
- The `NEXT_PUBLIC_` prefix exposes these variables to the browser (safe for public keys only)
- Never commit `.env.local` to your repository

## Step 4: Configure Supabase for Production

Update your Supabase project to allow your Vercel domain:

1. Go to your Supabase Dashboard
2. Navigate to Authentication → URL Configuration
3. Add your Vercel URLs to **Site URL**:
   - Production: `https://your-project.vercel.app`
   - Add any custom domains you're using
4. Add to **Redirect URLs**:
   - `https://your-project.vercel.app/**`
   - `https://your-project.vercel.app/auth/callback`

## Step 5: Deploy

### Automatic Deployments

Vercel automatically deploys when you push to your repository:

- **Production**: Pushes to `main` branch
- **Preview**: Pushes to any other branch or pull requests

### Manual Deployment

You can also trigger a manual deployment:

1. In Vercel Dashboard, go to your project
2. Click "Deployments" tab
3. Click "Redeploy" on any previous deployment
4. Or use CLI: `vercel --prod`

## Step 6: Verify Deployment

1. Visit your deployment URL (shown in Vercel Dashboard)
2. Test the following:
   - [ ] Homepage loads correctly
   - [ ] Can navigate to /signup
   - [ ] Can create an account
   - [ ] Can sign in
   - [ ] Can access /dashboard when logged in
   - [ ] Can sign out

## Troubleshooting

### Build Fails

**Check build logs in Vercel:**
1. Go to Deployments tab
2. Click on the failed deployment
3. Check the build logs for errors

**Common issues:**
- TypeScript errors: Fix in your code and push again
- Missing dependencies: Make sure all dependencies are in `package.json`
- Environment variables: Ensure all required env vars are set

### Authentication Not Working

**Check the following:**
1. Environment variables are set correctly in Vercel
2. Supabase URL configuration includes your Vercel domain
3. Redirect URLs are configured in Supabase
4. Browser console for any CORS errors

### Database Connection Issues

**Verify:**
1. Supabase credentials are correct
2. Environment variables are properly set
3. Check Supabase dashboard for any project issues
4. Verify RLS policies are not blocking queries

### "Middleware Not Working" Errors

**Make sure:**
1. `src/middleware.ts` is properly configured
2. Middleware matcher patterns are correct
3. Cookies are being set/read correctly

## Custom Domain (Optional)

To use a custom domain:

1. In Vercel Dashboard, go to your project
2. Click "Settings" → "Domains"
3. Click "Add" and enter your domain
4. Follow DNS configuration instructions
5. Update Supabase URL configuration with your custom domain

## Performance Optimization

### Recommended Vercel Settings

1. **Analytics**: Enable Vercel Analytics for performance monitoring
2. **Speed Insights**: Enable for real-user monitoring
3. **Edge Functions**: Consider using Edge Runtime for faster responses

### Environment-Specific Builds

You can optimize builds per environment by using different build commands:

```json
{
  "scripts": {
    "build": "next build",
    "build:preview": "next build",
    "build:production": "next build"
  }
}
```

## Monitoring and Logging

### View Deployment Logs

1. Go to Vercel Dashboard → Your Project
2. Click "Deployments" tab
3. Click on any deployment
4. View "Build Logs" and "Function Logs"

### Set Up Alerts

1. In Vercel Dashboard, go to Settings → Integrations
2. Add integrations for:
   - Slack notifications
   - Email alerts
   - Error tracking (Sentry, etc.)

## Continuous Deployment Workflow

Recommended Git workflow:

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to GitHub (triggers preview deployment)
git push origin feature/new-feature

# Create pull request on GitHub
# Review preview deployment
# Merge to main (triggers production deployment)
```

## Rollback

If you need to rollback a deployment:

1. Go to Vercel Dashboard → Deployments
2. Find the last working deployment
3. Click "..." menu → "Promote to Production"

Or use CLI:
```bash
vercel rollback
```

## Security Best Practices

1. **Environment Variables**: Never commit secrets to Git
2. **Branch Protection**: Enable branch protection rules on GitHub
3. **Preview Deployments**: Review preview URLs before merging
4. **Dependencies**: Keep dependencies updated
5. **Supabase RLS**: Ensure Row Level Security is properly configured

## Cost Considerations

### Vercel Free Tier Includes:
- Unlimited deployments
- Automatic HTTPS
- 100 GB bandwidth per month
- Hobby projects

### Upgrade Considerations:
- Commercial projects require Pro plan
- Check [Vercel Pricing](https://vercel.com/pricing) for details

## Additional Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
- [Supabase + Vercel Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-nextjs)
- [Vercel CLI Reference](https://vercel.com/docs/cli)

## Support

If you encounter issues:

1. Check [Vercel Status](https://www.vercel-status.com/)
2. Check [Supabase Status](https://status.supabase.com/)
3. Review deployment logs
4. Contact Vercel support or check their community forums
