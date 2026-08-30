export type UserRole =
  | "Admin"
  | "Customer"
  | "User"
  | "Taboor Admin"
  | "Taboor Customer"
  | "Taboor User"
  | "PlatformAdmin"

export interface AppUser {
  id: string,
  email: string;
  fullName: string;
  role: UserRole;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  refreshToken?: string | null;
  user: AppUser;
}

export interface RefreshResponse {
  accessToken: string;
  user: AppUser;
}

export interface ApiResponse<T> {
  data: T,
  message: string;
  success: boolean
}