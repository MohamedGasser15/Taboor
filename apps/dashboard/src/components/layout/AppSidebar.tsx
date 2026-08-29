import { Link, useLocation } from '@tanstack/react-router'
import { Collapsible } from '@base-ui/react/collapsible'
import {
  Building2Icon,
  ChevronRightIcon,
  LayoutDashboardIcon,
} from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { Logo } from '#/components/brand/logo'
import { useDirection } from '#/hooks/use-direction'
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuBadge,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarMenuSub,
  SidebarMenuSubButton,
  SidebarMenuSubItem,
  SidebarSeparator,
  useSidebar,
} from '#/components/ui/sidebar'
import { managementItems, queueItems, systemItems } from './sidebarConfig'
import NavUser from './NavUser'

export function AppSidebar() {
  const { state } = useSidebar()
  const { pathname } = useLocation()
  const direction = useDirection()
  const { t } = useTranslation('navbar')

  const isActive = (url: string) =>
    pathname === url || pathname.startsWith(`${url}/`)

  const itemLabel = (key: string) => t(`items.${key}`)

  return (
    <Sidebar collapsible="icon" side={direction === 'rtl' ? 'right' : 'left'}>
      <SidebarHeader className="h-14 justify-center px-2 group-data-[collapsible=icon]:px-0">
        <div className="flex items-center group-data-[collapsible=icon]:justify-center">
          <Logo size="xs" scale={1.3} hideWordmark={state === 'collapsed'} />
        </div>
      </SidebarHeader>
      <SidebarSeparator className="mx-0" />

      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>{t('groups.overview')}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              <SidebarMenuItem>
                <SidebarMenuButton
                  render={<Link to="/dashboard" />}
                  isActive={pathname === '/dashboard'}
                  tooltip={t('items.dashboard')}
                >
                  <LayoutDashboardIcon />
                  <span>{t('items.dashboard')}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup>
          <SidebarGroupLabel>{t('groups.queues')}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              <Collapsible.Root defaultOpen className="group/collapsible">
                <SidebarMenuItem>
                  <Collapsible.Trigger
                    render={<SidebarMenuButton tooltip={t('groups.queues')} />}
                  >
                    <Building2Icon />
                    <span>{t('groups.queues')}</span>
                    <ChevronRightIcon className="icon-flip ms-auto transition-transform duration-200 group-data-open/collapsible:rotate-90" />
                  </Collapsible.Trigger>
                  <Collapsible.Panel>
                    <SidebarMenuSub>
                      {queueItems.map((item) => (
                        <SidebarMenuSubItem key={item.key}>
                          <SidebarMenuSubButton
                            render={<Link to={item.url} />}
                            isActive={isActive(item.url)}
                          >
                            <item.icon />
                            <span>{itemLabel(item.key)}</span>
                          </SidebarMenuSubButton>
                        </SidebarMenuSubItem>
                      ))}
                    </SidebarMenuSub>
                  </Collapsible.Panel>
                </SidebarMenuItem>
              </Collapsible.Root>
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup>
          <SidebarGroupLabel>{t('groups.management')}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {managementItems.map((item) => (
                <SidebarMenuItem key={item.key}>
                  <SidebarMenuButton
                    render={<Link to={item.url} />}
                    isActive={isActive(item.url)}
                    tooltip={itemLabel(item.key)}
                  >
                    <item.icon />
                    <span>{itemLabel(item.key)}</span>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup>
          <SidebarGroupLabel>{t('groups.system')}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {systemItems.map((item) => (
                <SidebarMenuItem key={item.key}>
                  <SidebarMenuButton
                    render={<Link to={item.url} />}
                    isActive={isActive(item.url)}
                    tooltip={itemLabel(item.key)}
                  >
                    <item.icon />
                    <span>{itemLabel(item.key)}</span>
                    {item.badge && (
                      <SidebarMenuBadge>{item.badge}</SidebarMenuBadge>
                    )}
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter>
        <NavUser />
      </SidebarFooter>
    </Sidebar>
  )
}

export default AppSidebar
