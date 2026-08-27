import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'
import { useAuthStore } from '#/feature/auth/auth-store'
import { ensureAuthInitialized } from '#/lib/client'
import AppSidebar from '#/components/layout/AppSidebar'
import SidebarToggle from '#/components/layout/SidebarToggle'
import { SidebarInset, SidebarProvider } from '#/components/ui/sidebar'

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
    <SidebarProvider>
      <AppSidebar />

      <SidebarToggle />

      <SidebarInset>
        <div className="flex flex-1 flex-col gap-4 p-4">
          <Outlet />
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}
