import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-registration-stepper',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './registration-stepper.component.html',
  styleUrl: './registration-stepper.component.css',
})
export class RegistrationStepperComponent {
  @Input() currentStep = 1;
  @Input() steps: string[] = [];
  @Output() stepClick = new EventEmitter<number>();

  onStepClick(stepIndex: number): void {
    // Only allow clicking steps that are completed or the current one
    if (stepIndex + 1 <= this.currentStep) {
      this.stepClick.emit(stepIndex + 1);
    }
  }
}
