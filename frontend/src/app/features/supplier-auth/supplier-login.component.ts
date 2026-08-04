import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';

import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { AuthService } from '../../core/auth/auth.service';

interface Statistic {
  value: string;
  label: string;
}

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

@Component({
  selector: 'app-supplier-login',
  standalone: true,
  imports: [FormsModule, RouterLink, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './supplier-login.component.html',
  styleUrl: './supplier-login.component.css',
})
export class SupplierLoginComponent {
  private readonly router = inject(Router);
  private readonly activatedRoute = inject(ActivatedRoute);
  private readonly auth = inject(AuthService);

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
      
      let role = 'Supplier';
      if (email.toLowerCase() === 'admin@salasel.com') {
        role = 'Admin';
      } else if (email.toLowerCase() === 'supplier@salasel.com') {
        role = 'Supplier';
      }

      this.auth.login(email, role);
      const returnUrl = this.activatedRoute.snapshot.queryParamMap.get('returnUrl');
      this.router.navigateByUrl(returnUrl ?? '/portal/dashboard');
    }, 900);
  }

  loginWithProvider(provider: 'microsoft' | 'google'): void {
    this.errorMessage.set(null);
    this.isSubmitting.set(true);

    window.setTimeout(() => {
      this.isSubmitting.set(false);
      this.auth.login(`supplier@${provider}.com`);
      const returnUrl = this.activatedRoute.snapshot.queryParamMap.get('returnUrl');
      this.router.navigateByUrl(returnUrl ?? '/portal/dashboard');
    }, 700);
  }
}
