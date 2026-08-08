import { ChangeDetectionStrategy, Component, signal, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SupplierDashboardService } from '../../core/services/supplier-dashboard.service';

interface StatCard {
  title: string;
  value: string;
  change: string;
  isPositive: boolean;
  icon: string;
}

interface ActionTile {
  title: string;
  description: string;
  route: string;
  badge?: string;
  icon: string;
}

interface ActivityItem {
  id: string;
  title: string;
  timestamp: string;
  type: 'info' | 'success' | 'warning';
  icon: string;
}

@Component({
  selector: 'app-supplier-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './supplier-dashboard.component.html',
  styleUrl: './supplier-dashboard.component.css',
})
export class SupplierDashboardComponent implements OnInit {
  readonly activeTab = signal<'overview' | 'documents' | 'rfqs'>('overview');

  private readonly dashboardService = inject(SupplierDashboardService);

  readonly stats = signal<StatCard[]>([
    {
      title: 'حالة طلب التسجيل',
      value: 'جاري التحميل...',
      change: '',
      isPositive: true,
      icon: 'status-check',
    },
    {
      title: 'طلب عروض أسعار (RFQ)',
      value: '...',
      change: '',
      isPositive: true,
      icon: 'rfq-bag',
    },
    {
      title: 'العروض المقدمة',
      value: '...',
      change: '',
      isPositive: true,
      icon: 'bids',
    },
    {
      title: 'تقييم المورد المبدئي',
      value: '...',
      change: '',
      isPositive: true,
      icon: 'star-badge',
    },
  ]);

  ngOnInit() {
    this.dashboardService.getDashboardStats().subscribe({
      next: (data) => {
        let registrationStatus = 'قيد المراجعة';
        let registrationChange = `مكتمل بنسبة ${Math.round((data.registrationStep / 7) * 100)}%`;
        if (data.isSetupCompleted) {
          registrationStatus = 'مكتمل ومعتمد';
          registrationChange = 'حساب نشط';
        }

        this.stats.set([
          {
            title: 'حالة طلب التسجيل',
            value: registrationStatus,
            change: registrationChange,
            isPositive: data.isSetupCompleted,
            icon: 'status-check',
          },
          {
            title: 'طلب عروض أسعار (RFQ)',
            value: `${data.activeRfqs} طلب نشط`,
            change: 'متاحة للرد',
            isPositive: data.activeRfqs > 0,
            icon: 'rfq-bag',
          },
          {
            title: 'العروض المقدمة',
            value: `${data.submittedBids} عروض`,
            change: 'قيد المراجعة من المشتري',
            isPositive: data.submittedBids > 0,
            icon: 'bids',
          },
          {
            title: 'تقييم المورد المبدئي',
            value: `(${data.supplierRating}/5)`,
            change: 'اعتماد آلي مبدئي',
            isPositive: data.supplierRating >= 4.0,
            icon: 'star-badge',
          },
        ]);
      },
      error: (err) => console.error('Failed to load dashboard stats', err)
    });
  }

  readonly quickActions = signal<ActionTile[]>([
    {
      title: 'مراجعة طلب التسجيل',
      description: 'متابعة وتعديل بيانات ملف المنشأة والرخص التجارية',
      route: '/supplier-registration',
      badge: 'الخطوة 7 من 8',
      icon: 'file-text',
    },
    {
      title: 'تصفح طلبات الشراء الناشطة',
      description: 'استكشاف طلبات عروض الأسعار المناسبة لنشاطك التجاري',
      route: '/suppliers',
      badge: 'جديد',
      icon: 'search-rfq',
    },
    {
      title: 'مركز الدعم والتعليمات',
      description: 'الوصول إلى أدلة الاستخدام والاستفسارات الشائعة',
      route: '/help-center',
      icon: 'help-circle',
    },
  ]);

  readonly recentActivities = signal<ActivityItem[]>([
    {
      id: 'act-1',
      title: 'تم تقديم طلب التسجيل بنجاح - ملف رقم #SL-9402',
      timestamp: 'منذ ساعتين',
      type: 'success',
      icon: 'check',
    },
    {
      id: 'act-2',
      title: 'تمت مطابقة السجل التجاري آلياً مع المركز السعودي للأعمال',
      timestamp: 'منذ 3 ساعات',
      type: 'info',
      icon: 'shield-check',
    },
    {
      id: 'act-3',
      title: 'دعوة جديدة للمشاركة في منافسة توريد مواد لوجستية',
      timestamp: 'أمس، 04:30 م',
      type: 'info',
      icon: 'bell',
    },
  ]);

  setTab(tab: 'overview' | 'documents' | 'rfqs'): void {
    this.activeTab.set(tab);
  }
}
