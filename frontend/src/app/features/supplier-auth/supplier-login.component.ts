import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';

interface Statistic {
  value: string;
  label: string;
}

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

@Component({
  selector: 'app-supplier-login',
  standalone: true,
  imports: [FormsModule, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './supplier-login.component.html',
  styleUrl: './supplier-login.component.css',
})
export class SupplierLoginComponent {
  readonly email = signal('');
  readonly password = signal('');
  readonly rememberMe = signal(false);
  readonly showPassword = signal(false);
  readonly isSubmitting = signal(false);
  readonly errorMessage = signal<string | null>(null);

  readonly passwordInputType = computed(() => (this.showPassword() ? 'text' : 'password'));
  readonly canSubmit = computed(() => this.email().trim().length > 0 && this.password().length > 0);

  readonly statistics: Statistic[] = [
    { value: '15%', label: 'خفض التكاليف السنوية' },
    { value: '99.9%', label: 'وقت التشغيل المستمر' },
  ];

  togglePasswordVisibility(): void {
    this.showPassword.update((visible) => !visible);
  }

  toggleRememberMe(): void {
    this.rememberMe.update((checked) => !checked);
  }

  onSubmit(): void {
    const email = this.email().trim();
    const password = this.password();

    if (!EMAIL_PATTERN.test(email)) {
      this.errorMessage.set('يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    if (!password) {
      this.errorMessage.set('يرجى إدخال كلمة المرور');
      return;
    }

    this.errorMessage.set(null);
    this.isSubmitting.set(true);

    window.setTimeout(() => {
      this.isSubmitting.set(false);
    }, 900);
  }

  loginWithProvider(provider: 'microsoft' | 'google'): void {
    this.errorMessage.set(null);
    
    console.log(`تسجيل الدخول بواسطة ${provider}`);
  }
}
