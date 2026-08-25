import { useAuthStore } from '#/feature/auth/auth-store'
import { useLogout } from '#/feature/auth/hooks/use-logout'
import { Button } from '#/components/ui/button'
import { ensureAuthInitialized } from '#/lib/client'
import { Outlet, createFileRoute, redirect } from '@tanstack/react-router'
import { LogOut } from 'lucide-react'
import { Logo } from '#/components/brand/logo'

export const Route = createFileRoute('/_authenticated')({
  beforeLoad: async () => {
    await ensureAuthInitialized()

    const { isAuthenticated } = useAuthStore.getState()

    if (!isAuthenticated) {
      throw redirect({
        to: '/login',
      })
    }
  },

  component: AuthenticatedLayout,
})

function AuthenticatedLayout() {
  const logout = useLogout()

  return (
    <div className="min-h-dvh w-full">
      <header className="flex items-center justify-between border-b bg-background px-6 py-3">
        {/* Logo / brand */}
        <Logo size="xs" scale={1.3} />

        {/* Navigation links/dropdowns - sibling of logo */}
        <nav className="flex items-center gap-4">
          {/* Dashboard, Queue, Services... */}
        </nav>

        {/* Right side actions - sibling of nav, not inside it */}
        <div className="flex items-center gap-3">
          {/* Theme toggle */}
          {/* Avatar dropdown (profile, logout) */}

          <Button
            variant="ghost"
            size="sm"
            onClick={() => logout.mutate()}
            disabled={logout.isPending}
          >
            <LogOut className="size-4" />
            {logout.isPending ? 'Signing out…' : 'Logout'}
          </Button>
        </div>
      </header>

      <main className="px-4">
        <Outlet />
      </main>
    </div>
  )
}
