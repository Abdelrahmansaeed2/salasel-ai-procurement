import { inject } from '@angular/core';
import { Router, type CanActivateFn } from '@angular/router';
import { AuthService } from './auth.service';

export const roleGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  
  const user = auth.currentUser();
  const expectedRoles = route.data['roles'] as string[];

  if (user && expectedRoles && expectedRoles.includes(user.role)) {
    return true;
  }

  // If role doesn't match, redirect them to dashboard (or login if unauthorized)
  return router.parseUrl('/portal/dashboard');
};
