import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { BookingService, CreateBookingRequest } from "../../services/booking.service";
import { Router } from "@angular/router";
import { HaircutService } from "../../services/haircut.service";
import { HaircutModel } from "../../../models/haircut.model";
import { NgClass } from '@angular/common';
import { BarberModel } from "../../../models/BarberModel";
import { BarberService } from "../../services/barber.service";

@Component({
  selector: 'app-booking',
  standalone: true,
  imports: [ReactiveFormsModule, NgClass],
  templateUrl: './booking.component.html',
  styleUrl: './booking.component.css'
})
export class BookingComponent implements OnInit {

  servicesList: HaircutModel[] = [];
  activeBarbers: BarberModel[] = [];
  bookingForm!: FormGroup;

  timeSlots: string[] = [
    '09:00','09:30','10:00','10:30','11:00','11:30',
    '12:00','12:30','13:00','13:30','14:00','14:30',
    '15:00','15:30','16:00','16:30','17:00','17:30'
  ];

  blockedTimes: string[] = [];
  isSubmitting = false;
  errorMessage: string | null = null;
  successMessage: string | null = null;
  todayDate: string = new Date().toISOString().split('T')[0];

  constructor(
    private fb: FormBuilder,
    private bookingService: BookingService,
    private haircutService: HaircutService,
    private router: Router,
    private barberService: BarberService,
  ) {}

  ngOnInit(): void {
    this.initForm();
    this.getServices();
    this.getActiveBarbers();
    this.initListeners();
  }

  initForm() {
    this.bookingForm = this.fb.group({
      fullName: ['', Validators.required],
      phoneNumber: ['', [Validators.required, Validators.pattern('^[0-9+ ]{8,15}$')]],
      email: [''],
      serviceSelection: ['', Validators.required],
      barber: ['', Validators.required],
      date: ['', Validators.required],
      time: ['', Validators.required]
    });
  }

  getActiveBarbers() {
    this.barberService.getActiveBarbers().subscribe({
      next: (data) => this.activeBarbers = data,
      error: (err) => {
        console.error('Error loading barbers:', err);
        this.errorMessage = 'Failed to load barbers. Please try again.';
      }
    });
  }

  initListeners() {
    this.bookingForm.get('date')?.valueChanges.subscribe(() => {
      this.checkAvailability();
    });

    this.bookingForm.get('barber')?.valueChanges.subscribe(() => {
      this.checkAvailability();
    });

    this.bookingForm.get('serviceSelection')?.valueChanges.subscribe(() => {
      this.checkAvailability();
    });
  }

  getServices() {
    this.haircutService.getServices().subscribe({
      next: (data) => this.servicesList = data,
      error: (err) => {
        console.error('Error loading services:', err);
        this.errorMessage = 'Failed to load services. Please try again.';
      }
    });
  }

  getSelectedServiceDuration(): number {
    const serviceId = this.bookingForm.get('serviceSelection')?.value;
    if (!serviceId) return 60;
    const service = this.servicesList.find(s => s.id === Number(serviceId));
    return service?.duration || 60;
  }

  checkAvailability() {
    const date = this.bookingForm.get('date')?.value;
    const barberId = Number(this.bookingForm.get('barber')?.value);

    if (!date || !barberId) {
      this.blockedTimes = [];
      return;
    }

    this.blockedTimes = [];

    this.bookingService.getBlockedSlots(date, barberId)
      .subscribe({
        next: (res) => {
          const occupiedSlots = res.blockedTimes || [];
          const duration = this.getSelectedServiceDuration();
          this.blockedTimes = this.calculateUnavailableStartTimes(occupiedSlots, duration);
        },
        error: (err) => {
          console.error('Error fetching blocked slots:', err);
          this.blockedTimes = [];
        }
      });
  }

  private calculateUnavailableStartTimes(occupiedSlots: string[], serviceDuration: number): string[] {
    const unavailable = new Set<string>();
    const slotsNeeded = Math.ceil(serviceDuration / 30);

    for (let startIndex = 0; startIndex < this.timeSlots.length; startIndex++) {
      for (let offset = 0; offset < slotsNeeded; offset++) {
        const checkIndex = startIndex + offset;
        if (checkIndex < this.timeSlots.length && occupiedSlots.includes(this.timeSlots[checkIndex])) {
          unavailable.add(this.timeSlots[startIndex]);
          break;
        }
      }

      const endIndex = startIndex + slotsNeeded;
      if (endIndex > this.timeSlots.length) {
        unavailable.add(this.timeSlots[startIndex]);
      }
    }

    return Array.from(unavailable);
  }

  onSubmit() {
    if (this.bookingForm.invalid) {
      this.bookingForm.markAllAsTouched();
      return;
    }

    this.isSubmitting = true;
    this.errorMessage = null;
    this.successMessage = null;

    const formValue = this.bookingForm.value;
    const request: CreateBookingRequest = {
      clientName: formValue.fullName,
      clientPhone: formValue.phoneNumber,
      clientEmail: formValue.email || undefined,
      barberId: Number(formValue.barber),
      haircutTypeId: Number(formValue.serviceSelection),
      date: formValue.date,
      startTime: formValue.time
    };

    this.bookingService.createBooking(request)
      .subscribe({
        next: (response) => {
          this.isSubmitting = false;
          this.successMessage = `Appointment booked successfully! Your booking ID is ${response.id}.`;
          this.bookingForm.reset();
          setTimeout(() => {
            this.router.navigate(['/']);
          }, 2000);
        },
        error: (err) => {
          this.isSubmitting = false;
          console.error('Booking failed:', err);
          this.errorMessage = err.error?.message || 'Failed to create appointment. The selected time slot may no longer be available.';
        }
      });
  }
}
