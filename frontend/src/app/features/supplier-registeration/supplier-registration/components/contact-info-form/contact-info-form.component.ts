import { ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { StepHeaderComponent } from '../shared/step-header/step-header.component';
import { FormActionsComponent } from '../shared/form-actions/form-actions.component';

@Component({
  selector: 'app-contact-info-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, StepHeaderComponent, FormActionsComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './contact-info-form.component.html',
  styleUrl: './contact-info-form.component.css',
})
export class ContactInfoFormComponent implements OnInit {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  form!: FormGroup;

  constructor(private fb: FormBuilder) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      fullName: ['', [Validators.required, Validators.minLength(3)]],
      jobTitle: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      phoneNumber: ['', [Validators.required, Validators.pattern(/^\+?\d[\d\s-]{7,15}$/)]],
    });
  }

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.next.emit(this.form.value);
  }

  onBackClick(): void {
    this.back.emit();
  }
}
