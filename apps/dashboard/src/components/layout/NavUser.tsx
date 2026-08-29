import {
  BadgeCheckIcon,
  BellIcon,
  CheckIcon,
  ChevronsUpDownIcon,
  CreditCardIcon,
  LanguagesIcon,
  LogOutIcon,
} from 'lucide-react'
import { useTranslation } from 'react-i18next'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
  DropdownMenuTrigger,
} from '../ui/dropdown-menu'
import { SidebarMenu, SidebarMenuButton, SidebarMenuItem } from '../ui/sidebar'
import { Avatar, AvatarFallback } from '../ui/avatar'
import { useDirection } from '#/hooks/use-direction'
import { useLogout } from '#/feature/auth/hooks/use-logout'
import { useAuthStore } from '#/feature/auth/auth-store'

function getInitials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return ''
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
  return (parts[0][0] + parts[1][0]).toUpperCase()
}

function NavUser() {
  const logout = useLogout()
  const user = useAuthStore((s) => s.user)
  const { t, i18n } = useTranslation('navbar')
  const direction = useDirection()

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger
            render={
              <SidebarMenuButton
                size="lg"
                tooltip={t('account.label')}
                className="h-12 group-data-[collapsible=icon]:justify-center"
              />
            }
          >
            <Avatar size="sm">
              <AvatarFallback className="bg-accent text-black">
                {getInitials(user?.fullName ?? '')}
              </AvatarFallback>
            </Avatar>
            <div className="grid flex-1 text-start text-sm leading-tight group-data-[collapsible=icon]:hidden">
              <span className="truncate font-medium">
                {user?.fullName ?? t('account.label')}
              </span>
              <span className="truncate text-xs text-muted-foreground">
                {user?.email}
              </span>
            </div>
            <ChevronsUpDownIcon className="ms-auto size-4 group-data-[collapsible=icon]:hidden" />
          </DropdownMenuTrigger>
          <DropdownMenuContent
            side={direction === 'rtl' ? 'left' : 'right'}
            align="end"
            sideOffset={10}
            className="w-56"
          >
            <DropdownMenuGroup>
              <DropdownMenuLabel>
                <div className="flex flex-col">
                  <span className="truncate">
                    {user?.fullName ?? t('account.label')}
                  </span>
                  <span className="truncate text-xs font-normal text-muted-foreground">
                    {user?.email}
                  </span>
                </div>
              </DropdownMenuLabel>
              <DropdownMenuItem>
                <BadgeCheckIcon />
                {t('account.label')}
              </DropdownMenuItem>
              <DropdownMenuItem>
                <CreditCardIcon />
                {t('account.billing')}
              </DropdownMenuItem>
              <DropdownMenuItem>
                <BellIcon />
                {t('account.notifications')}
              </DropdownMenuItem>
              <DropdownMenuSub>
                <DropdownMenuSubTrigger>
                  <LanguagesIcon />
                  {t('language.label')}
                </DropdownMenuSubTrigger>
                <DropdownMenuSubContent
                  side={direction === 'rtl' ? 'left' : 'right'}
                >
                  <DropdownMenuItem onClick={() => i18n.changeLanguage('en')}>
                    English
                    {i18n.language === 'en' && (
                      <CheckIcon className="ms-auto size-4" />
                    )}
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={() => i18n.changeLanguage('ar')}>
                    العربية
                    {i18n.language.startsWith('ar') && (
                      <CheckIcon className="ms-auto size-4" />
                    )}
                  </DropdownMenuItem>
                </DropdownMenuSubContent>
              </DropdownMenuSub>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              variant="destructive"
              onClick={() => logout.mutate()}
            >
              <LogOutIcon />
              {t('account.signOut')}
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  )
}

export default NavUser
