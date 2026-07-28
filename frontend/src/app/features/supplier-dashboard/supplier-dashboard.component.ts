import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';

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
export class SupplierDashboardComponent {
  readonly activeTab = signal<'overview' | 'documents' | 'rfqs'>('overview');

  readonly stats = signal<StatCard[]>([
    {
      title: 'حالة طلب التسجيل',
      value: 'قيد المراجعة',
      change: 'مكتمل بنسبة 87%',
      isPositive: true,
      icon: 'status-check',
    },
    {
      title: 'طلب عروض أسعار (RFQ)',
      value: '12 طلب نشط',
      change: '+3 هذا الأسبوع',
      isPositive: true,
      icon: 'rfq-bag',
    },
    {
      title: 'العروض المقدمة',
      value: '5 عروض',
      change: '2 في انتظار الترسية',
      isPositive: true,
      icon: 'bids',
    },
    {
      title: 'تقييم المورد المبدئي',
      value: 'ممتاز (4.8/5)',
      change: 'اعتماد آلي مبدئي',
      isPositive: true,
      icon: 'star-badge',
    },
  ]);

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
