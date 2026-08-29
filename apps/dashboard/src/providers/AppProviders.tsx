import { DirectionProvider } from '@base-ui/react/direction-provider'
import { QueryClientProvider } from '@tanstack/react-query'
import type { ReactNode } from 'react'
import { useDirection } from '#/hooks/use-direction'
import { queryClient } from '#/lib/query-client'
import { TooltipProvider } from '#/components/ui/tooltip'
import '#/lib/i18n'

function DirectionAwareProviders({ children }: { children: ReactNode }) {
  const direction = useDirection()

  return (
    <DirectionProvider direction={direction}>
      <TooltipProvider>{children}</TooltipProvider>
    </DirectionProvider>
  )
}

const AppProviders = ({ children }: { children: ReactNode }) => {
  return (
    <QueryClientProvider client={queryClient}>
      <DirectionAwareProviders>{children}</DirectionAwareProviders>
    </QueryClientProvider>
  )
}

export default AppProviders
