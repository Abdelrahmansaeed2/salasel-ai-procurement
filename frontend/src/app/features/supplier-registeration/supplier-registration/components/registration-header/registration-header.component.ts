import { ChangeDetectionStrategy, Component, EventEmitter, Output } from '@angular/core';

@Component({
  selector: 'app-registration-header',
  standalone: true,
  imports: [],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './registration-header.component.html',
  styleUrl: './registration-header.component.css',
})
export class RegistrationHeaderComponent {
  @Output() saveAndExit = new EventEmitter<void>();

  onSaveAndExit(): void {
    this.saveAndExit.emit();
  }
}
