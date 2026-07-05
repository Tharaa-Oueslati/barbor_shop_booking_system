import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HaircutService } from "../../services/haircut.service";
import { HaircutModel } from "../../../models/haircut.model";
import { Router } from "@angular/router";
import { AuthentificationService } from "../../services/authentification.service";
import { UserModel } from "../../../models/UserModel";
import { AppointmentsService } from "../../services/appointments.service";
import { AppointmentModel } from "../../../models/AppointmentModel";
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import {CapitalizeWordsPipe} from "../../pipes/capitalize-words.pipe";

@Component({
  selector: 'app-homepage',
  standalone: true,
  imports: [CommonModule, TranslateModule, CapitalizeWordsPipe],
  templateUrl: './homepage.component.html',
  styleUrl: './homepage.component.css'
})
export class HomepageComponent implements OnInit {
  protected readonly CapitalizeWordsPipe = CapitalizeWordsPipe;
  servicesList: HaircutModel[] = [];
  isLoggedIn = false;
  currentUser: UserModel | null = null;
  validAppointments: AppointmentModel[] = [];

  // Cancellation modal state
  appointmentToCancel: AppointmentModel | null = null;
  isCancelling = false;
  cancelError: string | null = null;

  constructor(
    private haircutService: HaircutService,
    private router: Router,
    private authService: AuthentificationService,
    private appointmentsService: AppointmentsService,
    private translate: TranslateService
  ) {}

  ngOnInit(): void {
    this.getServices();
    this.isLoggedIn  = this.authService.isLoggedIn();
    this.currentUser = this.authService.getCurrentUser();
    if (this.currentUser) {
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

  // Only pending/confirmed tickets are cancellable — opens the confirmation modal
  onTicketClick(appointment: AppointmentModel) {
    if (appointment.status !== 'PENDING' && appointment.status !== 'CONFIRMED') {
      return;
    }
    this.appointmentToCancel = appointment;
    this.cancelError = null;
  }

  closeCancelModal() {
    if (this.isCancelling) return; // don't allow closing mid-request
    this.appointmentToCancel = null;
    this.cancelError = null;
  }

  confirmCancelAppointment() {
    if (!this.appointmentToCancel) return;

    const id = this.appointmentToCancel.id;
    this.isCancelling = true;
    this.cancelError = null;

    this.appointmentsService.cancelAppointments(id).subscribe({
      next: () => {
        // Reflect the cancellation locally instead of refetching everything
        const target = this.validAppointments.find(a => a.id === id);
        if (target) {
          target.status = 'CANCELLED';
        }
        this.isCancelling = false;
        this.appointmentToCancel = null;
      },
      error: (err) => {
        console.error('Error cancelling appointment', err);
        this.cancelError = this.translate.instant('errors.generic');
        this.isCancelling = false;
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
