import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../../../environments/environment';

export interface SupplierSetupDto {
  facilityInfo: {
    legalName: string;
    businessType: string;
    registrationNumber: string;
    address: string;
  };
  contactInfo: {
    fullName: string;
    jobTitle: string;
    email: string;
    phoneNumber: string;
  };
  taxInfo: {
    vatNumber: string;
    taxId: string;
    isVatExempt: boolean;
  };
  warehouses: {
    warehouseName: string;
    capacity: string;
    lat: number;
    lng: number;
    city: string;
  }[];
}

@Injectable({
  providedIn: 'root'
})
export class SupplierService {
  private readonly http = inject(HttpClient);

  registerSupplier(data: SupplierSetupDto): Observable<any> {
    return this.http.post(`${environment.apiUrl}/suppliers/register`, data);
  }

  uploadDocuments(files: File[]): Observable<any> {
    const formData = new FormData();
    files.forEach((file) => {
      formData.append('files', file);
    });
    
    return this.http.post(`${environment.apiUrl}/suppliers/me/documents`, formData);
  }
}
