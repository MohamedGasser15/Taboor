import { z } from "zod";

export const loginSchema = z.object({
  email: z
    .string()
    .trim()
    .email("please enter a valid email address"),

  password: z
    .string()
    .min(8, "password has to be at least 8 characters")
    .regex(/[A-Z]/, { message: "Must contain at least one uppercase letter" })
});

export type LoginFormValues = z.infer<typeof loginSchema>;