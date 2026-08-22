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

    this.auth.login(email, password).subscribe({
      next: (res) => {
        this.isSubmitting.set(false);
        const returnUrl = this.activatedRoute.snapshot.queryParamMap.get('returnUrl');
        
        // If they are not verified/setup yet, you could route them to the setup wizard here
        // if (!res.isSetupCompleted) { ... }
        
        if (!returnUrl) {
          if (res.role === 'Admin') {
            this.router.navigateByUrl('/portal/analytics');
          } else {
            this.router.navigateByUrl('/portal/dashboard');
          }
        } else {
          this.router.navigateByUrl(returnUrl);
        }
      },
      error: (err: any) => {
        this.isSubmitting.set(false);
        if (err.status === 401) {
          this.errorMessage.set('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        } else {
          this.errorMessage.set('حدث خطأ في الاتصال بالخادم. يرجى المحاولة لاحقاً');
        }
      }
    });
  }
}
