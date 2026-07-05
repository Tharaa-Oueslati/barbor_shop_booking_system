import {CanActivateFn, Router} from '@angular/router';
import {inject} from "@angular/core";
import {AuthentificationService} from "../services/authentification.service";

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthentificationService);
  const router = inject(Router);
  const currentUserRole= authService.getCurrentUser()?.role;

  if (authService.isLoggedIn()) {
    if (route.data['roles'].includes(currentUserRole)) {
      return true;
    }
    else{
      authService.logout();
      router.navigate(['/login']);
    }

  }
  else{
    if (route.data['roles'].includes("NONE")){
      return true;
    }
  }


  return false;
};
