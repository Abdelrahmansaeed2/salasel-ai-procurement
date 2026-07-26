import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';

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

  readonly suppliers: Supplier[] = [
    {
      id: 1,
      name: 'فيرتكس للتجارة العامة',
      city: 'القاهرة، مدينة نصر',
      reviewsCount: 124,
      rating: 4.8,
      isVerified: true,
      isAvailableNow: true,
      topProducts: ['معدات تقنية', 'أدوات مكتبية'],
      deliveryArea: 'التوصيل: جميع أنحاء القاهرة والجيزة',
      logo: 'assets/images/vertex-trade-logo.png',
    },
    {
      id: 2,
      name: 'فيرتكس للتجارة العامة',
      city: 'القاهرة، مدينة نصر',
      reviewsCount: 124,
      rating: 4.8,
      isVerified: true,
      isAvailableNow: true,
      topProducts: ['معدات تقنية', 'أدوات مكتبية'],
      deliveryArea: 'التوصيل: جميع أنحاء القاهرة والجيزة',
      logo: 'assets/images/vertex-trade-logo.png',
    },
    {
      id: 3,
      name: 'فيرتكس للتجارة العامة',
      city: 'القاهرة، مدينة نصر',
      reviewsCount: 124,
      rating: 4.8,
      isVerified: true,
      isAvailableNow: true,
      topProducts: ['معدات تقنية', 'أدوات مكتبية'],
      deliveryArea: 'التوصيل: جميع أنحاء القاهرة والجيزة',
      logo: 'assets/images/vertex-trade-logo.png',
    },
    {
      id: 4,
      name: 'فيرتكس للتجارة العامة',
      city: 'القاهرة، مدينة نصر',
      reviewsCount: 124,
      rating: 4.8,
      isVerified: true,
      isAvailableNow: true,
      topProducts: ['معدات تقنية', 'أدوات مكتبية'],
      deliveryArea: 'التوصيل: جميع أنحاء القاهرة والجيزة',
      logo: 'assets/images/vertex-trade-logo.png',
    },
  ];

  readonly filteredSuppliers = computed(() => {
    const city = this.cityQuery().trim().toLowerCase();
    const product = this.productQuery().trim().toLowerCase();
    const name = this.supplierNameQuery().trim().toLowerCase();
    const verifiedOnly = this.verifiedOnly();

    return this.suppliers.filter((supplier) => {
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

  toggleVerifiedOnly(): void {
    this.verifiedOnly.update((value) => !value);
  }

  onSearch(): void {
    
  }
}
