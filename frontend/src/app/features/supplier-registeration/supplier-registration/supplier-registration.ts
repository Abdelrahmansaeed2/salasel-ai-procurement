import { Component, ChangeDetectionStrategy, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/auth/auth.service';

import { RegistrationHeaderComponent } from './components/registration-header/registration-header.component';
import { RegistrationStepperComponent } from './components/registration-stepper/registration-stepper.component';
import { FacilityInfoFormComponent } from './components/facility-info-form/facility-info-form.component';
import { LicenseInfoFormComponent } from './components/license-info-form/license-info-form.component';
import { TaxInfoFormComponent } from './components/tax-info-form/tax-info-form.component';
import { WarehouseInfoFormComponent } from './components/warehouse-info-form/warehouse-info-form.component';
import { ContactInfoFormComponent } from './components/contact-info-form/contact-info-form.component';
import { AdditionalDocumentsFormComponent } from './components/additional-documents-form/additional-documents-form.component';
import { ReviewSubmitFormComponent } from './components/review-submit-form/review-submit-form.component';
import { RegistrationSuccessComponent } from './components/registration-success/registration-success.component';
import { SiteFooterComponent } from '../../../shared/site-footer/site-footer.component';
import { SupplierService, SupplierSetupDto } from './services/supplier.service';

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
    AdditionalDocumentsFormComponent,
    ReviewSubmitFormComponent,
    RegistrationSuccessComponent,
    SiteFooterComponent
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './supplier-registration.html',
  styleUrl: './supplier-registration.css',
})
export class SupplierRegistration {
  readonly currentStep = signal<number>(1);
  readonly isSubmitting = signal<boolean>(false);
  
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

  readonly stepGuidanceTitle = signal<string>('نصيحة: دقة البيانات تهمنا');
  readonly stepGuidanceText = signal<string>(
    'سيتم مطابقة المعلومات المقدمة هنا مع السجلات التجارية المحلية. تأكد من أن الاسم يطابق رخصتك التجارية تماماً لتجنب التأخير في التحقق.'
  );

  registrationData: any = {};

  private router = inject(Router);
  private auth = inject(AuthService);
  private supplierService = inject(SupplierService);

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
    alert('تم حفظ تقدمك بنجاح. سنقوم بإعادتك إلى الصفحة الرئيسية.');
    this.router.navigate(['/']);
  }

  onFinish(): void {
    if (this.isSubmitting()) return;
    this.isSubmitting.set(true);

    const email = this.registrationData.email || `supplier_${Date.now()}@example.com`;
    const fullName = this.registrationData.fullName || 'New Supplier';
    
    const dto: SupplierSetupDto = {
      facilityInfo: {
        legalName: this.registrationData.legalName || '',
        businessType: this.registrationData.businessType || '',
        registrationNumber: this.registrationData.registrationNumber || '',
        address: this.registrationData.address || ''
      },
      contactInfo: {
        fullName: fullName,
        jobTitle: this.registrationData.jobTitle || '',
        email: email,
        phoneNumber: this.registrationData.phoneNumber || ''
      },
      taxInfo: {
        vatNumber: this.registrationData.vatNumber || '',
        taxId: this.registrationData.taxId || '',
        isVatExempt: this.registrationData.isVatExempt || false
      },
      warehouses: [
        {
          warehouseName: this.registrationData.warehouseName || '',
          capacity: this.registrationData.capacity ? this.registrationData.capacity.toString() : '',
          lat: this.registrationData.coordinates?.lat || 24.7136,
          lng: this.registrationData.coordinates?.lng || 46.6753,
          city: this.registrationData.city || 'الرياض'
        }
      ]
    };

    if (this.auth.isAuthenticated()) {
      this.submitSupplierProfile(dto);
    } else {
      // 1. Create Auth Account
      this.auth.register({
        fullName: fullName,
        email: email,
        password: 'Password123!',
        role: 1
      }).subscribe({
        next: () => {
          // 2. Submit Supplier Profile Details
          this.submitSupplierProfile(dto);
        },
        error: (err) => {
          this.isSubmitting.set(false);
          alert('حدث خطأ أثناء إنشاء الحساب. قد يكون البريد الإلكتروني مستخدماً مسبقاً.');
          console.error(err);
        }
      });
    }
  }

  private submitSupplierProfile(dto: SupplierSetupDto): void {
    this.supplierService.registerSupplier(dto).subscribe({
      next: () => {
        const filesToUpload: File[] = [];

        // Collect files from license step
        if (this.registrationData.files && this.registrationData.files.length > 0) {
          filesToUpload.push(this.registrationData.files[0].rawFile);
        }

        // Collect files from tax step
        if (this.registrationData.taxCertificate?.rawFile) {
          filesToUpload.push(this.registrationData.taxCertificate.rawFile);
        }

        if (filesToUpload.length > 0 && filesToUpload.every(f => f !== undefined)) {
          this.supplierService.uploadDocuments(filesToUpload).subscribe({
            next: () => {
              this.isSubmitting.set(false);
              this.nextStep(); // Move to success step
            },
            error: (err) => {
              this.isSubmitting.set(false);
              alert('تم تسجيل البيانات ولكن حدث خطأ أثناء رفع الملفات.');
              console.error(err);
            }
          });
        } else {
          this.isSubmitting.set(false);
          this.nextStep(); // Move to success step
        }
      },
      error: (err) => {
        this.isSubmitting.set(false);
        alert('حدث خطأ أثناء تسجيل بيانات المورد. يرجى المحاولة لاحقاً.');
        console.error(err);
      }
    });
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
