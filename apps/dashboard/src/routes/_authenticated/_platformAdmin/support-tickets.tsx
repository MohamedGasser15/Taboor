import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/support-tickets')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.supportTickets.title')}
        description={t('pages.supportTickets.description')}
      />
      <div className="rounded-lg border bg-card p-6">
        <h3 className="font-semibold">Support Tickets (Dummy — in Ops collapsible)</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Collapsible <code>Ops</code> group demo. Click the Ops header in sidebar to collapse/expand — proves generic
          <code> SidebarCollapsibleGroup</code> rendering works for platform too.
        </p>
        <div className="mt-4 space-y-2">
          {['#1042 — Acme: queue not advancing', '#1041 — Demo: billing question'].map((s) => (
            <div key={s} className="rounded-md border p-3 text-sm">
              {s}
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
