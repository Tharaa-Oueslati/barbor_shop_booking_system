import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http'; // 1. Import HttpClient
import { Observable } from 'rxjs'; // 2. Import Observable
import { environment } from '../../environments/environment'; // 3. Import your environment file
import {AppointmentModel} from "../../models/AppointmentModel";

@Injectable({
  providedIn: 'root'
})
export class BookingService {
  // 4. Define your backend bookings endpoint URL
  // If you used the Interceptor strategy from earlier, this can just be '/bookings'
  private apiUrl = `${environment.apiUrl}/appointments`;

  // 5. Inject HttpClient through the constructor
  constructor(private http: HttpClient) { }

  /**
   * Sends the booking form data to the backend API
   * @param bookingData Object containing fullName, phoneNumber, serviceSelection, barber, date, and time
   */
  createBooking(  bookingData: any): Observable<any> {
    return this.http.post<any>(this.apiUrl, bookingData);
  }
  getBlockedSlots(date: string, barberId: number) {
    return this.http.get<{ blockedTimes: string[] }>(
      `${this.apiUrl}/blocked-slots`,
      {
        params: {
          date,
          barberId
        }
      }
    );
  }
}
