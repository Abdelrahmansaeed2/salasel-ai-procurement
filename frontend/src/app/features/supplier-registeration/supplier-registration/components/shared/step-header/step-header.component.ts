import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-step-header',
  standalone: true,
  templateUrl: './step-header.component.html',
  styleUrl: './step-header.component.css'
})
export class StepHeaderComponent {
  @Input({ required: true }) title!: string;
  @Input() subtitle?: string;
}
