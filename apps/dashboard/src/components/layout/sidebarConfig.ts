import { BarChart3Icon, BellIcon, CalendarClockIcon, CheckCircle2Icon, Clock3Icon, LifeBuoyIcon, ListOrderedIcon, SettingsIcon, StoreIcon, TicketIcon, UsersIcon } from "lucide-react"
import type { LucideIcon  } from "lucide-react";

type NavItem = {
  title: string
  url: string
  icon: LucideIcon
  badge?: string
}

export const queueItems: NavItem[] = [
  {
    title: 'Now Serving',
    url: '/dashboard/queues/now-serving',
    icon: Clock3Icon,
  },
  {
    title: 'Active Queues',
    url: '/dashboard/queues/active',
    icon: ListOrderedIcon,
  },
  {
    title: 'Scheduled',
    url: '/dashboard/queues/scheduled',
    icon: CalendarClockIcon,
  },
  {
    title: 'Completed',
    url: '/dashboard/queues/completed',
    icon: CheckCircle2Icon,
  },
]

export const managementItems: NavItem[] = [
  { title: 'Customers', url: '/dashboard/customers', icon: UsersIcon },
  { title: 'Services', url: '/dashboard/services', icon: TicketIcon },
  { title: 'Businesses', url: '/dashboard/businesses', icon: StoreIcon },
  { title: 'Reports', url: '/dashboard/reports', icon: BarChart3Icon },
]

export const systemItems: NavItem[] = [
  {
    title: 'Notifications',
    url: '/dashboard/notifications',
    icon: BellIcon,
    badge: '3',
  },
  { title: 'Settings', url: '/dashboard/settings', icon: SettingsIcon },
  { title: 'Support', url: '/dashboard/support', icon: LifeBuoyIcon },
]
