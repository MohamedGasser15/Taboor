import { Button } from '#/components/ui/button'
import { Spinner } from '#/components/ui/spinner'
import {
  Building2,
  Clock,
  Edit2,
  GitFork,
  Layers,
  Power,
  PowerOff,
  Trash2,
} from 'lucide-react'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BillingCycle } from '../plans-types'
import type { Plan } from '../plans-types'
import {
  useActivatePlan,
  useDeactivatePlan,
  useDeletePlan,
} from '../hooks/use-plans'
import type { AxiosError } from 'axios'

interface PlanCardProps {
  plan: Plan
  onEdit: (plan: Plan) => void
}

export function PlanCard({ plan, onEdit }: PlanCardProps) {
  const { t } = useTranslation('plans')
  const activatePlan = useActivatePlan()
  const deactivatePlan = useDeactivatePlan()
  const deletePlan = useDeletePlan()

  const [isConfirmingDelete, setIsConfirmingDelete] = useState(false)
  const [deleteError, setDeleteError] = useState<string | null>(null)

  const isToggling = activatePlan.isPending || deactivatePlan.isPending

  const handleToggleStatus = () => {
    setDeleteError(null)
    if (plan.isActive) {
      deactivatePlan.mutate(plan.id)
    } else {
      activatePlan.mutate(plan.id)
    }
  }

  const handleDelete = () => {
    setDeleteError(null)
    deletePlan.mutate(plan.id, {
      onSuccess: () => {
        setIsConfirmingDelete(false)
      },
      onError: (error) => {
        const err = error as AxiosError<{ message?: string; errors?: string[] }>
        const msg =
          err.response?.data?.errors?.[0] ??
          err.response?.data?.message ??
          t('form.saveError')
        setDeleteError(msg)
      },
    })
  }

  const derivedQueues = plan.maxBranches * plan.maxServicesPerBranch

  return (
    <div
      className={`group relative flex flex-col justify-between rounded-2xl border bg-card p-6 shadow-xs transition-all duration-200 hover:shadow-md ${
        plan.isActive
          ? 'border-border hover:border-primary/40'
          : 'border-border/60 bg-card/60 opacity-90'
      }`}
    >
      <div>
        {/* Header: Name + Status Badge */}
        <div className="flex items-start justify-between gap-2">
          <div>
            <h3 className="font-heading text-xl font-bold tracking-tight text-foreground">
              {plan.name}
            </h3>
            {plan.description && (
              <p className="mt-1 line-clamp-2 text-xs text-muted-foreground">
                {plan.description}
              </p>
            )}
          </div>
          <span
            className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-semibold ${
              plan.isActive
                ? 'bg-soft-teal text-deep-teal dark:bg-teal/20 dark:text-teal'
                : 'bg-muted text-muted-foreground'
            }`}
          >
            <span
              className={`size-1.5 rounded-full ${
                plan.isActive ? 'bg-teal' : 'bg-muted-foreground'
              }`}
            />
            {plan.isActive ? t('active') : t('inactive')}
          </span>
        </div>

        {/* Pricing */}
        <div className="mt-5 space-y-1">
          <div className="flex items-baseline gap-1.5">
            {plan.price === 0 ? (
              <span className="font-heading text-3xl font-extrabold text-foreground">
                {t('free')}
              </span>
            ) : (
              <>
                <span className="font-heading text-3xl font-extrabold text-foreground">
                  {plan.price.toLocaleString()}
                </span>
                <span className="text-sm font-semibold text-muted-foreground">
                  {t('egp')}
                </span>
                <span className="text-xs text-muted-foreground">
                  {plan.billingCycle === BillingCycle.Monthly
                    ? t('perMonth')
                    : t('perYear')}
                </span>
              </>
            )}
          </div>
          {plan.price > 0 && (
            <p className="text-xs font-semibold text-teal">
              {plan.billingCycle === BillingCycle.Yearly
                ? t('monthlyEquivalent', {
                    amount: (plan.price / 12).toLocaleString(undefined, {
                      minimumFractionDigits: 2,
                      maximumFractionDigits: 2,
                    }),
                    currency: t('egp'),
                  })
                : t('billedAnnually')}
            </p>
          )}
        </div>

        {/* Resource Limits List */}
        <div className="mt-6 space-y-3 border-t border-border pt-5">
          <div className="flex items-center justify-between text-xs">
            <span className="flex items-center gap-2 text-muted-foreground">
              <Building2 className="size-4 text-teal" />
              {t('branchesLimit')}
            </span>
            <span className="font-semibold text-foreground">
              {plan.maxBranches}
            </span>
          </div>

          <div className="flex items-center justify-between text-xs">
            <span className="flex items-center gap-2 text-muted-foreground">
              <Layers className="size-4 text-teal" />
              {t('servicesLimit')}
            </span>
            <span className="font-semibold text-foreground">
              {plan.maxServices}
            </span>
          </div>

          <div className="flex items-center justify-between text-xs">
            <span className="flex items-center gap-2 text-muted-foreground">
              <GitFork className="size-4 text-teal" />
              {t('servicesPerBranchLimit')}
            </span>
            <span className="font-semibold text-foreground">
              {plan.maxServicesPerBranch}
            </span>
          </div>

          <div className="flex items-center justify-between rounded-lg bg-muted/60 px-2.5 py-1.5 text-xs">
            <span
              className="flex items-center gap-2 text-muted-foreground"
              title={t('derivedQueuesHint')}
            >
              <Clock className="size-3.5 text-amber" />
              {t('derivedQueues')}
            </span>
            <span className="font-bold text-foreground">{derivedQueues}</span>
          </div>
        </div>
      </div>

      {/* Action Buttons & Delete Confirmation */}
      <div className="mt-6 space-y-2 border-t border-border/80 pt-4">
        {deleteError && (
          <p className="text-xs text-destructive" role="alert">
            {deleteError}
          </p>
        )}

        {isConfirmingDelete ? (
          <div className="flex flex-col gap-2 rounded-xl border border-destructive/30 bg-destructive/10 p-3 text-xs">
            <p className="font-medium text-destructive">
              {t('deleteConfirm', { name: plan.name })}
            </p>
            <div className="flex items-center gap-2">
              <Button
                variant="destructive"
                size="sm"
                className="h-8 flex-1 text-xs"
                onClick={handleDelete}
                disabled={deletePlan.isPending}
              >
                {deletePlan.isPending ? (
                  <Spinner className="size-3.5" />
                ) : (
                  t('delete')
                )}
              </Button>
              <Button
                variant="outline"
                size="sm"
                className="h-8 flex-1 text-xs"
                onClick={() => {
                  setIsConfirmingDelete(false)
                  setDeleteError(null)
                }}
                disabled={deletePlan.isPending}
              >
                {t('form.cancel')}
              </Button>
            </div>
          </div>
        ) : (
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              className="flex-1 gap-1.5"
              onClick={() => onEdit(plan)}
            >
              <Edit2 className="size-3.5" />
              {t('edit')}
            </Button>

            <Button
              variant={plan.isActive ? 'ghost' : 'secondary'}
              size="sm"
              className={`gap-1.5 ${
                plan.isActive
                  ? 'text-destructive hover:bg-destructive/10 hover:text-destructive'
                  : 'text-teal hover:bg-soft-teal'
              }`}
              onClick={handleToggleStatus}
              disabled={isToggling}
            >
              {isToggling ? (
                <Spinner className="size-3.5" />
              ) : plan.isActive ? (
                <>
                  <PowerOff className="size-3.5" />
                  {t('deactivate')}
                </>
              ) : (
                <>
                  <Power className="size-3.5" />
                  {t('activate')}
                </>
              )}
            </Button>

            {!plan.isActive && (
              <Button
                variant="ghost"
                size="sm"
                className="text-destructive hover:bg-destructive/10 hover:text-destructive px-2"
                onClick={() => setIsConfirmingDelete(true)}
                title={t('delete')}
              >
                <Trash2 className="size-3.5" />
              </Button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
