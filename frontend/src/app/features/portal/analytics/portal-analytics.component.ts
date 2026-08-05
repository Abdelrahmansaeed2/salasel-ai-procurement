import { ChangeDetectionStrategy, Component, computed, signal, inject, OnInit } from '@angular/core';
import { AreaLineChartComponent } from '../ui/area-line-chart.component';
import { BarChartComponent } from '../ui/bar-chart.component';
import { DonutChartComponent, DonutSegment } from '../ui/donut-chart.component';
import { SparklineComponent } from '../ui/sparkline.component';
import { PaginationComponent } from '../ui/pagination.component';
import { AdminService } from '../../../core/services/admin.service';
import { take } from 'rxjs';

interface AnalyticsKpi {
  label: string;
  sublabel?: string;
  value: string;
  suffix?: string;
  change: string;
  trend: number[];
  iconBg: string;
  iconColor: string;
}

interface SupplierPerformanceRow {
  name: string;
  orders: number;
  revenue: string;
  performanceScore: number;
  onTime: number;
  trend: 'up' | 'down';
}

const MONTH_LABELS = ['يان', 'فبر', 'مار', 'أبر', 'ماي', 'يون', 'يول', 'أغس', 'سبت', 'أكت', 'نوف', 'ديس'];

@Component({
  selector: 'app-portal-analytics',
  standalone: true,
  imports: [AreaLineChartComponent, BarChartComponent, DonutChartComponent, SparklineComponent, PaginationComponent],
  templateUrl: './portal-analytics.component.html',
  styleUrl: './portal-analytics.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalAnalyticsComponent implements OnInit {
  private readonly adminService = inject(AdminService);

  readonly year = signal(2026);
  readonly yearMenuOpen = signal(false);

  readonly monthLabels = MONTH_LABELS;

  readonly kpis = signal<AnalyticsKpi[]>([
    { label: 'الطلبات', value: '...', change: '...', trend: [38, 46, 55, 50, 58, 66, 60, 72, 80, 90, 96, 98], iconBg: 'rgba(139,92,246,0.08)', iconColor: '#8B5CF6' },
    { label: 'الإيرادات', sublabel: '12 أشهر مجتمعة', value: '...', suffix: 'EGP', change: '...', trend: [36, 44, 52, 48, 56, 64, 60, 70, 78, 84, 92, 98], iconBg: 'rgba(37,99,235,0.08)', iconColor: '#2563EB' },
    { label: 'إجمالي التجار', value: '...', change: '...', trend: [42, 50, 58, 54, 62, 70, 66, 76, 82, 88, 94, 98], iconBg: 'rgba(16,185,129,0.08)', iconColor: '#10B981' },
    { label: 'إجمالي الموردين', value: '...', change: '...', trend: [45, 52, 60, 56, 64, 72, 68, 78, 84, 90, 95, 98], iconBg: 'rgba(245,158,11,0.08)', iconColor: '#F59E0B' },
  ]);

  ngOnInit() {
    this.adminService.getAnalytics().pipe(take(1)).subscribe((data) => {
      this.kpis.set([
        { label: 'الطلبات', value: data.totalOrders.toString(), change: '+12%', trend: [38, 46, 55, 50, 58, 66, 60, 72, 80, 90, 96, 98], iconBg: 'rgba(139,92,246,0.08)', iconColor: '#8B5CF6' },
        { label: 'الإيرادات', sublabel: 'GMV', value: data.totalGmv.toLocaleString(), suffix: 'EGP', change: '+8%', trend: [36, 44, 52, 48, 56, 64, 60, 70, 78, 84, 92, 98], iconBg: 'rgba(37,99,235,0.08)', iconColor: '#2563EB' },
        { label: 'إجمالي التجار', value: data.totalMerchants.toString(), change: '+5%', trend: [42, 50, 58, 54, 62, 70, 66, 76, 82, 88, 94, 98], iconBg: 'rgba(16,185,129,0.08)', iconColor: '#10B981' },
        { label: 'إجمالي الموردين', value: data.totalSuppliers.toString(), change: '+3%', trend: [45, 52, 60, 56, 64, 72, 68, 78, 84, 90, 95, 98], iconBg: 'rgba(245,158,11,0.08)', iconColor: '#F59E0B' },
      ]);
    });
  }

  readonly supplierDistribution: DonutSegment[] = [
    { label: 'الأندلس', value: 35, color: '#2563EB' },
    { label: 'الكنز', value: 28, color: '#8B5CF6' },
    { label: 'نقاء', value: 18, color: '#10B981' },
    { label: 'الزهرة', value: 12, color: '#F59E0B' },
    { label: 'أخرى', value: 7, color: '#94A3B8' },
  ];

  readonly monthlyRevenue = [28, 32, 38, 41, 39, 45, 50, 55, 52, 60, 68, 82];
  readonly orderVolume = [32, 28, 40, 45, 42, 48, 58, 62, 55, 68, 74, 88];

  private readonly allSuppliers: SupplierPerformanceRow[] = [
    { name: 'الأندلس للتوزيع', orders: 842, revenue: '1820K EGP', performanceScore: 96, onTime: 98, trend: 'up' },
    { name: 'الكنز للمواد الغذائية', orders: 631, revenue: '1456K EGP', performanceScore: 88, onTime: 92, trend: 'up' },
    { name: 'شركة نقاء', orders: 428, revenue: '936K EGP', performanceScore: 96, onTime: 98, trend: 'up' },
    { name: 'الزهرة للزيوت', orders: 315, revenue: '624K EGP', performanceScore: 70, onTime: 84, trend: 'down' },
    { name: 'مصنع الصفوة', orders: 187, revenue: '364K EGP', performanceScore: 50, onTime: 42, trend: 'down' },
  ];

  readonly page = signal(1);
  readonly pageSize = 5;
  readonly totalSuppliers = 128;
  readonly totalPages = Math.ceil(this.totalSuppliers / this.pageSize);

  readonly pagedSuppliers = computed(() => this.allSuppliers);

  toggleYearMenu() {
    this.yearMenuOpen.update((v) => !v);
  }

  selectYear(year: number) {
    this.year.set(year);
    this.yearMenuOpen.set(false);
  }

  goToPage(page: number) {
    this.page.set(page);
  }
}
