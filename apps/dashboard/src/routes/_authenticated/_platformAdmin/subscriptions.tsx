import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/subscriptions')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.subscriptions.title')}
        description={t('pages.subscriptions.description')}
      />
      <div className="rounded-lg border bg-card p-6">
        <h3 className="font-semibold">Subscriptions (Dummy)</h3>
        <p className="mt-2 text-sm text-muted-foreground">Tracks tenant → plan assignments. Dummy data to distinguish platform shell.</p>
        <div className="mt-4 overflow-hidden rounded-md border">
          <div className="grid grid-cols-3 bg-muted p-2 text-xs font-medium">
            <span>Tenant</span>
            <span>Plan</span>
            <span>Status</span>
          </div>
          {[
            ['Acme Corp', 'Pro', 'Active'],
            ['Demo', 'Free', 'Trialing'],
            ['Contoso', 'Enterprise', 'Past Due'],
          ].map((r) => (
            <div key={r[0]} className="grid grid-cols-3 p-2 text-sm border-t">
              <span>{r[0]}</span>
              <span>{r[1]}</span>
              <span>{r[2]}</span>
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
