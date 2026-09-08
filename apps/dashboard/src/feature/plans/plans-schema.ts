import { z } from 'zod'
import type { TFunction } from 'i18next'
import { BillingCycle } from './plans-types'

export const createPlanFormSchema = (t: TFunction) =>
  z
    .object({
      name: z
        .string()
        .trim()
        .min(1, { message: t('plans:form.nameRequired') })
        .max(100, { message: t('plans:form.nameMax') }),
      description: z
        .string()
        .max(500, { message: t('plans:form.descriptionMax') })
        .optional()
        .or(z.literal('')),
      price: z
        .number({ message: t('plans:form.priceRequired') })
        .min(0, { message: t('plans:form.priceMin') }),
      billingCycle: z.nativeEnum(BillingCycle, {
        message: t('plans:form.billingCycleInvalid'),
      }),
      maxBranches: z
        .number({ message: t('plans:form.maxBranchesRequired') })
        .int({ message: t('plans:form.mustBeInteger') })
        .min(1, { message: t('plans:form.minOne') }),
      maxServices: z
        .number({ message: t('plans:form.maxServicesRequired') })
        .int({ message: t('plans:form.mustBeInteger') })
        .min(1, { message: t('plans:form.minOne') }),
      maxServicesPerBranch: z
        .number({ message: t('plans:form.maxServicesPerBranchRequired') })
        .int({ message: t('plans:form.mustBeInteger') })
        .min(1, { message: t('plans:form.minOne') }),
    })
    .refine((data) => data.maxServicesPerBranch <= data.maxServices, {
      message: t('plans:form.servicesPerBranchExceedsTotal'),
      path: ['maxServicesPerBranch'],
    })

export type PlanFormValues = z.infer<ReturnType<typeof createPlanFormSchema>>
