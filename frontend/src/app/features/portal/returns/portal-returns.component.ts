import { ChangeDetectionStrategy, Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { ToastService } from '../../../core/services/toast.service';
import { AuthService } from '../../../core/auth/auth.service';

interface ReturnRequest {
  id: number;
  masterOrderId: number;
  reason: string;
  requestedAmount: number;
  approvedAmount?: number;
  status: string;
  createdAt: string;
  merchantName?: string;
}

@Component({
  selector: 'app-portal-returns',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './portal-returns.component.html',
  styleUrl: './portal-returns.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalReturnsComponent implements OnInit {
  private http = inject(HttpClient);
  private toast = inject(ToastService);
  private auth = inject(AuthService);

  readonly returns = signal<ReturnRequest[]>([]);
  readonly loading = signal(true);
  readonly userRole = this.auth.currentUser()?.role;

  ngOnInit() {
    this.fetchReturns();
  }

  fetchReturns() {
    this.loading.set(true);
    // Hardcoded baseUrl for MVP or we should use environment
    this.http.get<ReturnRequest[]>('https://salasel.otlob-egy.online/api/v1/returns').subscribe({
      next: (data) => {
        this.returns.set(data);
        this.loading.set(false);
      },
      error: (err) => {
        console.error(err);
        this.loading.set(false);
        this.toast.error('حدث خطأ أثناء جلب المرتجعات');
      }
    });
  }

  approveReturn(ret: ReturnRequest) {
    if (confirm(`هل أنت متأكد من الموافقة على الاسترجاع بمبلغ ${ret.requestedAmount}؟`)) {
      this.http.put(`https://salasel.otlob-egy.online/api/v1/returns/${ret.id}/approve`, ret.requestedAmount).subscribe({
        next: () => {
          this.toast.success('تمت الموافقة بنجاح');
          this.fetchReturns();
        },
        error: () => this.toast.error('فشلت العملية')
      });
    }
  }

  rejectReturn(ret: ReturnRequest) {
    if (confirm(`هل أنت متأكد من رفض طلب الاسترجاع؟`)) {
      this.http.put(`https://salasel.otlob-egy.online/api/v1/returns/${ret.id}/reject`, '"تم الرفض من قبل المورد"').subscribe({
        next: () => {
          this.toast.success('تم الرفض بنجاح');
          this.fetchReturns();
        },
        error: () => this.toast.error('فشلت العملية')
      });
    }
  }

  confirmReceipt(ret: ReturnRequest) {
    if (confirm('هل استلمت المنتجات المرتجعة فعلياً؟ (سيتم خصم المبلغ من رصيدك فوراً)')) {
      this.http.put(`https://salasel.otlob-egy.online/api/v1/returns/${ret.id}/confirm-receipt`, {}).subscribe({
        next: () => {
          this.toast.success('تم تأكيد الاستلام وتنفيذ الاسترجاع المالي بنجاح!');
          this.fetchReturns();
        },
        error: () => this.toast.error('فشلت عملية الدفع')
      });
    }
  }
}
