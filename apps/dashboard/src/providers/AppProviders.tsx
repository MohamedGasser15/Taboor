import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import type { ReactNode } from 'react'

const AppProviders = ({ children }: { children: ReactNode }) => {
  const query = new QueryClient()
  return <QueryClientProvider client={query}>{children}</QueryClientProvider>
}

export default AppProviders
