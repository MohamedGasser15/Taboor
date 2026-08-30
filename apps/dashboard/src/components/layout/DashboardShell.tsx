import { Outlet } from '@tanstack/react-router'

import { PageHeaderSlotProvider } from '#/components/layout/PageHeaderSlot'
import { SidebarInset, SidebarProvider } from '#/components/ui/sidebar'
import ShellHeader from '#/components/ShellHeader'
import AppSidebar from './AppSidebar'
import type { SidebarConfig } from './sidebarConfig'

type DashboardShellProps = {
  navConfig: SidebarConfig
}

export function DashboardShell({ navConfig }: DashboardShellProps) {
  return (
    <SidebarProvider>
      <AppSidebar config={navConfig} />
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

export default DashboardShell
