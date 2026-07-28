import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-support-card',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './support-card.component.html',
  styleUrl: './support-card.component.css'
})
export class SupportCardComponent {
  onContactSupport(): void {
    window.open('mailto:support@salasel.sa', '_blank');
  }
}
