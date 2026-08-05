import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';

type StockStatus = 'available' | 'low' | 'out';

interface CatalogProduct {
  sku: string;
  name: string;
  category: string;
  price: string;
  status: StockStatus;
  statusLabel: string;
  stockUnits: string;
  stockPercent: number;
}

@Component({
  selector: 'app-portal-catalog',
  standalone: true,
  templateUrl: './portal-catalog.component.html',
  styleUrl: './portal-catalog.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalCatalogComponent {
  readonly searchTerm = signal('');
  readonly currentPage = signal(1);
  readonly pageSize = 4;

  readonly products = signal<CatalogProduct[]>([
    {
      sku: 'COF-AR-500',
      name: 'قهوة أرابيكا فاخرة',
      category: 'مشروبات',
      price: '45.00 جنيه',
      status: 'available',
      statusLabel: 'متوفر',
      stockUnits: '1,240 وحدة',
      stockPercent: 82,
    },
    {
      sku: 'OIL-EV-1000',
      name: 'زيت زيتون عضوي',
      category: 'بقالة',
      price: '82.50 جنيه',
      status: 'low',
      statusLabel: 'مخزون منخفض',
      stockUnits: '42 وحدة',
      stockPercent: 8,
    },
    {
      sku: 'SLT-HM-250',
      name: 'ملح الهيمالايا',
      category: 'بقالة',
      price: '18.00 جنيه',
      status: 'available',
      statusLabel: 'متوفر',
      stockUnits: '560 وحدة',
      stockPercent: 45,
    },
    {
      sku: 'SPF-SAF-005',
      name: 'زعفران فاخر',
      category: 'توابل',
      price: '120.00 جنيه',
      status: 'out',
      statusLabel: 'نفذت الكمية',
      stockUnits: '0 وحدة',
      stockPercent: 0,
    },
  ]);

  readonly filteredProducts = computed(() => {
    const term = this.searchTerm().trim();
    if (!term) return this.products();
    return this.products().filter(
      (p) => p.name.includes(term) || p.sku.toLowerCase().includes(term.toLowerCase()),
    );
  });

  readonly totalPages = computed(() => Math.ceil(25 / 10));

  readonly inventoryValue = '85,150';
  readonly outOfStockCount = 3;
  readonly lowStockCount = 4;
  readonly activeCount = 118;

  updateSearch(value: string) {
    this.searchTerm.set(value);
  }

  goToPage(page: number) {
    this.currentPage.set(page);
  }
}
