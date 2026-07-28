import { Component, EventEmitter, Input, Output } from '@angular/core';

@Component({
  selector: 'app-form-actions',
  standalone: true,
  templateUrl: './form-actions.component.html',
  styleUrl: './form-actions.component.css'
})
export class FormActionsComponent {
  @Input() submitText: string = 'التالي';
  @Input() backText: string = 'السابق';
  @Input() showBack: boolean = true;
  @Input() disabled: boolean = false;

  @Output() submit = new EventEmitter<void>();
  @Output() back = new EventEmitter<void>();

  onSubmit(): void {
    if (!this.disabled) {
      this.submit.emit();
    }
  }

  onBack(): void {
    this.back.emit();
  }
}
