import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/customers')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Customers"
        description="Manage your customers and their history."
      />
      <div className="text-sm text-muted-foreground">
        Customers — under construction
      </div>
    </>
  )
}
