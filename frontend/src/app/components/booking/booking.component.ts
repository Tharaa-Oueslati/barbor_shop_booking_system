import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { BookingService } from "../../services/booking.service";
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
    '15:00','15:30','16:00','16:30','17:00'
  ];

  blockedTimes: string[] = [];

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

  // ---------------- FORM INIT ----------------
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

  // ---------------- LOAD BARBERS ----------------
  getActiveBarbers() {
    this.barberService.getActiveBarbers().subscribe({
      next: (data) => this.activeBarbers = data,
      error: (err) => console.error('Error loading barbers:', err)
    });
  }

  // ---------------- LISTENERS ----------------
  initListeners() {
    this.bookingForm.get('date')?.valueChanges.subscribe(() => {
      this.checkAvailability();
    });

    this.bookingForm.get('barber')?.valueChanges.subscribe(() => {
      this.checkAvailability();
    });
  }

  // ---------------- LOAD SERVICES ----------------
  getServices() {
    this.haircutService.getServices().subscribe({
      next: (data) => this.servicesList = data,
      error: (err) => console.error('Error loading services:', err)
    });
  }

  // ---------------- AVAILABILITY CHECK ----------------
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
          const bookedSlots = res.blockedTimes || [];
          // Process existing slots to calculate the 1-hour block windows
          this.blockedTimes = this.calculateOneHourBlocks(bookedSlots);
        },
        error: (err) => {
          console.error('Error fetching blocked slots:', err);
          this.blockedTimes = [];
        }
      });
  }

  // ---------------- HELPER: 1-HOUR BLOCKING LOGIC ----------------
  private calculateOneHourBlocks(bookedSlots: string[]): string[] {
    const expandedBlocks = new Set<string>();

    bookedSlots.forEach(time => {
      const index = this.timeSlots.indexOf(time);

      if (index !== -1) {
        // 1. Block the exact booked slot (e.g., 10:00)
        expandedBlocks.add(this.timeSlots[index]);

        // 2. Block the next 30-min slot (e.g., 10:30) to fulfill the 1-hour duration
        if (index + 1 < this.timeSlots.length) {
          expandedBlocks.add(this.timeSlots[index + 1]);
        }

        // 3. Block the previous 30-min slot (e.g., 09:30) to prevent a new booking
        // from running into the start of this existing appointment
        if (index - 1 >= 0) {
          expandedBlocks.add(this.timeSlots[index - 1]);
        }
      }
    });

    // Convert Set back to array for template usage
    return Array.from(expandedBlocks);
  }

  // ---------------- SUBMIT ----------------
  onSubmit() {
    if (this.bookingForm.invalid) {
      this.bookingForm.markAllAsTouched();
      return;
    }

    this.bookingService.createBooking(this.bookingForm.value)
      .subscribe({
        next: () => {
          console.log('Booking created successfully');
          this.router.navigate(['/']);
        },
        error: (err) => {
          console.error('Booking failed:', err);
        }
      });
  }
}
