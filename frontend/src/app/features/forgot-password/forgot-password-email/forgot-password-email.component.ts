import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';

import { DashboardTopbarComponent } from '../../../shared/dashboard-topbar/dashboard-topbar.component';

import { AuthService } from '../../../core/auth/auth.service';

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

@Component({
  selector: 'app-forgot-password-email',
  standalone: true,
  imports: [FormsModule, RouterLink, DashboardTopbarComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './forgot-password-email.component.html',
  styleUrl: './forgot-password-email.component.css',
})
export class ForgotPasswordEmailComponent {
  readonly email = signal('');
  readonly isSubmitting = signal(false);
  readonly errorMessage = signal<string | null>(null);

  readonly canSubmit = computed(() => this.email().trim().length > 0);

  constructor(
    private readonly router: Router,
    private readonly authService: AuthService
  ) {}

  onSubmit(): void {
    const email = this.email().trim();

    if (!EMAIL_PATTERN.test(email)) {
      this.errorMessage.set('يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    this.errorMessage.set(null);
    this.isSubmitting.set(true);

    this.authService.forgotPassword(email).subscribe({
      next: () => {
        this.isSubmitting.set(false);
        this.router.navigate(['/forgot-password/sent'], { queryParams: { email } });
      },
      error: (err) => {
        this.isSubmitting.set(false);
        if (err.status === 404) {
          this.errorMessage.set('لم نتمكن من العثور على حساب بهذا البريد الإلكتروني');
        } else {
          this.errorMessage.set('حدث خطأ أثناء إرسال الرابط. يرجى المحاولة لاحقاً');
        }
      }
    });
  }
}
