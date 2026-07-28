import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';

import { DashboardTopbarComponent } from '../../../shared/dashboard-topbar/dashboard-topbar.component';

interface PasswordRequirement {
  key: string;
  label: string;
  met: boolean;
}

@Component({
  selector: 'app-forgot-password-reset',
  standalone: true,
  imports: [FormsModule, RouterLink, DashboardTopbarComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './forgot-password-reset.component.html',
  styleUrl: './forgot-password-reset.component.css',
})
export class ForgotPasswordResetComponent {
  readonly password = signal('');
  readonly confirmPassword = signal('');
  readonly showPassword = signal(false);
  readonly showConfirmPassword = signal(false);
  readonly errorMessage = signal<string | null>(null);
  readonly isSubmitting = signal(false);

  readonly passwordInputType = computed(() => (this.showPassword() ? 'text' : 'password'));
  readonly confirmPasswordInputType = computed(() => (this.showConfirmPassword() ? 'text' : 'password'));

  readonly requirements = computed<PasswordRequirement[]>(() => {
    const value = this.password();
    return [
      { key: 'length', label: '12 حرفًا على الأقل', met: value.length >= 12 },
      { key: 'upper', label: 'حرف كبير', met: /[A-Z]/.test(value) },
      { key: 'lower', label: 'حرف صغير', met: /[a-z]/.test(value) },
      { key: 'digit', label: 'رقم', met: /\d/.test(value) },
      { key: 'special', label: 'رمز خاص (!@#$%)', met: /[!@#$%^&*(),.?":{}|<>]/.test(value) },
    ];
  });

  readonly metCount = computed(() => this.requirements().filter((requirement) => requirement.met).length);

  readonly strengthLevel = computed(() => {
    if (this.password().length === 0) {
      return 0;
    }
    const met = this.metCount();
    if (met <= 2) {
      return 1;
    }
    if (met <= 4) {
      return 2;
    }
    return 3;
  });

  readonly strengthLabel = computed(() => {
    switch (this.strengthLevel()) {
      case 1:
        return 'ضعيفة';
      case 2:
        return 'متوسطة';
      case 3:
        return 'قوية';
      default:
        return 'غير محددة';
    }
  });

  readonly passwordsMatch = computed(
    () => this.confirmPassword().length > 0 && this.confirmPassword() === this.password(),
  );

  readonly canSubmit = computed(() => this.metCount() === 5 && this.passwordsMatch());

  constructor(private readonly router: Router) {}

  togglePasswordVisibility(): void {
    this.showPassword.update((visible) => !visible);
  }

  toggleConfirmPasswordVisibility(): void {
    this.showConfirmPassword.update((visible) => !visible);
  }

  onSubmit(): void {
    if (this.metCount() < 5) {
      this.errorMessage.set('يرجى استيفاء جميع متطلبات كلمة المرور');
      return;
    }

    if (!this.passwordsMatch()) {
      this.errorMessage.set('كلمتا المرور غير متطابقتين');
      return;
    }

    this.errorMessage.set(null);
    this.isSubmitting.set(true);

    window.setTimeout(() => {
      this.isSubmitting.set(false);
      this.router.navigate(['/forgot-password/success']);
    }, 700);
  }
}
