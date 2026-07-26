import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

interface SummaryStat {
  label: string;
  value: string;
  valueColor: string;
  icon: string;
}

interface KpiCard {
  value: string;
  label: string;
}

interface Product {
  id: number;
  name: string;
  brand: string;
  price: string;
  minQtyLabel: string;
  image: string;
  category: string;
  discountBadge?: string;
}

interface Certification {
  icon: string;
  title: string;
  subtitle: string;
}

interface Review {
  name: string;
  time: string;
  initials: string;
  avatarColor: string;
  rating: number;
  text: string;
}

interface PerformanceBar {
  label: string;
  heightPercent: number;
}

@Component({
  selector: 'app-supplier-details',
  standalone: true,
  imports: [FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './supplier-details.component.html',
  styleUrl: './supplier-details.component.css',
})
export class SupplierDetailsComponent {
  readonly isFavorite = signal(false);
  readonly activeCategory = signal('الكل');
  readonly productSearch = signal('');
  readonly cartCount = signal(0);

  readonly categories = ['مجمدات', 'ألبان', 'أفران', 'الكل'];

  readonly summaryStats: SummaryStat[] = [
    { label: 'حالة التحقق', value: 'موثق بلاتيني', valueColor: '#004AC6', icon: 'assets/icons/icon-shield-badge.svg' },
    { label: 'الحد الأدنى للطلب', value: '5,000 EGP', valueColor: '#191C1E', icon: 'assets/icons/icon-package.svg' },
    { label: 'مدة التوصيل', value: '24-48 ساعة', valueColor: '#191C1E', icon: 'assets/icons/icon-truck-clock.svg' },
    { label: 'سرعة الرد', value: 'أقل من 10 دقائق', valueColor: '#16A34A', icon: 'assets/icons/icon-lightning.svg' },
  ];

  readonly aboutCompanyText =
    'نحن في شركة البركة نفخر بكوننا الركيزة الأساسية لأكثر من 1200 تاجر تجزئة في مصر، نوفر أجود أنواع المنتجات الغذائية والاستهلاكية بأسعار تنافسية وخدمة لوجستية لا تضاهى.';

  readonly kpiCards: KpiCard[] = [
    { value: '24ساعة', label: 'متوسط التوصيل' },
    { value: '98%', label: 'دقة الطلبات' },
    { value: '48', label: 'علامة تجارية' },
    { value: '+5,000', label: 'منتج متاح' },
  ];

  readonly products: Product[] = [
    {
      id: 1,
      name: 'أرز بسمتي ذهبي - 5 كجم',
      brand: 'الماركة: المطبخ',
      price: '340.00 EGP',
      minQtyLabel: 'أقل كمية: 4 عبوات',
      image: 'assets/images/product-rice.jpg',
      category: 'أفران',
    },
    {
      id: 2,
      name: 'تونا قطعة واحدة - 185 جم',
      brand: 'الماركة: صن شاين',
      price: '52.00 EGP',
      minQtyLabel: 'أقل كمية: 24 قطعة',
      image: 'assets/images/product-tuna.jpg',
      category: 'مجمدات',
    },
    {
      id: 3,
      name: 'حليب كامل الدسم - عبوة 1 لتر',
      brand: 'الماركة: جهينة',
      price: '24.50 EGP',
      minQtyLabel: 'أقل كمية: 12 قطعة',
      image: 'assets/images/product-milk.jpg',
      category: 'ألبان',
      discountBadge: 'خصم 5%',
    },
    {
      id: 4,
      name: 'بن محوج ممتاز - 250 جم',
      brand: 'الماركة: بن شاهين',
      price: '115.00 EGP',
      minQtyLabel: 'أقل كمية: 10 قطع',
      image: 'assets/images/product-coffee.jpg',
      category: 'أفران',
    },
  ];

  readonly filteredProducts = computed(() => {
    const category = this.activeCategory();
    const query = this.productSearch().trim().toLowerCase();

    return this.products.filter((product) => {
      const matchesCategory = category === 'الكل' || product.category === category;
      const matchesQuery =
        !query || product.name.toLowerCase().includes(query) || product.brand.toLowerCase().includes(query);
      return matchesCategory && matchesQuery;
    });
  });

  readonly performanceBars: PerformanceBar[] = [
    { label: 'أبريل', heightPercent: 100 },
    { label: 'مارس', heightPercent: 62 },
    { label: 'فبراير', heightPercent: 78 },
    { label: 'يناير', heightPercent: 55 },
  ];

  readonly certifications: Certification[] = [
    { icon: 'assets/icons/icon-document-license.svg', title: 'Commercial License', subtitle: 'سجل تجاري ساري' },
    { icon: 'assets/icons/icon-food-safety.svg', title: 'Food Safety', subtitle: 'سلامة الغذاء الدولية' },
    { icon: 'assets/icons/icon-iso.svg', title: 'ISO 9001', subtitle: 'نظام إدارة الجودة' },
  ];

  readonly reviews: Review[] = [
    {
      name: 'سوبر ماركت الأمانة',
      time: 'منذ يومين',
      initials: 'م.أ',
      avatarColor: '#DBE1FF',
      rating: 5,
      text: 'أفضل مورد تعاملت معه في منطقة القاهرة. التوصيل دائماً في الموعد والمنتجات تصل بحالة ممتازة.',
    },
    {
      name: 'هايبر طيبة',
      time: 'منذ أسبوع',
      initials: 'هـ.ص',
      avatarColor: '#D3E4FE',
      rating: 4,
      text: 'دقة عالية في الفواتير وسهولة في طلب المرتجعات. نظام الربط التقني لديهم متميز جداً.',
    },
  ];

  readonly starIndexes = [0, 1, 2, 3, 4];

  toggleFavorite(): void {
    this.isFavorite.update((value) => !value);
  }

  selectCategory(category: string): void {
    this.activeCategory.set(category);
  }

  addToCart(product: Product): void {
    this.cartCount.update((count) => count + 1);
    
    console.log(`تمت إضافة ${product.name} إلى السلة`);
  }
}
