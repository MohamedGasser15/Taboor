import {
  BarChart3Icon,
  BellIcon,
  CalendarClockIcon,
  CheckCircle2Icon,
  Clock3Icon,
  CrownIcon,
  LifeBuoyIcon,
  ListOrderedIcon,
  SettingsIcon,
  ShieldCheckIcon,
  StoreIcon,
  TicketIcon,
  UsersIcon,
  BuildingIcon,
  CreditCardIcon,
  LayoutDashboardIcon,
  Building2Icon,
  ClipboardListIcon,
  ActivityIcon,
} from 'lucide-react'
import type { LucideIcon } from 'lucide-react'

export type NavItem = {
  key: string
  url: string
  icon: LucideIcon
  badge?: string
}

// Keep legacy exports for backwards-compat (if any direct imports remain)
export type SidebarItem = NavItem

export interface SidebarFlatGroup {
  type: 'flat'
  labelKey: string
  items: SidebarItem[]
}

export interface SidebarCollapsibleGroup {
  type: 'collapsible'
  labelKey: string
  triggerKey: string
  icon: LucideIcon
  items: SidebarItem[]
}

export type SidebarSection = SidebarFlatGroup | SidebarCollapsibleGroup
export type SidebarConfig = SidebarSection[]

// --- Base item arrays (reused in tenant config) ---
export const queueItems: NavItem[] = [
  { key: 'nowServing', url: '/dashboard/queues/now-serving', icon: Clock3Icon },
  {
    key: 'activeQueues',
    url: '/dashboard/queues/active',
    icon: ListOrderedIcon,
  },
  {
    key: 'scheduled',
    url: '/dashboard/queues/scheduled',
    icon: CalendarClockIcon,
  },
  {
    key: 'completed',
    url: '/dashboard/queues/completed',
    icon: CheckCircle2Icon,
  },
]

export const managementItems: NavItem[] = [
  { key: 'customers', url: '/dashboard/customers', icon: UsersIcon },
  { key: 'services', url: '/dashboard/services', icon: TicketIcon },
  { key: 'businesses', url: '/dashboard/businesses', icon: StoreIcon },
  { key: 'reports', url: '/dashboard/reports', icon: BarChart3Icon },
]

export const systemItems: NavItem[] = [
  {
    key: 'notifications',
    url: '/dashboard/notifications',
    icon: BellIcon,
    badge: '3',
  },
  { key: 'settings', url: '/dashboard/settings', icon: SettingsIcon },
  { key: 'support', url: '/dashboard/support', icon: LifeBuoyIcon },
]

// --- Tenant (business) nav config — mirrors shipped shell ---
export const tenantNavConfig: SidebarConfig = [
  {
    type: 'flat',
    labelKey: 'groups.overview',
    items: [{ key: 'dashboard', url: '/dashboard', icon: LayoutDashboardIcon }],
  },
  {
    type: 'collapsible',
    labelKey: 'groups.queues',
    triggerKey: 'groups.queues',
    icon: Building2Icon,
    items: queueItems,
  },
  {
    type: 'flat',
    labelKey: 'groups.management',
    items: managementItems,
  },
  {
    type: 'flat',
    labelKey: 'groups.system',
    items: systemItems,
  },
]

// --- Platform admin nav config — dummy links to visually distinguish layouts ---
// These URLs map to _platformAdmin children (pathless -> /plans, /tenants, etc.)
// Intentionally distinct group labels + icons + count so you can tell shells apart at a glance.
export const platformNavConfig: SidebarConfig = [
  {
    type: 'flat',
    labelKey: 'groups.platform',
    items: [
      { key: 'plans', url: '/plans', icon: CrownIcon },
      { key: 'tenants', url: '/tenants', icon: BuildingIcon },
      { key: 'subscriptions', url: '/subscriptions', icon: CreditCardIcon },
      { key: 'auditLogs', url: '/audit-logs', icon: ShieldCheckIcon },
    ],
  },
  {
    type: 'flat',
    labelKey: 'groups.analytics',
    items: [
      { key: 'platformReports', url: '/platform-reports', icon: BarChart3Icon },
      { key: 'platformSettings', url: '/platform-settings', icon: SettingsIcon },
    ],
  },
  {
    type: 'collapsible',
    labelKey: 'groups.ops',
    triggerKey: 'groups.ops',
    icon: ClipboardListIcon,
    items: [
      { key: 'supportTickets', url: '/support-tickets', icon: LifeBuoyIcon },
      { key: 'activity', url: '/activity', icon: ActivityIcon },
    ],
  },
]

export const PLATFORM_PATHS = platformNavConfig.flatMap((section) =>
  section.items.map((item) => item.url),
)
