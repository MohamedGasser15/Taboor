import { useAuthStore } from '#/feature/auth/auth-store'
import { useLogout } from '#/feature/auth/hooks/use-logout'
import { Button } from '#/components/ui/button'
import { ensureAuthInitialized } from '#/lib/client'
import { Outlet, createFileRoute, redirect } from '@tanstack/react-router'
import { LogOut } from 'lucide-react'

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
    <div className="min-h-dvh">
      <header className="flex items-center justify-between border-b bg-background px-6 py-3">
        <span className="text-sm font-semibold text-ink">Taboor Dashboard</span>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => logout.mutate()}
          disabled={logout.isPending}
        >
          <LogOut className="size-4" />
          {logout.isPending ? 'Signing out…' : 'Logout'}
        </Button>
      </header>
      <Outlet />
    </div>
  )
}
