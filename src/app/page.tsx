import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function Home() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  // If user is logged in, redirect to dashboard
  if (user) {
    redirect('/dashboard')
  }

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-4xl font-bold mb-4">VoetbalWissels</h1>
            <p className="text-xl text-gray-600 dark:text-gray-400">
              Football Team Management for Coaches
            </p>
          </div>
          <div className="flex gap-4">
            <Link
              href="/login"
              className="px-4 py-2 text-blue-600 hover:text-blue-500 font-medium"
            >
              Sign in
            </Link>
            <Link
              href="/signup"
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 font-medium"
            >
              Get Started
            </Link>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Player Management</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Manage your team roster and track player availability
            </p>
          </div>

          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Formations</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Create game setups and assign positions
            </p>
          </div>

          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Substitutions</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Track player swaps during games
            </p>
          </div>
        </div>

        <div className="text-center">
          <h3 className="text-2xl font-bold mb-4">Ready to get started?</h3>
          <p className="text-gray-600 dark:text-gray-400 mb-6">
            Create your free account and start managing your team today
          </p>
          <Link
            href="/signup"
            className="inline-block px-6 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700 font-medium text-lg"
          >
            Sign Up Now
          </Link>
        </div>
      </div>
    </main>
  );
}
