import { createPortal } from 'react-dom'
import type { ReactNode } from 'react'
import { usePageHeaderSlot } from './PageHeaderSlot'

type PageHeaderProps = {
  title: string
  description?: string
  actions?: ReactNode
}

function PageHeader({ title, description, actions }: PageHeaderProps) {
  const { container } = usePageHeaderSlot()

  const content = (
    <div className="flex w-full min-w-0 items-center justify-between gap-2">
      <div className="min-w-0">
        <h1 className="truncate text-base font-semibold tracking-tight">
          {title}
        </h1>
        {description && (
          <p className="truncate text-xs text-muted-foreground">
            {description}
          </p>
        )}
      </div>
      {actions && (
        <div className="flex shrink-0 items-center gap-2">{actions}</div>
      )}
    </div>
  )

  if (!container) return null
  return createPortal(content, container)
}

export default PageHeader
