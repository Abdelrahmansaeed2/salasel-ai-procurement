import { ChangeDetectionStrategy, Component, computed, signal, inject, OnInit } from '@angular/core';
import { CatalogService, CatalogProduct, StockStatus } from '../../../core/services/catalog.service';



@Component({
  selector: 'app-portal-catalog',
  standalone: true,
  templateUrl: './portal-catalog.component.html',
  styleUrl: './portal-catalog.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
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
