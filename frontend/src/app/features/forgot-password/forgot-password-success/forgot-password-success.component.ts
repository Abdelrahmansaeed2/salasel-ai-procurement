import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterLink } from '@angular/router';

import { DashboardTopbarComponent } from '../../../shared/dashboard-topbar/dashboard-topbar.component';

@Component({
  selector: 'app-forgot-password-success',
  standalone: true,
  imports: [RouterLink, DashboardTopbarComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './forgot-password-success.component.html',
  styleUrl: './forgot-password-success.component.css',
})
export class ForgotPasswordSuccessComponent {}
