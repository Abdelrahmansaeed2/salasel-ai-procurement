import { ChangeDetectionStrategy, Component, EventEmitter, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-review-submit-form',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './review-submit-form.component.html',
  styleUrl: './review-submit-form.component.css',
})
export class ReviewSubmitFormComponent {
  @Output() next = new EventEmitter<void>();
  @Output() back = new EventEmitter<void>();

  declarationChecked = signal(false);

  // Section 1: Business Info
  businessInfo = [
    { label: 'اسم المنشأة', value: 'شركة سلاسل للخدمات اللوجستية' },
    { label: 'نوع الكيان', value: 'شركة ذات مسؤولية محدودة' },
    { label: 'المقر الرئيسي', value: 'الرياض، المملكة العربية السعودية' },
    { label: 'تاريخ التأسيس', value: '14 يناير 2018' },
  ];

  // Section 3: Legal & Tax
  legalTaxInfo = [
    { label: 'رقم السجل التجاري', value: '1010XXXX92', highlighted: true },
    { label: 'تاريخ انتهاء السجل', value: '22 مايو 2026', highlighted: false },
    { label: 'الرقم الضريبي (VAT)', value: '3000XXXXXXX0003', highlighted: true },
  ];

  // Section 4: Document files
  attachedDocuments = [
    { name: 'شهادة السجل التجاري.pdf', size: '2.4 MB' },
    { name: 'شهادة الزكاة والدخل.png', size: '1.1 MB' },
  ];

  toggleDeclaration(): void {
    this.declarationChecked.update(v => !v);
  }

  onSubmit(): void {
    if (!this.declarationChecked()) return;
    this.next.emit();
  }

  onBackClick(): void {
    this.back.emit();
  }
}
