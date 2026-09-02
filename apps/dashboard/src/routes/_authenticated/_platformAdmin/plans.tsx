import { Button } from '#/components/ui/button'
import PageHeader from '#/components/layout/PageHeader'
import { PlanCard } from '#/feature/plans/components/PlanCard'
import { PlansEmptyState } from '#/feature/plans/components/PlansEmptyState'
import { PlanFormSheet } from '#/feature/plans/components/PlanFormSheet'
import { PlansSkeleton } from '#/feature/plans/components/PlansSkeleton'
import { usePlans } from '#/feature/plans/hooks/use-plans'
import type { Plan } from '#/feature/plans/plans-types'
import { createFileRoute } from '@tanstack/react-router'
import { AlertCircle, Plus, RefreshCw } from 'lucide-react'
import { useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'

export const Route = createFileRoute(
  '/_authenticated/_platformAdmin/plans',
)({
  component: PlansPage,
})

function PlansPage() {
  const { t } = useTranslation('plans')
  const [activeTab, setActiveTab] = useState<'all' | 'active' | 'inactive'>(
    'all',
  )
  const [isSheetOpen, setIsSheetOpen] = useState(false)
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null)

  const {
    data: plans,
    isLoading,
    isError,
    refetch,
    isFetching,
  } = usePlans()

  const filteredPlans = useMemo(() => {
    if (!plans) return []
    if (activeTab === 'active') return plans.filter((p) => p.isActive)
    if (activeTab === 'inactive') return plans.filter((p) => !p.isActive)
    return plans
  }, [plans, activeTab])

  const handleOpenCreate = () => {
    setSelectedPlan(null)
    setIsSheetOpen(true)
  }

  const handleOpenEdit = (plan: Plan) => {
    setSelectedPlan(plan)
    setIsSheetOpen(true)
  }

  return (
    <div className="space-y-6">
      {/* Portaled to Top Sticky ShellHeader */}
      <PageHeader
        title={t('title')}
        description={t('description')}
        actions={
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => refetch()}
              disabled={isFetching}
              className="gap-1.5"
            >
              <RefreshCw
                className={`size-3.5 ${isFetching ? 'animate-spin' : ''}`}
              />
            </Button>

            <Button onClick={handleOpenCreate} className="gap-2" size="sm">
              <Plus className="size-4" />
              {t('createPlan')}
            </Button>
          </div>
        }
      />

      {/* Filter Segmented Controls */}
      <div className="flex items-center justify-between">
        <div className="flex w-fit items-center rounded-lg border border-border bg-muted/50 p-1 text-xs">
          <button
            type="button"
            onClick={() => setActiveTab('all')}
            className={`rounded-md px-3 py-1.5 font-medium transition-all ${
              activeTab === 'all'
                ? 'bg-card text-foreground shadow-xs font-semibold'
                : 'text-muted-foreground hover:text-foreground'
            }`}
          >
            {t('all')}
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('active')}
            className={`rounded-md px-3 py-1.5 font-medium transition-all ${
              activeTab === 'active'
                ? 'bg-card text-foreground shadow-xs font-semibold'
                : 'text-muted-foreground hover:text-foreground'
            }`}
          >
            {t('activeOnly')}
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('inactive')}
            className={`rounded-md px-3 py-1.5 font-medium transition-all ${
              activeTab === 'inactive'
                ? 'bg-card text-foreground shadow-xs font-semibold'
                : 'text-muted-foreground hover:text-foreground'
            }`}
          >
            {t('inactiveOnly')}
          </button>
        </div>
      </div>

      {/* Content Area */}
      {isLoading ? (
        <PlansSkeleton />
      ) : isError ? (
        <div className="flex flex-col items-center justify-center rounded-2xl border border-destructive/20 bg-destructive/5 p-10 text-center">
          <AlertCircle className="size-10 text-destructive" />
          <h3 className="mt-3 font-heading text-lg font-bold text-foreground">
            {t('error.title')}
          </h3>
          <p className="mt-1 text-sm text-muted-foreground">
            {t('error.description')}
          </p>
          <Button
            variant="outline"
            size="sm"
            onClick={() => refetch()}
            className="mt-4 gap-2"
          >
            <RefreshCw className="size-3.5" />
            {t('error.retry')}
          </Button>
        </div>
      ) : !plans || plans.length === 0 ? (
        <PlansEmptyState onCreate={handleOpenCreate} />
      ) : filteredPlans.length === 0 ? (
        <div className="flex flex-col items-center justify-center rounded-2xl border border-dashed border-border bg-card/60 p-10 text-center">
          <p className="text-sm font-medium text-muted-foreground">
            {t('empty.title')}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
          {filteredPlans.map((plan) => (
            <PlanCard key={plan.id} plan={plan} onEdit={handleOpenEdit} />
          ))}
        </div>
      )}

      {/* Create / Edit Plan Side Sheet */}
      <PlanFormSheet
        open={isSheetOpen}
        onOpenChange={setIsSheetOpen}
        plan={selectedPlan}
      />
    </div>
  )
}
