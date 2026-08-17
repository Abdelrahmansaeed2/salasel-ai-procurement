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
  isStripeOnboardingComplete: boolean;
  businessType: string;
  address: string;
  jobTitle: string;
  coverageRadiusKm: number;
  paymentTerms: string;
  vatNumber: string;
  isVatExempt: boolean;
  warehouses: any[];
}

export interface UpdateSupplierProfileDto {
  companyName: string;
  contactPhone: string;
  bankName: string;
  iban: string;
  address: string;
  businessType: string;
  jobTitle: string;
  crNumber: string;
  taxNumber: string;
  vatNumber: string;
  isVatExempt: boolean;
  coverageRadiusKm: number;
  paymentTerms: string;
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

  getMe(): Observable<SupplierProfileDto> {
    return this.http.get<SupplierProfileDto>(`${this.apiUrl}/me`);
  }

  updateMe(data: UpdateSupplierProfileDto): Observable<SupplierProfileDto> {
    return this.http.put<SupplierProfileDto>(`${this.apiUrl}/me`, data);
  }

  createStripeAccountSession(supplierId: number): Observable<{ clientSecret: string }> {
    return this.http.post<{ clientSecret: string }>(`${environment.apiUrl}/v1/payments/supplier/${supplierId}/account-session`, {});
  }
}
