import { createFileRoute, redirect, Outlet } from '@tanstack/react-router'
import { useAuthStore } from '#/feature/auth/auth-store'
import { isPlatformAdmin } from '#/lib/isPlatformAdmin'

export const Route = createFileRoute('/_authenticated/_platformAdmin')({
  beforeLoad: () => {
    // No need to call ensureAuthInitialized() again —
    // parent _authenticated already resolved it before child guard runs.
    // This is now a guard-only layout (no DashboardShell) to avoid nested shells.
    // The single DashboardShell in _authenticated/route.tsx switches navConfig
    // based on the current pathname.
    const { isAuthenticated, user } = useAuthStore.getState()
    if (!isAuthenticated) {
      throw redirect({ to: '/login' })
    }
    if (!isPlatformAdmin(user)) {
      throw redirect({ to: '/dashboard' })
    }
  },
  component: PlatformAdminLayout,
})

function PlatformAdminLayout() {
  return <Outlet />
}
