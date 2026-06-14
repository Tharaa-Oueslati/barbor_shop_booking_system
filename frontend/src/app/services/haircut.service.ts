import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { environment } from "../../environments/environment";
import {HaircutModel} from "../../models/haircut.model";
// It's a best practice to define the shape of your data


@Injectable({
  providedIn: 'root'
})
export class HaircutService {
  // Your Spring Boot API endpoint
  private apiUrl = environment.apiUrl;

  // Inject the HttpClient
  constructor(private http: HttpClient) { }

  getServices(): Observable<HaircutModel[]> {
    return this.http.get<HaircutModel[]>(this.apiUrl+"/haircuts/services");
  }
}
