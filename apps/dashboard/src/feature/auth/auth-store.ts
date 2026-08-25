import { create } from "zustand";
import type { AppUser } from "./auth-types";

interface AuthState {
  user: AppUser | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isInitializing: boolean;


  setAuth: (user: AppUser, accessToken: string) => void;
  setAccessToken: (accessToken: string, user: AppUser) => void;
  setInitializing: (value: boolean) => void;
  clearAuth: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  accessToken: null,
  isAuthenticated: false,
  isInitializing: false,

  setAuth: (user, accessToken) => 
    set({
      user,
      accessToken,
      isAuthenticated: true
    }),

  setAccessToken: (accessToken, user) => 
    set({
      accessToken, 
      user: user,
      isAuthenticated: true
    }),

    setInitializing: (value) =>
    set({
      isInitializing: value,
    }),
  
  clearAuth: () => 
    set({
      user: null,
      accessToken: null,
      isAuthenticated: false
    })
}))