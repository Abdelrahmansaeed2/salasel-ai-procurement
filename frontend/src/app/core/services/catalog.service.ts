import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { delay, map } from 'rxjs/operators';
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
    return this.http.get<any[]>(this.apiUrl).pipe(
      map(items => items.map(item => {
        const qty = item.availableQty || 0;
        let status: StockStatus = 'available';
        let statusLabel = 'متوفر';
        
        if (qty === 0) {
          status = 'out';
          statusLabel = 'نفد المخزون';
        } else if (qty < 50) {
          status = 'low';
          statusLabel = 'مخزون منخفض';
        }

        return {
          sku: item.sku || `SKU-${item.id || Math.floor(Math.random() * 1000)}`,
          name: item.productName || 'منتج غير معروف',
          category: 'عام', // Backend doesn't currently return category name
          price: item.unitPrice?.toString() || '0',
          status: status,
          statusLabel: statusLabel,
          stockUnits: `${qty} كجم/كرتون`,
          stockPercent: qty > 100 ? 100 : qty,
        };
      }))
    );
  }

  updateCatalog(id: string, product: Partial<CatalogProduct>): Observable<CatalogProduct> {
    return this.http.put<CatalogProduct>(`${this.apiUrl}/${id}`, product);
  }
}
