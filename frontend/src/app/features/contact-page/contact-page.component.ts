import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { RevealDirective } from '../../shared/animations/reveal.directive';

interface ContactChannel {
  icon: 'briefcase' | 'handshake' | 'headset' | 'sales';
  title: string;
  description: string;
  email: string;
}

interface FaqItem {
  question: string;
  answer: string;
}

@Component({
  selector: 'app-contact-page',
  standalone: true,
  imports: [FormsModule, SiteHeaderComponent, SiteFooterComponent, RevealDirective],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './contact-page.component.html',
  styleUrl: './contact-page.component.css',
})
export class ContactPageComponent {
  readonly channels: ContactChannel[] = [
    {
      icon: 'briefcase',
      title: 'الوظائف',
      description: 'انضم إلى فريق المبتكرين الذين يشكلون مستقبل التوريد.',
      email: 'carrers@salasel.sa',
    },
    {
      icon: 'handshake',
      title: 'الشراكات',
      description: 'فرص التعاون الاستراتيجي مع مزودي الخدمات اللوجستية.',
      email: 'partners@salasel.sa',
    },
    {
      icon: 'headset',
      title: 'الدعم الفني',
      description: 'مساعدة تقنية على مدار الساعة لضمان استمرارية أعمالك.',
      email: 'support@salasel.sa',
    },
    {
      icon: 'sales',
      title: 'المبيعات',
      description: 'استفسارات المنتجات والعروض التجارية المخصصة.',
      email: 'sales@salasel.sa',
    },
  ];

  readonly faqItems: FaqItem[] = [
    {
      question: 'الاستفسارات التجارية',
      answer:
        'نقدم خدماتنا للشركات والمؤسسات الكبيرة والمتوسطة، مع إمكانية تخصيص الحلول لتناسب حجم العمليات والاحتياجات اللوجستية الخاصة بكل قطاع.',
    },
    {
      question: 'عمليات الربط والتحامل',
      answer: 'يمكن ربط سلاسل بأنظمتك الحالية عبر واجهات برمجية جاهزة دون التأثير على سير العمل القائم لديك.',
    },
    {
      question: 'خطط الأسعار',
      answer: 'نوفر خططاً مرنة تناسب مختلف أحجام الأعمال، مع إمكانية تخصيص الباقة حسب احتياجاتك.',
    },
    {
      question: 'خدمات الدعم',
      answer: 'فريق الدعم الفني متاح على مدار الساعة لمساعدتك في أي استفسار أو مشكلة تواجهك.',
    },
  ];

  readonly openFaqIndex = signal<number | null>(0);

  readonly company = signal('');
  readonly name = signal('');
  readonly phone = signal('');
  readonly email = signal('');
  readonly contactMethod = signal('البريد الإلكتروني');
  readonly subject = signal('');
  readonly message = signal('');
  readonly isSubmitted = signal(false);

  toggleFaq(index: number): void {
    this.openFaqIndex.update((current) => (current === index ? null : index));
  }

  submit(): void {
    if (!this.name() || !this.email() || !this.message()) {
      return;
    }
    this.isSubmitted.set(true);
    this.company.set('');
    this.name.set('');
    this.phone.set('');
    this.email.set('');
    this.subject.set('');
    this.message.set('');
  }
}
