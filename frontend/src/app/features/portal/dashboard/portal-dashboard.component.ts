import { ChangeDetectionStrategy, Component, signal, inject, OnInit } from '@angular/core';
import { AreaLineChartComponent } from '../ui/area-line-chart.component';
import { DonutChartComponent, DonutSegment } from '../ui/donut-chart.component';
import { RadialGaugeComponent } from '../ui/radial-gauge.component';
import { SupplierDashboardService, DashboardOrderRow, TopProduct } from '../../../core/services/supplier-dashboard.service';


@Component({
  selector: 'app-portal-dashboard',
  standalone: true,
  imports: [AreaLineChartComponent, DonutChartComponent, RadialGaugeComponent],
  templateUrl: './portal-dashboard.component.html',
  styleUrl: './portal-dashboard.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalDashboardComponent implements OnInit {
  readonly period = signal<'6m' | '3m' | '1y'>('6m');
  readonly periodOpen = signal(false);

  readonly periodLabels: Record<'6m' | '3m' | '1y', string> = {
    '6m': 'Last 6 Months',
    '3m': 'Last 3 Months',
    '1y': 'Last 12 Months',
  };

  private dashboardService = inject(SupplierDashboardService);

  readonly revenueByPeriod = signal<Record<'6m' | '3m' | '1y', number[]>>({
    '6m': [], '3m': [], '1y': []
  });

  readonly revenueLabelsByPeriod = signal<Record<'6m' | '3m' | '1y', string[]>>({
    '6m': [], '3m': [], '1y': []
  });

  readonly weeklyOrders = signal<number[]>([]);
  readonly categorySegments = signal<DonutSegment[]>([]);
  readonly topProducts = signal<TopProduct[]>([]);
  readonly recentOrders = signal<DashboardOrderRow[]>([]);

  ngOnInit() {
    this.dashboardService.getDashboardStats().subscribe({
      next: (stats) => {
        this.revenueByPeriod.set(stats.revenueByPeriod);
        this.revenueLabelsByPeriod.set(stats.revenueLabelsByPeriod);
        this.weeklyOrders.set(stats.weeklyOrders);
        this.categorySegments.set(stats.categorySegments);
        this.topProducts.set(stats.topProducts);
        this.recentOrders.set(stats.recentOrders);
      },
      error: (err) => console.error('Failed to load dashboard stats', err)
    });
  }

  readonly statusStyles: Record<DashboardOrderRow['status'], string> = {
    مقبول: 'status-accepted',
    انتظار: 'status-pending',
    بالطريق: 'status-transit',
  };

  togglePeriodMenu() {
    this.periodOpen.update((v) => !v);
  }

  selectPeriod(period: '6m' | '3m' | '1y') {
    this.period.set(period);
    this.periodOpen.set(false);
  }
}
