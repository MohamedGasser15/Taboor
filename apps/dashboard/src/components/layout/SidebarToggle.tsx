import { PanelLeftCloseIcon, PanelLeftOpenIcon } from 'lucide-react'

import { cn } from '@/lib/utils'
import { useSidebar } from '#/components/ui/sidebar'
import { Tooltip, TooltipContent, TooltipTrigger } from '../ui/tooltip'

function SidebarToggle() {
  const { state, isMobile, openMobile, toggleSidebar } = useSidebar()

  const closed = isMobile ? !openMobile : state === 'collapsed'
  const Icon = closed ? PanelLeftOpenIcon : PanelLeftCloseIcon

  return (
    <div
      className={cn(
        'fixed top-1/2 z-50 -translate-y-1/2 transition-[left,opacity] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)]',
        closed
          ? 'left-0 opacity-100'
          : isMobile
            ? 'left-0 pointer-events-none opacity-0'
            : 'left-[var(--sidebar-width)] opacity-0 hover:opacity-100 focus-within:opacity-100',
      )}
    >
      <Tooltip>
        <TooltipTrigger
          render={
            <button
              type="button"
              onClick={toggleSidebar}
              aria-label={closed ? 'Expand sidebar' : 'Collapse sidebar'}
              className={cn(
                'flex size-9 items-center justify-center rounded-r-full bg-primary text-primary-foreground shadow-md transition-all duration-200 ease-linear hover:bg-primary/90',
                closed ? '' : '-translate-x-1/2',
              )}
            >
              <Icon className="size-5" />
            </button>
          }
        />
        <TooltipContent>
          <kbd data-slot="kbd">Ctrl</kbd>
          <span>+</span>
          <kbd data-slot="kbd">B</kbd>
        </TooltipContent>
      </Tooltip>
    </div>
  )
}

export default SidebarToggle
