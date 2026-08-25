import { ChangeDetectionStrategy, Component, computed, signal, inject, OnInit } from '@angular/core';
import { CatalogService, CatalogProduct, StockStatus } from '../../../core/services/catalog.service';



@Component({
  selector: 'app-portal-catalog',
  standalone: true,
  templateUrl: './portal-catalog.component.html',
  styleUrl: './portal-catalog.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { dir: 'ltr' }
})
export class PortalCatalogComponent implements OnInit {
  readonly searchTerm = signal('');
  readonly currentPage = signal(1);
  readonly pageSize = 4;

  private catalogService = inject(CatalogService);
  
  readonly products = signal<CatalogProduct[]>([]);
  
  ngOnInit() {
    this.catalogService.getCatalogs().subscribe({
      next: (res) => this.products.set(res),
      error: (err) => console.error('Error fetching catalog', err)
    });
  }

  readonly filteredProducts = computed(() => {
    const term = this.searchTerm().trim().toLowerCase();
    
    // 1. Filter
    const filtered = term 
      ? this.products().filter((p) => p.name.toLowerCase().includes(term) || p.sku.toLowerCase().includes(term))
      : this.products();
      
    // 2. Paginate
    const startIndex = (this.currentPage() - 1) * this.pageSize;
    return filtered.slice(startIndex, startIndex + this.pageSize);
  });
  
  readonly totalItems = computed(() => {
    const term = this.searchTerm().trim().toLowerCase();
    if (!term) return this.products().length;
    return this.products().filter((p) => p.name.toLowerCase().includes(term) || p.sku.toLowerCase().includes(term)).length;
  });

  readonly totalPages = computed(() => Math.ceil(this.totalItems() / this.pageSize) || 1);

  readonly inventoryValue = '85,150';
  readonly outOfStockCount = 3;
  readonly lowStockCount = 4;
  readonly activeCount = 118;

  math = Math;

  updateSearch(value: string) {
    this.searchTerm.set(value);
    this.currentPage.set(1); // Reset to first page on search
  }

  goToPage(page: number) {
    if (page >= 1 && page <= this.totalPages()) {
      this.currentPage.set(page);
    }
  }

  getPagesArray(): number[] {
    const total = this.totalPages();
    const pages = [];
    for (let i = 1; i <= total; i++) {
      pages.push(i);
    }
    return pages;
  }
}
