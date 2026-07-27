import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';

interface FaqCategory {
  id: string;
  title: string;
  icon: string;
  description: string;
}

interface FaqItem {
  id: string;
  categoryId: string;
  question: string;
  answer: string;
  isOpen?: boolean;
}

@Component({
  selector: 'app-help-center',
  standalone: true,
  imports: [CommonModule, RouterLink, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './help-center.component.html',
  styleUrl: './help-center.component.css',
})
export class HelpCenterComponent {
  readonly searchQuery = signal<string>('');
  readonly activeCategory = signal<string>('all');

  readonly categories = signal<FaqCategory[]>([
    {
      id: 'registration',
      title: 'التسجيل والتوثيق',
      icon: 'file-check',
      description: 'كل ما يتعلق برفع السجل التجاري والشهادات الضريبية وتوثيق المنشأة',
    },
    {
      id: 'bidding',
      title: 'عروض الأسعار والمنافسات',
      icon: 'trending-up',
      description: 'كيفية تقديم العروض والمشاركة في طلبيات الشراء العامة والخاصة',
    },
    {
      id: 'account',
      title: 'إدارة الحساب والأمان',
      icon: 'shield',
      description: 'تغيير بيانات الاتصال، إدارة صلاحيات المفوضين، وتأمين الحساب',
    },
    {
      id: 'billing',
      title: 'الفواتير والمدفوعات',
      icon: 'credit-card',
      description: 'معلومات المستحقات الشراء والدفع الإلكتروني والرسوم',
    },
  ]);

  readonly faqs = signal<FaqItem[]>([
    {
      id: 'faq-1',
      categoryId: 'registration',
      question: 'كم تستغرق عملية التوثيق والمراجعة للسجل التجاري؟',
      answer: 'تتم عملية المطابقة والتحقق الآلي من السجل التجاري في غضون 24 إلى 48 ساعة عمل. سيتم إشعارك فور اكتمال الاعتماد عبر البريد الإلكتروني والرسائل النصية القصيرة.',
      isOpen: true,
    },
    {
      id: 'faq-2',
      categoryId: 'registration',
      question: 'ما هي المستندات المطلوبة لإكمال عملية التسجيل؟',
      answer: 'المستندات الأساسية هي: رخصة السجل التجاري السارية، شهادة تسجيل ضريبة القيمة المضافة (VAT)، وكشف حساب بنكي رسمي مختوم لتوثيق رقم الآيبان (IBAN).',
      isOpen: false,
    },
    {
      id: 'faq-3',
      categoryId: 'bidding',
      question: 'كيف يمكنني التقدم بمنافسة لعرض سعر جديد؟',
      answer: 'بعد اعتماد حسابك، يمكنك التوجه إلى قسم "منافسات المشتريات" في لوحة التحكم وتصفح طلبات الشراء المتاحة، ثم الضغط على "تقديم عرض سعر" وإدخال البيانات المطلوبة.',
      isOpen: false,
    },
    {
      id: 'faq-4',
      categoryId: 'account',
      question: 'هل يمكن إضافة أكثر من شخص مفوض في حساب الشركة؟',
      answer: 'نعم، يمكنك تقديم بيانات الأشخاص المفوضين في خطوة "معلومات الاتصال" أو من خلال لوحة التحكم لإضافة ممثلي مبيعات إضافيين.',
      isOpen: false,
    },
    {
      id: 'faq-5',
      categoryId: 'billing',
      question: 'كيف تتم عملية التحصيل والدفع مقابل توريد المنتجات؟',
      answer: 'تتم التسويات المالية مباشرة إلى الحساب البنكي المعتمد المرفق في ملف المنشأة وفق شروط أمر الشراء الصادر من المشتري.',
      isOpen: false,
    },
  ]);

  toggleFaq(id: string): void {
    this.faqs.update(list =>
      list.map(item => item.id === id ? { ...item, isOpen: !item.isOpen } : item)
    );
  }

  setCategory(catId: string): void {
    this.activeCategory.set(catId);
  }

  onSearch(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchQuery.set(input.value.trim().toLowerCase());
  }

  get filteredFaqs(): FaqItem[] {
    const query = this.searchQuery();
    const cat = this.activeCategory();

    return this.faqs().filter(item => {
      const matchesCat = cat === 'all' || item.categoryId === cat;
      const matchesQuery = !query || 
        item.question.toLowerCase().includes(query) || 
        item.answer.toLowerCase().includes(query);
      return matchesCat && matchesQuery;
    });
  }
}
