import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface DashboardOrderRow {
  time: string;
  status: 'مقبول' | 'انتظار' | 'بالطريق';
  total: string;
  items: string;
  category: string;
  vendor: string;
  orderId: string;
}

export type ProductIcon = 'water' | 'grain' | 'juice' | 'milk' | 'oil';

export interface TopProduct {
  icon: ProductIcon;
  name: string;
  units: string;
  trend: number;
  progress: number;
  color: string;
}

export interface SupplierDashboardStats {
  revenueByPeriod: Record<'6m' | '3m' | '1y', number[]>;
  revenueLabelsByPeriod: Record<'6m' | '3m' | '1y', string[]>;
  weeklyOrders: number[];
  categorySegments: { label: string; value: number; color: string }[];
  topProducts: TopProduct[];
  recentOrders: DashboardOrderRow[];
}

@Injectable({
  providedIn: 'root'
})
export class SupplierDashboardService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/v1/suppliers/me/dashboard`;

  getDashboardStats(): Observable<SupplierDashboardStats> {
    return this.http.get<SupplierDashboardStats>(this.apiUrl);
  }
}
