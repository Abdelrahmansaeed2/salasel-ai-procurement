import { ChangeDetectionStrategy, Component, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { SupportCardComponent } from './components/support-card/support-card.component';

@Component({
  selector: 'app-registration-success',
  standalone: true,
  imports: [CommonModule, RouterLink, SupportCardComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './registration-success.component.html',
  styleUrl: './registration-success.component.css'
})
export class RegistrationSuccessComponent {
  @Output() finish = new EventEmitter<void>();

  constructor(private router: Router) {}

  goToDashboard(): void {
    this.router.navigate(['/supplier-login']);
  }

  downloadPDF(): void {
    window.print();
  }
}
