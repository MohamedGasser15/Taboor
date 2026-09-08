export enum BillingCycle {
  Monthly = 1,
  Yearly = 2,
}

export interface Plan {
  id: number
  name: string
  description?: string | null
  price: number
  billingCycle: BillingCycle
  maxBranches: number
  maxServices: number
  maxServicesPerBranch: number
  isActive: boolean
  createdAt: string
  updatedAt?: string | null
}

export interface CreatePlanInput {
  name: string
  description?: string
  price: number
  billingCycle: BillingCycle
  maxBranches: number
  maxServices: number
  maxServicesPerBranch: number
}

export type UpdatePlanInput = CreatePlanInput

export type { ApiResponse } from '#/types/api'
