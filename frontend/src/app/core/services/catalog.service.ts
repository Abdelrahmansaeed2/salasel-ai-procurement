import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export type StockStatus = 'available' | 'low' | 'out';

export interface CatalogProduct {
  sku: string;
  name: string;
  category: string;
  price: string;
  status: StockStatus;
  statusLabel: string;
  stockUnits: string;
  stockPercent: number;
}

@Injectable({
  providedIn: 'root'
})
export class CatalogService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/suppliers/me/products`;

  getCatalogs(): Observable<CatalogProduct[]> {
    return this.http.get<CatalogProduct[]>(this.apiUrl);
  }

  updateCatalog(id: string, product: Partial<CatalogProduct>): Observable<CatalogProduct> {
    return this.http.put<CatalogProduct>(`${this.apiUrl}/${id}`, product);
  }
}
