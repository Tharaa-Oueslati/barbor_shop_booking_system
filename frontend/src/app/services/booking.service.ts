import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface CreateBookingRequest {
  clientName: string;
  clientPhone: string;
  clientEmail?: string;
  barberId: number;
  haircutTypeId: number;
  date: string;
  startTime: string;
}

export interface BookingResponse {
  id: number;
  clientName: string;
  clientPhone: string;
  clientEmail?: string;
  barberId: number;
  haircutTypeId: number;
  date: string;
  startTime: string;
  status: string;
}

@Injectable({
  providedIn: 'root'
})
export class BookingService {
  private apiUrl = `${environment.apiUrl}/appointments`;

  constructor(private http: HttpClient) {}

  createBooking(bookingData: CreateBookingRequest): Observable<BookingResponse> {
    return this.http.post<BookingResponse>(this.apiUrl, bookingData);
  }

  getBlockedSlots(date: string, barberId: number) {
    return this.http.get<{ blockedTimes: string[] }>(
      `${this.apiUrl}/blocked-slots`,
      {
        params: { date, barberId }
      }
    );
  }
}
