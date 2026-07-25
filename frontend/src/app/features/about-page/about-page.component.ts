import { ChangeDetectionStrategy, Component } from '@angular/core';

import { RevealDirective } from '../../shared/animations/reveal.directive';
import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';

interface MissionCard {
  icon: string;
  iconColor: string;
  iconBackground: string;
  title: string;
  description: string;
  statValue: string;
  statLabel: string;
  statColor: string;
}

interface StatCard {
  value: string;
  eyebrow: string;
  description: string;
}

interface TeamMember {
  name: string;
  englishName: string;
  role: string;
  bio: string;
}

@Component({
  selector: 'app-about-page',
  standalone: true,
  imports: [RevealDirective, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './about-page.component.html',
  styleUrl: './about-page.component.css',
})
export class AboutPageComponent {
  readonly missionCards: MissionCard[] = [
    {
      icon: 'mission-digitize',
      iconColor: '#2563eb',
      iconBackground: 'rgba(37, 99, 235, 0.07)',
      title: 'رقمنة تجارة الجملة المصرية',
      description: 'أكثر من ٩٠٪ من مشتريات الجملة في مصر تتم بالهاتف أو الواتساب. نحن نبني البنية التحتية الرقمية التي تحول هذا الواقع.',
      statValue: '٩٠٪',
      statLabel: 'مشتريات غير رقمية',
      statColor: '#2563eb',
    },
    {
      icon: 'mission-speed',
      iconColor: '#7c3aed',
      iconBackground: 'rgba(124, 58, 237, 0.07)',
      title: 'تقليل الطلب اليدوي',
      description: 'الطلب اليدوي يضيع ٣-٤ ساعات يومياً من وقت التاجر في مكالمات ومتابعة. ساليسل تختصر هذا في ثوانٍ.',
      statValue: '٤ ساعات',
      statLabel: 'تُهدر يومياً للطلب اليدوي',
      statColor: '#7c3aed',
    },
    {
      icon: 'mission-empower',
      iconColor: '#059669',
      iconBackground: 'rgba(5, 150, 105, 0.07)',
      title: 'تمكين المشاريع الصغيرة',
      description: 'الـ SMEs لا تملك فرق مشتريات متخصصة. ساليسل تعطيها قدرات المؤسسات الكبرى بسعر في متناول اليد.',
      statValue: '٣.٢م',
      statLabel: 'تاجر صغير في مصر',
      statColor: '#059669',
    },
  ];

  readonly lostSalesCard: StatCard = {
    value: '15%',
    eyebrow: 'فقدان في المبيعات',
    description: 'نفاد المخزون المتكرر بسبب غياب التنبؤ الفوري واعتماد دورات مشتريات بطيئة ويدوية.',
  };

  readonly unreliableOrdersCard: StatCard = {
    value: '82%',
    eyebrow: 'طلبات هاتفية غير موثقة',
    description: 'فقدان البيانات في المكالمات يؤدي إلى معدلات خطأ مرتفعة واختلال في دورة التوريد.',
  };

  readonly teamMembers: TeamMember[] = Array.from({ length: 4 }, () => ({
    name: 'أحمد ماهر',
    englishName: 'Ahmed Maher',
    role: 'مهندس برمجيات | مصمم و مطور ويب',
    bio: 'مهندس برمجيات سابق في Careem وSwvl. خريج AUC وMIT Sloan. شغف برقمنة التجارة المصرية.',
  }));

  readonly technologyPartners = ['Google Cloud', 'Microsoft', 'Anthropic', 'AWS'];
}
