import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface SupplierProfileDto {
  supplierID: number;
  companyName: string;
  contactPhone: string;
  crNumber: string;
  taxNumber: string;
  bankName: string;
  iban: string;
  registrationStep: number;
  isSetupCompleted: boolean;
  reliabilityScore: number;
  isActiveForRouting: boolean;
  warehouses: any[];
}

@Injectable({
  providedIn: 'root'
})
export class SupplierService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/v1/suppliers`;

  getSuppliers(): Observable<SupplierProfileDto[]> {
    return this.http.get<SupplierProfileDto[]>(this.apiUrl);
  }

  getSupplierById(id: number): Observable<SupplierProfileDto> {
    return this.http.get<SupplierProfileDto>(`${this.apiUrl}/${id}`);
  }
}
