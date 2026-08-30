import type { AppUser } from "#/feature/auth/auth-types"

export function isPlatformAdmin(user: AppUser | null): boolean {
  return user?.role === "Admin"
}

export function isCustomer(user: AppUser | null): boolean {
  return user?.role === "Customer"
}

export function isUser(user: AppUser | null): boolean {
  return user?.role === "User"
}

export function isAllowedForDashboard(user: AppUser | null): boolean {
  return isPlatformAdmin(user) || isCustomer(user)
}