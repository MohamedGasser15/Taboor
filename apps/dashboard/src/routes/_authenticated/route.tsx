import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'
import { useAuthStore } from '#/feature/auth/auth-store'
import { ensureAuthInitialized } from '#/lib/client'
import AppSidebar from '#/components/layout/AppSidebar'
import { PageHeaderSlotProvider } from '#/components/layout/PageHeaderSlot'
import { SidebarInset, SidebarProvider } from '#/components/ui/sidebar'
import ShellHeader from '#/components/ShellHeader'

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

      <SidebarInset className="h-svh overflow-y-auto">
        <PageHeaderSlotProvider>
          <ShellHeader />

          <div className="flex-1 p-4">
            <Outlet />
          </div>
        </PageHeaderSlotProvider>
      </SidebarInset>
    </SidebarProvider>
  )
}
