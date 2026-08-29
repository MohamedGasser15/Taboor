import {
  BarChart3Icon,
  BellIcon,
  CalendarClockIcon,
  CheckCircle2Icon,
  Clock3Icon,
  LifeBuoyIcon,
  ListOrderedIcon,
  SettingsIcon,
  StoreIcon,
  TicketIcon,
  UsersIcon,
} from 'lucide-react'
import type { LucideIcon } from 'lucide-react'

export type NavItem = {
  key: string
  url: string
  icon: LucideIcon
  badge?: string
}

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
