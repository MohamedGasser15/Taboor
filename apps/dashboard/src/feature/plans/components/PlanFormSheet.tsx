import { Button } from '#/components/ui/button'
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from '#/components/ui/field'
import { Input } from '#/components/ui/input'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from '#/components/ui/sheet'
import { Spinner } from '#/components/ui/spinner'
import { zodResolver } from '@hookform/resolvers/zod'
import { useEffect, useMemo, useState } from 'react'
import { Controller, useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { useCreatePlan, useUpdatePlan } from '../hooks/use-plans'
import { createPlanFormSchema } from '../plans-schema'
import type { PlanFormValues } from '../plans-schema'
import { BillingCycle } from '../plans-types'
import type { Plan } from '../plans-types'
import type { AxiosError } from 'axios'

interface PlanFormSheetProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  plan: Plan | null
}

export function PlanFormSheet({
  open,
  onOpenChange,
  plan,
}: PlanFormSheetProps) {
  const { t } = useTranslation('plans')
  const isEdit = !!plan

  const createPlan = useCreatePlan()
  const updatePlan = useUpdatePlan()

  const [errorMessage, setErrorMessage] = useState<string | null>(null)

  const resolver = useMemo(() => zodResolver(createPlanFormSchema(t)), [t])

  const form = useForm<PlanFormValues>({
    resolver,
    defaultValues: {
      name: '',
      description: '',
      price: 0,
      billingCycle: BillingCycle.Yearly,
      maxBranches: 1,
      maxServices: 5,
      maxServicesPerBranch: 2,
    },
  })

  const watchedPrice = form.watch('price')

  useEffect(() => {
    if (open) {
      setErrorMessage(null)
      if (plan) {
        form.reset({
          name: plan.name,
          description: plan.description ?? '',
          price: plan.price,
          billingCycle: plan.billingCycle,
          maxBranches: plan.maxBranches,
          maxServices: plan.maxServices,
          maxServicesPerBranch: plan.maxServicesPerBranch,
        })
      } else {
        form.reset({
          name: '',
          description: '',
          price: 0,
          billingCycle: BillingCycle.Yearly,
          maxBranches: 1,
          maxServices: 5,
          maxServicesPerBranch: 2,
        })
      }
    }
  }, [open, plan, form])

  const isSubmitting = createPlan.isPending || updatePlan.isPending

  const onSubmit = (values: PlanFormValues) => {
    setErrorMessage(null)

    const payload = {
      name: values.name.trim(),
      description: values.description?.trim() || undefined,
      price: Number(values.price),
      billingCycle: Number(values.billingCycle),
      maxBranches: Number(values.maxBranches),
      maxServices: Number(values.maxServices),
      maxServicesPerBranch: Number(values.maxServicesPerBranch),
    }

    if (isEdit) {
      updatePlan.mutate(
        { id: plan.id, data: payload },
        {
          onSuccess: () => {
            onOpenChange(false)
          },
          onError: (error) => {
            const err = error as AxiosError<{
              message?: string
              errors?: string[]
            }>
            const msg =
              err.response?.data.errors?.[0] ??
              err.response?.data.message ??
              t('form.saveError')
            setErrorMessage(msg)
          },
        },
      )
    } else {
      createPlan.mutate(payload, {
        onSuccess: () => {
          onOpenChange(false)
        },
        onError: (error) => {
          const err = error as AxiosError<{
            message?: string
            errors?: string[]
          }>
          const msg =
            err.response?.data.errors?.[0] ??
            err.response?.data.message ??
            t('form.saveError')
          setErrorMessage(msg)
        },
      })
    }
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="w-full sm:max-w-md overflow-y-auto" side="right">
        <SheetHeader>
          <SheetTitle>
            {isEdit
              ? t('form.titleEdit', { name: plan.name })
              : t('form.titleCreate')}
          </SheetTitle>
          <SheetDescription>{t('form.subtitle')}</SheetDescription>
        </SheetHeader>

        <form
          onSubmit={form.handleSubmit(onSubmit)}
          className="flex flex-1 flex-col justify-between gap-6 px-4 py-2"
        >
          {errorMessage && (
            <div
              className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-xs text-destructive"
              role="alert"
            >
              {errorMessage}
            </div>
          )}

          <FieldGroup className="space-y-4">
            {/* Plan Name */}
            <Controller
              name="name"
              control={form.control}
              render={({ field, fieldState }) => (
                <Field data-invalid={fieldState.invalid}>
                  <FieldLabel htmlFor={field.name}>
                    {t('form.name')} <span className="font-bold text-destructive">*</span>
                  </FieldLabel>
                  <Input
                    {...field}
                    id={field.name}
                    placeholder={t('form.namePlaceholder')}
                    aria-invalid={fieldState.invalid}
                  />
                  {fieldState.invalid && (
                    <FieldError errors={[fieldState.error]} />
                  )}
                </Field>
              )}
            />

            {/* Description */}
            <Controller
              name="description"
              control={form.control}
              render={({ field, fieldState }) => (
                <Field data-invalid={fieldState.invalid}>
                  <FieldLabel htmlFor={field.name}>
                    {t('form.description')}
                  </FieldLabel>
                  <Input
                    {...field}
                    id={field.name}
                    placeholder={t('form.descriptionPlaceholder')}
                    aria-invalid={fieldState.invalid}
                  />
                  {fieldState.invalid && (
                    <FieldError errors={[fieldState.error]} />
                  )}
                </Field>
              )}
            />

            {/* Yearly Price */}
            <Controller
              name="price"
              control={form.control}
              render={({ field, fieldState }) => (
                <Field data-invalid={fieldState.invalid}>
                  <FieldLabel htmlFor={field.name}>
                    {t('yearlyPrice')} ({t('egp')}){' '}
                    <span className="font-bold text-destructive">*</span>
                  </FieldLabel>
                  <Input
                    id={field.name}
                    name={field.name}
                    ref={field.ref}
                    onBlur={field.onBlur}
                    type="number"
                    min={0}
                    step="0.01"
                    value={field.value}
                    onChange={(e) =>
                      field.onChange(
                        e.target.value === '' ? '' : Number(e.target.value),
                      )
                    }
                    aria-invalid={fieldState.invalid}
                  />
                  {Number(watchedPrice) > 0 && (
                    <p className="mt-1 text-xs font-semibold text-teal">
                      {t('monthlyEquivalent', {
                        amount: (Number(watchedPrice) / 12).toLocaleString(
                          undefined,
                          {
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 2,
                          },
                        ),
                        currency: t('egp'),
                      })}
                    </p>
                  )}
                  {fieldState.invalid && (
                    <FieldError errors={[fieldState.error]} />
                  )}
                </Field>
              )}
            />

            <div className="border-t border-border pt-3">
              <h4 className="mb-3 text-xs font-bold tracking-wider text-muted-foreground uppercase">
                {t('limits')}
              </h4>

              <div className="space-y-3">
                {/* Max Branches */}
                <Controller
                  name="maxBranches"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel htmlFor={field.name}>
                        {t('form.maxBranches')}{' '}
                        <span className="font-bold text-destructive">*</span>
                      </FieldLabel>
                      <Input
                        id={field.name}
                        name={field.name}
                        ref={field.ref}
                        onBlur={field.onBlur}
                        type="number"
                        min={1}
                        value={field.value}
                        onChange={(e) =>
                          field.onChange(
                            e.target.value === '' ? '' : Number(e.target.value),
                          )
                        }
                        aria-invalid={fieldState.invalid}
                      />
                      {fieldState.invalid && (
                        <FieldError errors={[fieldState.error]} />
                      )}
                    </Field>
                  )}
                />

                {/* Max Catalog Services */}
                <Controller
                  name="maxServices"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel htmlFor={field.name}>
                        {t('form.maxServices')}{' '}
                        <span className="font-bold text-destructive">*</span>
                      </FieldLabel>
                      <Input
                        id={field.name}
                        name={field.name}
                        ref={field.ref}
                        onBlur={field.onBlur}
                        type="number"
                        min={1}
                        value={field.value}
                        onChange={(e) =>
                          field.onChange(
                            e.target.value === '' ? '' : Number(e.target.value),
                          )
                        }
                        aria-invalid={fieldState.invalid}
                      />
                      {fieldState.invalid && (
                        <FieldError errors={[fieldState.error]} />
                      )}
                    </Field>
                  )}
                />

                {/* Max Services Per Branch */}
                <Controller
                  name="maxServicesPerBranch"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel htmlFor={field.name}>
                        {t('form.maxServicesPerBranch')}{' '}
                        <span className="font-bold text-destructive">*</span>
                      </FieldLabel>
                      <Input
                        id={field.name}
                        name={field.name}
                        ref={field.ref}
                        onBlur={field.onBlur}
                        type="number"
                        min={1}
                        value={field.value}
                        onChange={(e) =>
                          field.onChange(
                            e.target.value === '' ? '' : Number(e.target.value),
                          )
                        }
                        aria-invalid={fieldState.invalid}
                      />
                      {fieldState.invalid && (
                        <FieldError errors={[fieldState.error]} />
                      )}
                    </Field>
                  )}
                />
              </div>
            </div>
          </FieldGroup>

          <SheetFooter className="mt-6 flex-row gap-2 border-t border-border pt-4">
            <Button
              type="button"
              variant="outline"
              className="flex-1"
              onClick={() => onOpenChange(false)}
            >
              {t('form.cancel')}
            </Button>
            <Button
              type="submit"
              className="flex-1 gap-2"
              disabled={isSubmitting}
            >
              {isSubmitting ? (
                <>
                  <Spinner className="size-4" />
                  {t('form.saving')}
                </>
              ) : (
                t('form.save')
              )}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
