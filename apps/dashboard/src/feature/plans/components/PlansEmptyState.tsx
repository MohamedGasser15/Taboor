import { Button } from '#/components/ui/button'
import { Plus, Sparkles } from 'lucide-react'
import { useTranslation } from 'react-i18next'

interface PlansEmptyStateProps {
  onCreate: () => void
}

export function PlansEmptyState({ onCreate }: PlansEmptyStateProps) {
  const { t } = useTranslation('plans')

  return (
    <div className="flex flex-col items-center justify-center rounded-2xl border border-dashed border-border bg-card/60 p-12 text-center shadow-xs">
      <div className="flex size-14 items-center justify-center rounded-full bg-secondary text-primary">
        <Sparkles className="size-7" />
      </div>
      <h3 className="mt-4 font-heading text-lg font-bold text-foreground">
        {t('empty.title')}
      </h3>
      <p className="mt-1.5 max-w-md text-sm text-muted-foreground">
        {t('empty.description')}
      </p>
      <Button onClick={onCreate} className="mt-6 gap-2">
        <Plus className="size-4" />
        {t('empty.cta')}
      </Button>
    </div>
  )
}
