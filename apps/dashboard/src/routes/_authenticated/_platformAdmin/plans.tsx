import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/plans')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.plans.title')}
        description={t('pages.plans.description')}
      />
      <div className="grid gap-4">
        <div className="rounded-lg border border-primary/20 bg-card p-6">
          <h3 className="font-semibold text-primary">Platform — Plans (Dummy)</h3>
          <p className="mt-2 text-sm text-muted-foreground">
            This is a dummy platform-admin page. Uses <code>platformNavConfig</code> → sidebar groups
            Platform / Analytics / Ops — visually distinct from tenant shell (Overview/Queues/Management/System).
          </p>
          <div className="mt-4 grid grid-cols-3 gap-3">
            <div className="rounded-md bg-muted p-4 text-center text-sm">Free — max_branches: 1</div>
            <div className="rounded-md bg-primary p-4 text-center text-sm text-primary-foreground">Pro — max_branches: 5</div>
            <div className="rounded-md bg-muted p-4 text-center text-sm">Enterprise — unlimited</div>
          </div>
        </div>
      </div>
    </>
  )
}
