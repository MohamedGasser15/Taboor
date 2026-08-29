import { createContext, useContext, useMemo, useState } from 'react'
import type { ReactNode } from 'react'

type PageHeaderSlotContextValue = {
  container: HTMLElement | null
  register: (el: HTMLElement | null) => void
}

const PageHeaderSlotContext = createContext<PageHeaderSlotContextValue>({
  container: null,
  register: () => {},
})

export function PageHeaderSlotProvider({ children }: { children: ReactNode }) {
  const [container, setContainer] = useState<HTMLElement | null>(null)

  const value = useMemo(
    () => ({ container, register: setContainer }),
    [container],
  )

  return (
    <PageHeaderSlotContext.Provider value={value}>
      {children}
    </PageHeaderSlotContext.Provider>
  )
}

export function usePageHeaderSlot() {
  return useContext(PageHeaderSlotContext)
}
