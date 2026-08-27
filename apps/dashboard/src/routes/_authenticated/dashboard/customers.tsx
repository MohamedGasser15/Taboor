import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/_authenticated/dashboard/customers')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div className="rounded-lg border bg-card p-6 text-sm text-muted-foreground">
      Customers — under construction
    </div>
  )
}
