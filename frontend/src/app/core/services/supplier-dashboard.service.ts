import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
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
  activeRfqs: number;
  submittedBids: number;
  supplierRating: number;
  isSetupCompleted: boolean;
  registrationStep: number;
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
  private apiUrl = `${environment.apiUrl}/suppliers/me/dashboard`;

  getDashboardStats(): Observable<SupplierDashboardStats> {
    return this.http.get<any>(this.apiUrl).pipe(
      map(backendData => {
        // The backend only returns { activeRfqs, submittedBids, supplierRating }
        // We mock the complex chart arrays so the UI looks beautiful
        return {
          activeRfqs: backendData.activeRfqs || 0,
          submittedBids: backendData.submittedBids || 0,
          supplierRating: backendData.supplierRating || 0,
          isSetupCompleted: backendData.isSetupCompleted || false,
          registrationStep: backendData.registrationStep || 1,
          revenueByPeriod: {
            '6m': [15, 22, 18, 30, 28, 42],
            '3m': [28, 42, 35],
            '1y': [10, 15, 22, 18, 30, 28, 42, 35, 45, 50, 48, 60]
          },
          revenueLabelsByPeriod: {
            '6m': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            '3m': ['Apr', 'May', 'Jun'],
            '1y': ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
          },
          weeklyOrders: [45, 60, 82, 55, 75, 91, 80],
          categorySegments: [
            { label: 'Beverages', value: 45, color: '#3B82F6' },
            { label: 'Snacks', value: 25, color: '#10B981' },
            { label: 'Dairy', value: 20, color: '#F59E0B' },
            { label: 'Other', value: 10, color: '#6B7280' }
          ],
          topProducts: [
            { icon: 'water', name: 'Naqi Water 330ml', units: '12,450', trend: 15, progress: 85, color: '#3B82F6' },
            { icon: 'juice', name: 'Almarai Orange', units: '8,320', trend: 8, progress: 65, color: '#F59E0B' }
          ],
          recentOrders: [
            { time: '10:45 AM', status: 'مقبول', total: '2,450 EGP', items: '45 items', category: 'Beverages', vendor: 'Supermarket Riyadh', orderId: 'ORD-1045' },
            { time: '09:30 AM', status: 'انتظار', total: '1,200 EGP', items: '12 items', category: 'Dairy', vendor: 'Baqalat Al-Amal', orderId: 'ORD-1044' },
            { time: 'Yesterday', status: 'بالطريق', total: '5,800 EGP', items: '120 items', category: 'Mixed', vendor: 'Qahwa Cafe', orderId: 'ORD-1043' }
          ]
        } as SupplierDashboardStats;
      })
    );
  }
}
