import { ChangeDetectionStrategy, Component, EventEmitter, Output, signal } from '@angular/core';
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

  declarationChecked = signal(false);

  businessInfo = [
    { label: 'اسم المنشأة', value: 'شركة سلاسل للخدمات اللوجستية' },
    { label: 'نوع الكيان', value: 'شركة ذات مسؤولية محدودة' },
    { label: 'المقر الرئيسي', value: 'الرياض، المملكة العربية السعودية' },
    { label: 'تاريخ التأسيس', value: '14 يناير 2018' },
  ];

  legalTaxInfo = [
    { label: 'رقم السجل التجاري', value: '1010XXXX92', highlighted: true },
    { label: 'تاريخ انتهاء السجل', value: '22 مايو 2026', highlighted: false },
    { label: 'الرقم الضريبي (VAT)', value: '3000XXXXXXXX003', highlighted: true },
  ];

  attachedDocuments = [
    { name: 'شهادة السجل التجاري.pdf', size: '2.4 MB', type: 'pdf' },
    { name: 'شهادة الزكاة والدخل.png', size: '1.1 MB', type: 'image' },
  ];

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
