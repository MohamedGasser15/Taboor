export type UserRole = "User" | "Customer" | "Admin"

export interface AppUser {
  id: string,
  email: string;
  fullname: string;
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
}

export interface ApiResponse<T> {
  data: T,
  message: string;
  success: boolean
}