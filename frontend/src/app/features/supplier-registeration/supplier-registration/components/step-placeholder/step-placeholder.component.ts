import { ChangeDetectionStrategy, Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-step-placeholder',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './step-placeholder.component.html',
  styleUrl: './step-placeholder.component.css',
})
export class StepPlaceholderComponent {
  @Input() step = 2;
  @Input() stepName = '';
  @Output() next = new EventEmitter<void>();
  @Output() back = new EventEmitter<void>();
  @Output() finish = new EventEmitter<void>();

  onNext(): void {
    this.next.emit();
  }

  onBack(): void {
    this.back.emit();
  }

  onFinish(): void {
    this.finish.emit();
  }
}
