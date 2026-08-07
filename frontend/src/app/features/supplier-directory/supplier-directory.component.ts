import { ChangeDetectionStrategy, Component, computed, signal, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { SupplierService } from '../../core/services/supplier.service';

interface FilterChip {
  id: string;
  label: string;
}

interface Supplier {
  id: number;
  name: string;
  city: string;
  reviewsCount: number;
  rating: number;
  isVerified: boolean;
  isAvailableNow: boolean;
  topProducts: string[];
  deliveryArea: string;
  logo: string;
}

@Component({
  selector: 'app-supplier-directory',
  standalone: true,
  imports: [FormsModule, RouterLink, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './supplier-directory.component.html',
  styleUrl: './supplier-directory.component.css',
})
export class SupplierDirectoryComponent {
  readonly cityQuery = signal('');
  readonly productQuery = signal('');
  readonly supplierNameQuery = signal('');
  readonly verifiedOnly = signal(true);

  readonly dropdownFilters: FilterChip[] = [
    { id: 'rating', label: 'التقييم' },
    { id: 'delivery-speed', label: 'سرعة التوصيل' },
    { id: 'min-order', label: 'الحد الأدنى للطلب' },
    { id: 'category', label: 'التصنيف' },
    { id: 'governorate', label: 'المحافظة' },
  ];

  private readonly supplierService = inject(SupplierService);
  private readonly suppliers = signal<Supplier[]>([]);

  readonly filteredSuppliers = computed(() => {
    const city = this.cityQuery().trim().toLowerCase();
    const product = this.productQuery().trim().toLowerCase();
    const name = this.supplierNameQuery().trim().toLowerCase();
    const verifiedOnly = this.verifiedOnly();

    return this.suppliers().filter((supplier) => {
      if (verifiedOnly && !supplier.isVerified) {
        return false;
      }
      if (city && !supplier.city.toLowerCase().includes(city)) {
        return false;
      }
      if (name && !supplier.name.toLowerCase().includes(name)) {
        return false;
      }
      if (product && !supplier.topProducts.some((item) => item.toLowerCase().includes(product))) {
        return false;
      }
      return true;
    });
  });

  constructor() {
    this.supplierService.getSuppliers().subscribe((data) => {
      // Map SupplierProfileDto to the UI Supplier interface
      const mapped = data.map(dto => ({
        id: dto.supplierID,
        name: dto.companyName || 'مورد مجهول',
        city: dto.warehouses?.length ? dto.warehouses[0].city : 'غير محدد',
        reviewsCount: Math.floor(Math.random() * 100) + 10, // Mock for now until reviews API is built
        rating: dto.reliabilityScore ? +(dto.reliabilityScore / 20).toFixed(1) : 4.0, // Scale 100 to 5
        isVerified: dto.isSetupCompleted,
        isAvailableNow: dto.isActiveForRouting,
        topProducts: ['غير متوفر'], // Would need products included in DTO
        deliveryArea: `التوصيل: ${dto.warehouses?.length ? dto.warehouses[0].city : 'غير محدد'}`,
        logo: 'assets/images/vertex-trade-logo.png', // Placeholder
      }));
      this.suppliers.set(mapped);
    });
  }

  toggleVerifiedOnly(): void {
    this.verifiedOnly.update((value) => !value);
  }

  onSearch(): void {
    
  }
}
