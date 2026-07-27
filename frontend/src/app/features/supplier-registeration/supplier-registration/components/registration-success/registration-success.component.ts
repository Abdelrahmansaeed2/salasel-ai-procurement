import { ChangeDetectionStrategy, Component, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SupportCardComponent } from './components/support-card/support-card.component';

@Component({
  selector: 'app-registration-success',
  standalone: true,
  imports: [CommonModule, SupportCardComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './registration-success.component.html',
  styleUrl: './registration-success.component.css'
})
export class RegistrationSuccessComponent {
  @Output() finish = new EventEmitter<void>();

  goToDashboard(): void {
    this.finish.emit();
  }

  downloadPDF(): void {
    window.print();
  }
}
