import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HaircutService } from "../../services/haircut.service";
import { HaircutModel } from "../../../models/haircut.model";
import { Router } from "@angular/router";
import { AuthentificationService } from "../../services/authentification.service";
import { UserModel} from "../../../models/UserModel";
import {AppointmentsService} from "../../services/appointments.service";
import {AppointmentModel} from "../../../models/AppointmentModel";

@Component({
  selector: 'app-homepage',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './homepage.component.html',
  styleUrl: './homepage.component.css'
})
export class HomepageComponent implements OnInit {

  servicesList: HaircutModel[] = [];
  isLoggedIn = false;
  currentUser: UserModel | null = null;
  validAppointments: AppointmentModel[] = [];

  constructor(
    private haircutService: HaircutService,
    private router: Router,
    private authService: AuthentificationService,
    private appointmentsService: AppointmentsService
  ) {}

  ngOnInit(): void {
    this.getServices();
    this.isLoggedIn  = this.authService.isLoggedIn();
    this.currentUser = this.authService.getCurrentUser();
    if(this.currentUser){
      this.getValidAppointments(this.currentUser.username);
    }

  }

  getServices() {
    this.haircutService.getServices().subscribe({
      next: (data: HaircutModel[]) => {
        this.servicesList = data;
      },
      error: (error) => {
        console.error('There was an error fetching the services!', error);
      }
    });
  }

  getValidAppointments(clientName: string) {
    this.appointmentsService.getValidAppointments(clientName).subscribe({
      next: (data) => {
        this.validAppointments = data;
      },
      error: (err) => {
        console.error('Error fetching valid appointments', err);
      }
    });
  }

  NavigateToBooking() {
    this.router.navigate(['/booking']);
  }

  NavigateToLogin() {
    this.router.navigate(['/login']);
  }


}
