import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { AreaLineChartComponent } from '../ui/area-line-chart.component';
import { DonutChartComponent, DonutSegment } from '../ui/donut-chart.component';
import { RadialGaugeComponent } from '../ui/radial-gauge.component';

interface DashboardOrderRow {
  time: string;
  status: 'مقبول' | 'انتظار' | 'بالطريق';
  total: string;
  items: string;
  category: string;
  vendor: string;
  orderId: string;
}

type ProductIcon = 'water' | 'grain' | 'juice' | 'milk' | 'oil';

interface TopProduct {
  icon: ProductIcon;
  name: string;
  units: string;
  trend: number;
  progress: number;
  color: string;
}

@Component({
  selector: 'app-portal-dashboard',
  standalone: true,
  imports: [AreaLineChartComponent, DonutChartComponent, RadialGaugeComponent],
  templateUrl: './portal-dashboard.component.html',
  styleUrl: './portal-dashboard.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalDashboardComponent {
  readonly period = signal<'6m' | '3m' | '1y'>('6m');
  readonly periodOpen = signal(false);

  readonly periodLabels: Record<'6m' | '3m' | '1y', string> = {
    '6m': 'Last 6 Months',
    '3m': 'Last 3 Months',
    '1y': 'Last 12 Months',
  };

  readonly revenueByPeriod: Record<'6m' | '3m' | '1y', number[]> = {
    '6m': [42, 58, 71, 55, 68, 90],
    '3m': [55, 68, 90],
    '1y': [30, 34, 40, 38, 45, 42, 58, 71, 55, 68, 90, 96],
  };

  readonly revenueLabelsByPeriod: Record<'6m' | '3m' | '1y', string[]> = {
    '6m': ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
    '3m': ['Aug', 'Sep', 'Oct'],
    '1y': ['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
  };

  readonly weeklyOrders = [38, 62, 53, 82, 91, 67, 48];

  readonly categorySegments: DonutSegment[] = [
    { label: 'مشروبات', value: 34, color: '#2563EB' },
    { label: 'حبوب', value: 22, color: '#22C55E' },
    { label: 'ألبان', value: 18, color: '#F59E0B' },
    { label: 'منظفات', value: 14, color: '#8B5CF6' },
    { label: 'أخرى', value: 12, color: '#E2E8F0' },
  ];

  readonly topProducts: TopProduct[] = [
    { icon: 'water', name: 'مياه معدنية ٥٠٠مل', units: '840 وحدة', trend: 12, progress: 100, color: '#2563EB' },
    { icon: 'grain', name: 'أرز بسمتي ٥ كيلو', units: '620 وحدة', trend: 8, progress: 84, color: '#22C55E' },
    { icon: 'juice', name: 'عصير برتقال ٢٥٠مل', units: '410 وحدة', trend: -3, progress: 55, color: '#F59E0B' },
    { icon: 'milk', name: 'حليب كامل الدسم', units: '380 وحدة', trend: 19, progress: 51, color: '#8B5CF6' },
    { icon: 'oil', name: 'زيت زيتون ١ لتر', units: '290 وحدة', trend: 5, progress: 39, color: '#94A3B8' },
  ];

  readonly recentOrders: DashboardOrderRow[] = [
    { time: 'منذ ٥ د', status: 'بالطريق', total: '4,200.00 جنيه', items: '3 أصناف', category: 'الموردين', vendor: 'محل أبو أحمد', orderId: '#TR-88219' },
    { time: 'منذ ١٢ د', status: 'مقبول', total: '12,840.50 جنيه', items: '2 أصناف', category: 'الرعاية الصحية', vendor: 'متجر الأمانة', orderId: '#TR-88220' },
    { time: 'منذ ٢ س', status: 'انتظار', total: '980.00 جنيه', items: '5 أصناف', category: 'طاقة', vendor: 'Energeia Systems', orderId: '#TR-88221' },
  ];

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
