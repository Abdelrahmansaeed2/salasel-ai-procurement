import { Component, ChangeDetectionStrategy, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

// Imports sub-components
import { RegistrationHeaderComponent } from './components/registration-header/registration-header.component';
import { RegistrationStepperComponent } from './components/registration-stepper/registration-stepper.component';
import { FacilityInfoFormComponent } from './components/facility-info-form/facility-info-form.component';
import { LicenseInfoFormComponent } from './components/license-info-form/license-info-form.component';
import { TaxInfoFormComponent } from './components/tax-info-form/tax-info-form.component';
import { WarehouseInfoFormComponent } from './components/warehouse-info-form/warehouse-info-form.component';
import { ContactInfoFormComponent } from './components/contact-info-form/contact-info-form.component';
import { StepPlaceholderComponent } from './components/step-placeholder/step-placeholder.component';
import { SiteFooterComponent } from '../../../shared/site-footer/site-footer.component';

@Component({
  selector: 'app-supplier-registration',
  standalone: true,
  imports: [
    CommonModule,
    RegistrationHeaderComponent,
    RegistrationStepperComponent,
    FacilityInfoFormComponent,
    LicenseInfoFormComponent,
    TaxInfoFormComponent,
    WarehouseInfoFormComponent,
    ContactInfoFormComponent,
    StepPlaceholderComponent,
    SiteFooterComponent
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './supplier-registration.html',
  styleUrl: './supplier-registration.css',
})
export class SupplierRegistration {
  // Stepper Controller state
  readonly currentStep = signal<number>(5);
  
  // List of steps matching the Figma design
  readonly steps = [
    'معلومات المنشأة',
    'رخصة تجارية',
    'معلومات ضريبية',
    'مستودع',
    'معلومات الاتصال',
    'وثائق',
    'مراجعة',
    'نجاح'
  ];

  // Dynamic advice notes based on the active step
  readonly stepGuidanceTitle = signal<string>('نصيحة: دقة البيانات تهمنا');
  readonly stepGuidanceText = signal<string>(
    'سيتم مطابقة المعلومات المقدمة هنا مع السجلات التجارية المحلية. تأكد من أن الاسم يطابق رخصتك التجارية تماماً لتجنب التأخير في التحقق.'
  );

  // Form Data Store
  private registrationData: any = {};

  constructor(private router: Router) {}

  nextStep(formData?: any): void {
    if (formData) {
      this.registrationData = { ...this.registrationData, ...formData };
      console.log('Saved step data:', this.registrationData);
    }

    if (this.currentStep() < this.steps.length) {
      this.currentStep.update(step => step + 1);
      this.updateGuidanceNote();
    }
  }

  prevStep(): void {
    if (this.currentStep() > 1) {
      this.currentStep.update(step => step - 1);
      this.updateGuidanceNote();
    }
  }

  goToStep(step: number): void {
    if (step >= 1 && step <= this.steps.length) {
      this.currentStep.set(step);
      this.updateGuidanceNote();
    }
  }

  onSaveAndExit(): void {
    console.log('Save and Exit clicked. Current data:', this.registrationData);
    alert('تم حفظ تقدمك بنجاح. سنقوم بإعادتك إلى لوحة التحكم.');
    this.router.navigate(['/']);
  }

  onFinish(): void {
    console.log('Final registration submission:', this.registrationData);
    this.router.navigate(['/']);
  }

  private updateGuidanceNote(): void {
    const step = this.currentStep();
    switch (step) {
      case 1:
        this.stepGuidanceTitle.set('نصيحة: دقة البيانات تهمنا');
        this.stepGuidanceText.set(
          'سيتم مطابقة المعلومات المقدمة هنا مع السجلات التجارية المحلية. تأكد من أن الاسم يطابق رخصتك التجارية تماماً لتجنب التأخير في التحقق.'
        );
        break;
      case 2:
        this.stepGuidanceTitle.set('الرخص التجارية النشطة');
        this.stepGuidanceText.set(
          'يرجى تحميل نسخة واضحة وملونة من رخصتك التجارية السارية بصيغة PDF. تأكد من وضوح تاريخ انتهاء الصلاحية ورقم الرخصة.'
        );
        break;
      case 3:
        this.stepGuidanceTitle.set('الشهادة الضريبية المعتمدة');
        this.stepGuidanceText.set(
          'مطلوب شهادة تسجيل ضريبة القيمة المضافة (VAT) للشركات المسجلة. يرجى التحقق من صحة الرقم الضريبي المدخل ومطابقته للشهادة الرسمية.'
        );
        break;
      case 4:
        this.stepGuidanceTitle.set('إدارة المستودعات والشحن');
        this.stepGuidanceText.set(
          'تحديد عنوان المستودع الرئيسي بدقة يساعد محرك الذكاء الاصطناعي على تحسين توقعات تكاليف الشحن وسلاسل التوريد الخاصة بك.'
        );
        break;
      case 5:
        this.stepGuidanceTitle.set('بيانات الاتصال الرسمية');
        this.stepGuidanceText.set(
          'يرجى توفير معلومات الاتصال للمسؤول المباشر عن العمليات والمشتريات. سنقوم بالتواصل معهم لتفعيل الحساب وإجراء الاختبارات التشغيلية.'
        );
        break;
      case 6:
        this.stepGuidanceTitle.set('المستندات الإضافية والتحقق');
        this.stepGuidanceText.set(
          'يمكنك تحميل أي شهادات جودة (ISO) أو خطابات تفويض رسمية هنا لتعزيز موثوقية ملفك التعريفي على المنصة وزيادة فرص الترسية.'
        );
        break;
      case 7:
        this.stepGuidanceTitle.set('مراجعة البيانات قبل الإرسال');
        this.stepGuidanceText.set(
          'يرجى مراجعة كافة التفاصيل المدخلة بعناية. بمجرد إرسال الطلب، سيبدأ فريق التدقيق والمطابقة بمراجعة الملف فوراً.'
        );
        break;
      default:
        this.stepGuidanceTitle.set('اكتملت التسجيل!');
        this.stepGuidanceText.set('أنت الآن جاهز لبدء استخدام المنصة وبدء تلقي طلبات عروض الأسعار الذكية.');
    }
  }
}
