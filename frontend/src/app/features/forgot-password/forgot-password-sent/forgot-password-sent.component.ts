import { ChangeDetectionStrategy, Component, OnDestroy, OnInit, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';

import { DashboardTopbarComponent } from '../../../shared/dashboard-topbar/dashboard-topbar.component';

const RESEND_COOLDOWN_SECONDS = 59;

@Component({
  selector: 'app-forgot-password-sent',
  standalone: true,
  imports: [RouterLink, DashboardTopbarComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './forgot-password-sent.component.html',
  styleUrl: './forgot-password-sent.component.css',
})
export class ForgotPasswordSentComponent implements OnInit, OnDestroy {
  private readonly route = inject(ActivatedRoute);
  private intervalId: ReturnType<typeof setInterval> | undefined;

  readonly email = signal('');
  readonly secondsRemaining = signal(RESEND_COOLDOWN_SECONDS);
  readonly canResend = computed(() => this.secondsRemaining() <= 0);

  readonly formattedCountdown = computed(() => {
    const seconds = this.secondsRemaining();
    const minutes = Math.floor(seconds / 60);
    const rest = seconds % 60;
    return `${minutes}:${rest.toString().padStart(2, '0')}`;
  });

  ngOnInit(): void {
    this.email.set(this.route.snapshot.queryParamMap.get('email') ?? '');
    this.startCountdown();
  }

  ngOnDestroy(): void {
    this.clearCountdown();
  }

  resendEmail(): void {
    if (!this.canResend()) {
      return;
    }

    this.secondsRemaining.set(RESEND_COOLDOWN_SECONDS);
    this.startCountdown();
  }

  openMailApp(): void {
    window.location.href = 'mailto:';
  }

  private startCountdown(): void {
    this.clearCountdown();
    this.intervalId = setInterval(() => {
      this.secondsRemaining.update((seconds) => Math.max(0, seconds - 1));
      if (this.secondsRemaining() === 0) {
        this.clearCountdown();
      }
    }, 1000);
  }

  private clearCountdown(): void {
    if (this.intervalId !== undefined) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
  }
}
