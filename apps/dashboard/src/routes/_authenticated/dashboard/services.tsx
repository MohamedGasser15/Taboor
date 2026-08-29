import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/services')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Services"
        description="The services your customers queue for."
      />
      <div className="text-sm text-muted-foreground">
        Services — under construction
      </div>
    </>
  )
}
