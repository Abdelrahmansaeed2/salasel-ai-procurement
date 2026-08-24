import { ChangeDetectionStrategy, Component, EventEmitter, Output, Input, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StepHeaderComponent } from '../shared/step-header/step-header.component';

@Component({
  selector: 'app-review-submit-form',
  standalone: true,
  imports: [CommonModule, StepHeaderComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './review-submit-form.component.html',
  styleUrl: './review-submit-form.component.css',
})
export class ReviewSubmitFormComponent {
  @Output() next = new EventEmitter<void>();
  @Output() back = new EventEmitter<void>();
  @Output() editStep = new EventEmitter<number>();

  @Input() data: any = {};

  declarationChecked = signal(false);

  get businessInfo() {
    return [
      { label: 'اسم المنشأة', value: this.data.legalName || 'غير محدد' },
      { label: 'نوع الكيان', value: this.data.businessType || 'غير محدد' },
      { label: 'رقم التسجيل', value: this.data.registrationNumber || 'غير محدد' },
      { label: 'العنوان', value: this.data.address || 'غير محدد' },
    ];
  }

  get contactInfo() {
    return {
      name: this.data.fullName || 'غير محدد',
      role: this.data.jobTitle || 'غير محدد',
      email: this.data.email || 'غير محدد',
      phone: this.data.phoneNumber || 'غير محدد'
    };
  }

  get legalTaxInfo() {
    return [
      { label: 'الرقم الضريبي (VAT)', value: this.data.vatNumber || 'غير محدد', highlighted: true },
      { label: 'المعرف الضريبي', value: this.data.taxId || 'غير محدد', highlighted: false },
      { label: 'معفى من الضريبة', value: this.data.isVatExempt ? 'نعم' : 'لا', highlighted: false },
    ];
  }

  get attachedDocuments() {
    const docs = [];
    if (this.data.files && this.data.files.length > 0) {
      docs.push({ name: this.data.files[0].name, size: 'ملف مرفق', type: 'doc' });
    }
    if (this.data.taxCertificate?.name) {
      docs.push({ name: this.data.taxCertificate.name, size: 'ملف مرفق', type: 'doc' });
    }
    if (docs.length === 0) {
      docs.push({ name: 'لا توجد مرفقات', size: '-', type: 'none' });
    }
    return docs;
  }

  toggleDeclaration(): void {
    this.declarationChecked.update(v => !v);
  }

  onEdit(stepNumber: number): void {
    this.editStep.emit(stepNumber);
  }

  onSubmit(): void {
    if (!this.declarationChecked()) return;
    this.next.emit();
  }

  onBackClick(): void {
    this.back.emit();
  }
}
