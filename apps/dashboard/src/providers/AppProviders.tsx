import { TooltipProvider } from '#/components/ui/tooltip'
import { queryClient } from '#/lib/query-client'
import { QueryClientProvider } from '@tanstack/react-query'
import type { ReactNode } from 'react'

const AppProviders = ({ children }: { children: ReactNode }) => {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>{children}</TooltipProvider>
    </QueryClientProvider>
  )
}

export default AppProviders
