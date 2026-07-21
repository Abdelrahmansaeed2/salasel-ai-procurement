import {
  AfterViewInit,
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  HostListener,
  OnDestroy,
  ViewChild,
  signal,
} from '@angular/core';

import { RevealDirective } from '../../shared/animations/reveal.directive';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';

interface TechBadge {
  label: string;
  color: string;
}

interface Metric {
  icon: string;
  label: string;
  value: string;
  accent: 'blue' | 'cyan';
}

interface ListItem {
  text: string;
  icon: string;
}

interface Step {
  number: string;
  icon: string;
  title: string;
  description: string;
}

interface Feature {
  icon: string;
  color: string;
  title: string;
  description: string;
}

interface Segment {
  emoji: string;
  title: string;
  titleColor: string;
  subtitle: string;
  borderColor: string;
  benefits: ListItem[];
  buttonLabel: string;
  buttonColor: string;
}

interface Testimonial {
  quote: string;
  name: string;
  role: string;
  avatar: string;
}

@Component({
  selector: 'app-landing-page',
  standalone: true,
  imports: [RevealDirective, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './landing-page.component.html',
  styleUrl: './landing-page.component.css',
})
export class LandingPageComponent implements AfterViewInit, OnDestroy {
  @ViewChild('waveformCanvas') private waveformCanvasRef?: ElementRef<HTMLCanvasElement>;

  readonly activeTestimonialIndex = signal(0);
  readonly isVoiceDemoActive = signal(false);
  readonly scrollProgress = signal(0);
  readonly showScrollTop = signal(false);

  private animationFrameId: number | null = null;
  private barHeights: number[] = Array.from({ length: 48 }, () => 4);
  private scrollTicking = false;
  private metricsAnimated = false;

  readonly techBadges: TechBadge[] = [
    { label: 'AWS', color: '#ff9900' },
    { label: 'Anthropic', color: '#d97706' },
    { label: 'Claude AI', color: '#7c3aed' },
    { label: 'LangGraph', color: '#2563eb' },
    { label: 'Amazon Transcribe', color: '#059669' },
  ];

  readonly metrics: Metric[] = [
    { icon: 'metric-merchants', label: 'تاجر نشط', value: '2,840+', accent: 'blue' },
    { icon: 'metric-suppliers', label: 'مورد معتمد', value: '183+', accent: 'blue' },
    { icon: 'metric-orders', label: 'طلب اليوم', value: '1,247', accent: 'blue' },
    { icon: 'metric-accuracy', label: 'دقة التعرف الصوتي', value: '97٪', accent: 'blue' },
    { icon: 'metric-time', label: 'وقت المعالجة', value: '8ث', accent: 'cyan' },
    { icon: 'metric-uptime', label: 'وقت التشغيل المضمون', value: '99.9٪', accent: 'blue' },
  ];

  readonly animatedMetricValues = signal<string[]>(
    this.metrics.map((metric) => this.formatMetricAtProgress(metric.value, 0)),
  );

  readonly problemItems: ListItem[] = [
    { text: 'مكالمات هاتفية لا تنتهي ومتابعة يدوية', icon: 'problem-phone' },
    { text: 'رسائل واتساب مبعثرة وفقدان الطلبات', icon: 'problem-chat' },
    { text: 'فواتير ورقية يصعب تتبعها وأرشفتها', icon: 'problem-invoice' },
    { text: 'طلبات ناقصة أو خاطئة بسبب سوء الفهم', icon: 'problem-warning' },
    { text: 'أخطاء بشرية في الكميات والأسعار', icon: 'problem-error' },
    { text: 'تأخير في التأكيد ونفاد المخزون فجأة', icon: 'problem-delay' },
  ];

  readonly solutionItems: ListItem[] = [
    { text: 'طلب صوتي فوري باللهجة المصرية العامية', icon: 'solution-mic' },
    { text: 'تحليل ذكي واستخراج البيانات تلقائياً', icon: 'solution-ai' },
    { text: 'أمر شراء منظم يُرسَل فورياً للمورد', icon: 'solution-order' },
    { text: 'تحقق تلقائي من الكميات والأسعار والمخزون', icon: 'solution-check' },
    { text: 'لوحة تحكم حية لمتابعة كل طلب', icon: 'solution-dashboard' },
    { text: 'معالجة في ثوانٍ بدلاً من ساعات', icon: 'solution-clock' },
  ];

  readonly steps: Step[] = [
    {
      number: '١',
      icon: 'step-mic',
      title: 'تكلم بشكل طبيعي',
      description: 'اضغط زر الميكروفون واطلب بضائعك باللهجة المصرية العامية كما تتكلم مع أي شخص.',
    },
    {
      number: '٢',
      icon: 'step-ai',
      title: 'الذكاء الاصطناعي يفهم',
      description: 'Amazon Transcribe يحوّل صوتك لنص وكلود يستخرج المنتجات والكميات بدقة عالية.',
    },
    {
      number: '٣',
      icon: 'step-check',
      title: 'تحقق من المنتجات',
      description: 'مطابقة تلقائية مع كتالوج الموردين والأسعار الحالية وما هو متاح في المخزون.',
    },
    {
      number: '٤',
      icon: 'step-supplier',
      title: 'اختيار أفضل مورد',
      description: 'LangGraph يرتب الموردين حسب السعر والموقع والتقييم التاريخي وسرعة التوصيل.',
    },
    {
      number: '٥',
      icon: 'step-accept',
      title: 'المورد يقبل',
      description: 'المورد يتلقى أمر الشراء ويؤكده مباشرةً من لوحة التحكم الخاصة به في الوقت الفعلي.',
    },
    {
      number: '٦',
      icon: 'step-delivery',
      title: 'بدء التوصيل',
      description: 'تبدأ رحلة التوصيل وتصلك تحديثات حية على هاتفك خطوة بخطوة.',
    },
  ];

  readonly features: Feature[] = [
    { icon: 'feature-voice', color: '#2563eb', title: 'طلب بالصوت', description: 'اطلب بضائعك بالعامية المصرية ساليسل يفهمك على الفور دون كتابة حرف.' },
    { icon: 'feature-ai-check', color: '#7c3aed', title: 'تحقق بالذكاء الاصطناعي', description: 'كلود يحلل كل طلب ويتأكد من الكميات والأسعار وتوفر المخزون تلقائياً.' },
    { icon: 'feature-routing', color: '#0891b2', title: 'توجيه ذكي للموردين', description: 'LangGraph يختار أفضل مورد حسب السعر والموقع والتقييم وسرعة التوصيل.' },
    { icon: 'feature-analytics', color: '#059669', title: 'تحليلات المخزون', description: 'لوحة تحكم حية تتابع مبيعاتك وتنبهك تلقائياً عند انخفاض المخزون.' },
    { icon: 'feature-tracking', color: '#ea580c', title: 'متابعة حية للطلبات', description: 'تتبع كل طلب من الإنشاء حتى التسليم الفعلي لحظة بلحظة.' },
    { icon: 'feature-local-ai', color: '#db2777', title: 'ذكاء اصطناعي محلي', description: 'يعمل بكفاءة حتى مع الاتصال الضعيف في الأسواق والمناطق النائية.' },
    { icon: 'feature-security', color: '#dc2626', title: 'أمان المؤسسات', description: 'تشفير شامل وامتثال GDPR وAML لحماية بيانات تجارتك الحساسة.' },
    { icon: 'feature-uptime', color: '#64748b', title: 'توافر عالٍ ٩٩.٩٪', description: 'بنية موزعة على AWS بضمان وقت تشغيل للعمليات التجارية الحيوية.' },
  ];

  readonly segments: Segment[] = [
    {
      emoji: '🛒',
      title: 'أنت التاجر',
      titleColor: '#2563eb',
      subtitle: 'لأصحاب البقالات والسوبرماركتات والمحلات',
      borderColor: '#bfdbfe',
      benefits: [
        { text: 'طلب البضائع بصوتك بالعامية المصرية', icon: 'check-bullet-1' },
        { text: 'مقارنة أسعار الموردين تلقائياً', icon: 'check-bullet-2' },
        { text: 'تتبع طلباتك حياً على الجوال', icon: 'check-bullet-3' },
        { text: 'سجل كامل لكل مشترياتك وفواتيرك', icon: 'check-bullet-4' },
        { text: 'تنبيهات تلقائية عند قرب نفاد المخزون', icon: 'check-bullet-5' },
      ],
      buttonLabel: 'ابدأ مجاناً',
      buttonColor: '#2563eb',
    },
    {
      emoji: '🏭',
      title: 'أنت المورد',
      titleColor: '#7c3aed',
      subtitle: 'للموزعين وتجار الجملة والمصنّعين',
      borderColor: '#ddd6fe',
      benefits: [
        { text: 'استلام أوامر شراء منظمة ومحددة', icon: 'check-bullet-6' },
        { text: 'لوحة تحكم متكاملة لإدارة الطلبات', icon: 'check-bullet-7' },
        { text: 'تحليلات المبيعات والموسمية', icon: 'check-bullet-8' },
        { text: 'تكامل مع أنظمة ERP و WMS', icon: 'check-bullet-9' },
        { text: 'وصول لأكثر من ٢٨٠٠ تاجر نشط', icon: 'check-bullet-10' },
      ],
      buttonLabel: 'انضم كشريك',
      buttonColor: '#7c3aed',
    },
  ];

  readonly testimonials: Testimonial[] = [
    {
      quote:
        'سلاسل غيرت الطريقة التي ندير بها فروعنا الـ 14 في القاهرة. كان الطلب يستغرق 3 موظفين نصف يوم، الآن يتحدث مديرو الفروع للتطبيق لمدة 5 دقائق فقط.',
      name: 'أحمد منصور',
      role: 'مدير العمليات، مترو ماركت',
      avatar: 'testimonial-avatar',
    },
    {
      quote:
        'سلاسل غيرت الطريقة التي ندير بها فروعنا الـ 14 في القاهرة. كان الطلب يستغرق 3 موظفين نصف يوم، الآن يتحدث مديرو الفروع للتطبيق لمدة 5 دقائق فقط.',
      name: 'أحمد منصور',
      role: 'مدير العمليات، مترو ماركت',
      avatar: 'testimonial-avatar',
    },
  ];

  readonly testimonialDots = [0, 1, 2, 3];

  setActiveTestimonial(index: number): void {
    this.activeTestimonialIndex.set(index);
  }

  toggleVoiceDemo(): void {
    this.isVoiceDemoActive.update((active) => !active);
  }

  @HostListener('window:scroll')
  onWindowScroll(): void {
    if (this.scrollTicking) {
      return;
    }
    this.scrollTicking = true;
    requestAnimationFrame(() => {
      const scrollY = window.scrollY;
      const maxScroll = document.documentElement.scrollHeight - window.innerHeight;
      this.showScrollTop.set(scrollY > window.innerHeight * 0.6);
      this.scrollProgress.set(maxScroll > 0 ? (scrollY / maxScroll) * 100 : 0);
      this.scrollTicking = false;
    });
  }

  scrollToTop(): void {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  onMetricsRevealed(): void {
    if (this.metricsAnimated) {
      return;
    }
    this.metricsAnimated = true;

    const duration = 1200;
    const start = performance.now();
    const targets = this.metrics.map((metric) => this.parseMetricTarget(metric.value));

    const step = (now: number) => {
      const progress = Math.min(1, (now - start) / duration);
      const eased = 1 - Math.pow(1 - progress, 3);
      this.animatedMetricValues.set(
        this.metrics.map((metric, i) => this.formatMetricAtProgress(metric.value, targets[i] * eased)),
      );
      if (progress < 1) {
        requestAnimationFrame(step);
      }
    };

    requestAnimationFrame(step);
  }

  private parseMetricTarget(value: string): number {
    const match = value.match(/^([0-9]+(?:[.,][0-9]+)*)/);
    return match ? parseFloat(match[1].replace(/,/g, '')) : 0;
  }

  private formatMetricAtProgress(value: string, current: number): string {
    const match = value.match(/^([0-9]+(?:[.,][0-9]+)*)/);
    if (!match) {
      return value;
    }
    const numberStr = match[1];
    const suffix = value.slice(numberStr.length);
    const decimals = numberStr.includes('.') ? numberStr.split('.')[1].length : 0;
    const formatted = current.toLocaleString('en-US', {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals,
    });
    return `${formatted}${suffix}`;
  }

  ngAfterViewInit(): void {
    this.runWaveformLoop();
  }

  ngOnDestroy(): void {
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
    }
  }

  private runWaveformLoop(): void {
    const canvas = this.waveformCanvasRef?.nativeElement;
    if (!canvas) {
      return;
    }
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      return;
    }

    const draw = () => {
      const width = canvas.width;
      const height = canvas.height;
      const barCount = this.barHeights.length;
      const barWidth = width / barCount;
      const active = this.isVoiceDemoActive();

      this.barHeights = this.barHeights.map((h) => {
        const target = active ? 6 + Math.random() * (height - 12) : 4;
        return h + (target - h) * 0.3;
      });

      ctx.clearRect(0, 0, width, height);
      const gradient = ctx.createLinearGradient(0, 0, width, 0);
      gradient.addColorStop(0, '#1e40af');
      gradient.addColorStop(1, '#2563eb');
      ctx.fillStyle = gradient;

      this.barHeights.forEach((h, i) => {
        const x = i * barWidth + barWidth * 0.2;
        const y = (height - h) / 2;
        ctx.fillRect(x, y, barWidth * 0.6, h);
      });

      this.animationFrameId = requestAnimationFrame(draw);
    };

    draw();
  }
}
