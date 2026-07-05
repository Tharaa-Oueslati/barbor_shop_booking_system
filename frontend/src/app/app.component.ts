import { Component } from '@angular/core';
import {Router, RouterLink, RouterOutlet} from '@angular/router';
import { AuthentificationService } from "./services/authentification.service";
import { UserModel } from "../models/UserModel";
import { TranslateModule } from '@ngx-translate/core';
import { LanguageSwitcherComponent } from './components/language-switcher/language-switcher.component';
import {CapitalizeWordsPipe} from "./pipes/capitalize-words.pipe";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, TranslateModule, LanguageSwitcherComponent, CapitalizeWordsPipe,RouterLink],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title: string = "Barber Shop Booking System";
  isLoggedIn = false;
  currentUser: UserModel | null = null;
  protected readonly CapitalizeWordsPipe = CapitalizeWordsPipe;



  constructor(
    private authService: AuthentificationService,
    private router: Router
  ) {
    this.authService.user$.subscribe(user => {
      this.currentUser = user;
      this.isLoggedIn = !!user;
    });
  }

  bookNow(): void {
    this.router.navigate(['/booking']);
  }

  login(): void {
    this.router.navigate(['/login']);
  }

  logout(): void {
    this.authService.logout();
    window.location.reload();
    this.router.navigate(["/"])
  }


}
