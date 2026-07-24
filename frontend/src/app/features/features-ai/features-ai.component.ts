import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { RouterLink } from '@angular/router';

import { RevealDirective } from '../../shared/animations/reveal.directive';
import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';

interface VoiceFeature {
  label: string;
  description: string;
}

interface ReasoningCard {
  id: string;
  icon: string;
  iconColor: string;
  iconBackground: string;
  title: string;
  description: string;
}

interface WorkflowStep {
  icon: string;
  label: string;
}

interface ConfidenceBar {
  height: number;
  background: string;
  boxShadow?: string;
}

interface ComplianceAvatar {
  label: string;
  background: string;
}

type VerificationCardType = 'confidence' | 'icon' | 'compliance';

interface VerificationCard {
  id: string;
  type: VerificationCardType;
  title: string;
  description: string;
  gridArea: string;
  icon?: string;
  iconColor?: string;
  bars?: ConfidenceBar[];
  avatars?: ComplianceAvatar[];
}

@Component({
  selector: 'app-features-ai',
  standalone: true,
  imports: [RevealDirective, RouterLink, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './features-ai.component.html',
  styleUrl: './features-ai.component.css',
})
export class FeaturesAiComponent {
  readonly voiceFeatures: VoiceFeature[] = [
    {
      label: 'تحسين اللهجات:',
      description: 'دعم أصيل للمصطلحات التجارية الخليجية، الشامية، والمصرية.',
    },
    {
      label: 'تصفية الضجيج الصناعي:',
      description: 'طرح طيفي متقدم لعزل نية التاجر عن الضوضاء المحيطة.',
    },
  ];

  readonly reasoningCards: ReasoningCard[] = [
    {
      id: 'reasoning-loop',
      icon: 'reasoning-loop',
      iconColor: '#565F71',
      iconBackground: 'rgba(86, 95, 113, 0.10)',
      title: 'حلقة الاستدلال',
      description: 'تضمن معالجة "سلسلة الأفكار" التحقق من قرارات المشتريات عالية المخاطر مقابل سياسات الشركة.',
    },
    {
      id: 'semantic-logic',
      icon: 'semantic-logic',
      iconColor: '#007E37',
      iconBackground: 'rgba(0, 126, 55, 0.10)',
      title: 'المنطق الدلالي',
      description: 'يحل الطلبات الغامضة من خلال مراجعة بيانات الطلبات التاريخية وكتالوجات الموردين في الوقت الفعلي.',
    },
    {
      id: 'entity-extraction',
      icon: 'entity-extraction',
      iconColor: '#2563EB',
      iconBackground: 'rgba(37, 99, 235, 0.10)',
      title: 'استخراج الكيانات',
      description: 'يحدد تلقائياً وحدات حفظ المخزون (SKUs)، الكميات، ووحدات القياس من نصوص اللغة الطبيعية غير المهيكلة.',
    },
  ];

  readonly workflowSteps: WorkflowStep[] = [
    { icon: 'supplier-routing', label: 'توجيه الموردين' },
    { icon: 'state-management', label: 'إدارة الحالة' },
    { icon: 'process-retrieval', label: 'استرجاع العمليات' },
    { icon: 'security-guardrails', label: 'حواجز الأمان' },
  ];

  readonly verificationCards: VerificationCard[] = [
    {
      id: 'last-mile-routing',
      type: 'icon',
      icon: 'last-mile-routing',
      iconColor: '#007E37',
      title: 'مسار الميل الأخير',
      description: 'التحسين بناءً على المسافة، ظروف حركة المرور، وتوافر المركبات.',
      gridArea: '1 / 1 / span 1 / span 1',
    },
    {
      id: 'fraud-detection',
      type: 'icon',
      icon: 'fraud-detection',
      iconColor: '#BA1A1A',
      title: 'كشف الاحتيال',
      description: 'كشف الشذوذ في الوقت الفعلي للقيم المتطرفة في الأسعار وأنماط الطلب المشبوهة.',
      gridArea: '1 / 2 / span 1 / span 1',
    },
    {
      id: 'confidence-score',
      type: 'confidence',
      title: 'تسجيل الثقة',
      description: 'تحقق متعدد الأنماط يضمن تلبية كل طلب مشتريات لعتبة ثقة بنسبة 98% قبل التنفيذ.',
      gridArea: '1 / 3 / span 1 / span 2',
      bars: [
        { height: 70.5, background: 'rgba(37, 99, 235, 0.70)' },
        { height: 84.59, background: '#2563EB', boxShadow: '0 0 10px 0 rgba(37, 99, 235, 0.20)' },
        { height: 56.39, background: 'rgba(37, 99, 235, 0.60)' },
        { height: 37.59, background: 'rgba(37, 99, 235, 0.40)' },
      ],
    },
    {
      id: 'compliance-engine',
      type: 'compliance',
      title: 'محرك توافق الذكاء الاصطناعي',
      description:
        'نقوم بتشغيل نماذج فرعية متعددة بالتوازي للتحقق من البيانات الهامة. إذا تم العثور على تناقض، يتم وضع علامة للمراجعة اليدوية تلقائياً.',
      gridArea: '2 / 1 / span 1 / span 2',
      avatars: [
        { label: 'M3', background: '#565F71' },
        { label: 'M2', background: '#007E37' },
        { label: 'M1', background: '#2563EB' },
      ],
    },
    {
      id: 'price-indexing',
      type: 'icon',
      icon: 'price-indexing',
      iconColor: '#2563EB',
      title: 'فهرسة الأسعار',
      description: 'مطابقة ديناميكية مقابل مؤشرات السوق لضمان مشتريات تنافسية.',
      gridArea: '2 / 3 / span 1 / span 2',
    },
  ];

  readonly activeReasoningCard = signal<string | null>(null);
  readonly activeVerificationCard = signal<string | null>(null);

  toggleReasoningCard(id: string): void {
    this.activeReasoningCard.update((current) => (current === id ? null : id));
  }

  toggleVerificationCard(id: string): void {
    this.activeVerificationCard.update((current) => (current === id ? null : id));
  }
}
