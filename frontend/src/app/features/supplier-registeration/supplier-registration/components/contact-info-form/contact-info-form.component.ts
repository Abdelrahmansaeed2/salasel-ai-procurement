import { ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';

@Component({
  selector: 'app-contact-info-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
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
    // Seeded with the exact data from Figma review card to look strict to design
    this.form = this.fb.group({
      fullName: ['أحمد المنصور', [Validators.required, Validators.minLength(3)]],
      jobTitle: ['مدير المشتريات', [Validators.required, Validators.minLength(2)]],
      email: ['a.mansour@salasel.sa', [Validators.required, Validators.email]],
      phoneNumber: ['+966 50 123 4567', [Validators.required, Validators.pattern(/^\+?\d[\d\s-]{7,15}$/)]],
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
