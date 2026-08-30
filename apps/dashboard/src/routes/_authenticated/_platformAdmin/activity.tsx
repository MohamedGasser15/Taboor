import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/activity')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.activity.title')}
        description={t('pages.activity.description')}
      />
      <div className="rounded-lg border bg-card p-6">
        <h3 className="font-semibold">Activity Feed (Dummy)</h3>
        <p className="mt-2 text-sm text-muted-foreground">Second item inside Ops collapsible.</p>
        <div className="mt-4 h-24 rounded-md bg-muted p-4 text-xs text-muted-foreground">Timeline placeholder — dummy to show Ops group has 2 items</div>
      </div>
    </>
  )
}
