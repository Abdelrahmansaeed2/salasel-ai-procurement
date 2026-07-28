import { ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { StepHeaderComponent } from '../shared/step-header/step-header.component';
import { FormActionsComponent } from '../shared/form-actions/form-actions.component';
import { FileUploadService } from '../../services/file-upload.service';

@Component({
  selector: 'app-tax-info-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, StepHeaderComponent, FormActionsComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './tax-info-form.component.html',
  styleUrl: './tax-info-form.component.css',
})
export class TaxInfoFormComponent implements OnInit {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  form!: FormGroup;
  uploadedFile = signal<{ name: string; size: string } | null>({
    name: 'Tax_Certificate_2024.pdf',
    size: '1.2 MB',
  });

  isDragOver = signal<boolean>(false);

  constructor(
    private fb: FormBuilder,
    private uploadService: FileUploadService
  ) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      vatNumber: ['100349283400003', [Validators.required, Validators.pattern(/^\d{15}$/)]],
      taxId: ['', [Validators.required, Validators.pattern(/^\d{9}$|^\d{3}-\d{3}-\d{3}$/)]],
      isVatExempt: [false],
    });

    this.form.get('isVatExempt')?.valueChanges.subscribe((exempt) => {
      const vatControl = this.form.get('vatNumber');
      if (exempt) {
        vatControl?.disable();
        vatControl?.clearValidators();
      } else {
        vatControl?.enable();
        vatControl?.setValidators([Validators.required, Validators.pattern(/^\d{15}$/)]);
      }
      vatControl?.updateValueAndValidity();
    });
  }

  onDragOver(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver.set(true);
  }

  onDragLeave(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver.set(false);
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver.set(false);

    if (event.dataTransfer?.files && event.dataTransfer.files.length > 0) {
      this.handleFile(event.dataTransfer.files[0]);
    }
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.handleFile(input.files[0]);
    }
  }

  private handleFile(file: File): void {
    if (file.size > 5 * 1024 * 1024) {
      alert('الحد الأقصى لحجم الملف هو 5 ميجابايت.');
      return;
    }

    this.uploadedFile.set({
      name: file.name,
      size: this.uploadService.formatBytes(file.size),
    });
  }

  removeFile(): void {
    this.uploadedFile.set(null);
  }

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.next.emit({
      ...this.form.value,
      taxCertificate: this.uploadedFile(),
    });
  }

  onBackClick(): void {
    this.back.emit();
  }
}
