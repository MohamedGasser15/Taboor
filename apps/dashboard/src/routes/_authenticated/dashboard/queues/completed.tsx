import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute(
  '/_authenticated/dashboard/queues/completed',
)({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  const title = t('pages.completed.title')

  return (
    <>
      <PageHeader
        title={title}
        description={t('pages.completed.description')}
      />
      <div className="text-sm text-muted-foreground">
        {t('underConstruction', { page: title })}
      </div>
    </>
  )
}
