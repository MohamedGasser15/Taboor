import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'
import { useAuthStore } from '#/feature/auth/auth-store'
import { ensureAuthInitialized } from '#/lib/client'
import { Logo } from '#/components/brand/logo'
import NavMenu from '#/components/layout/NavMenu'
import AvatarDropdown from '#/components/AvatarDropdown'

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
  return (
    <div className="min-h-dvh w-full">
      <header className="flex items-center justify-between border-b bg-background px-6 py-3 shadow">
        {/* Logo / brand */}
        <Logo size="xs" scale={1.3} />

        {/* Navigation links/dropdowns - sibling of logo */}
        <NavMenu />

        {/* Right side actions - sibling of nav, not inside it */}
        <div className="flex items-center gap-3">
          {/* Theme toggle */}
          {/* Avatar dropdown (profile, logout) */}
          <AvatarDropdown />
        </div>
      </header>

      <main className="px-4">
        <Outlet />
      </main>
    </div>
  )
}
