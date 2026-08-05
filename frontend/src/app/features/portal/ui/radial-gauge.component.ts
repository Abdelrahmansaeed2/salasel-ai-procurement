import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

@Component({
  selector: 'app-radial-gauge',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="gauge">
      <svg viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="42" fill="none" stroke="#E7E7F3" stroke-width="8" />
        <circle
          cx="50"
          cy="50"
          r="42"
          fill="none"
          [attr.stroke]="color()"
          stroke-width="8"
          stroke-linecap="round"
          [attr.stroke-dasharray]="circumference()"
          [attr.stroke-dashoffset]="dashOffset()"
          transform="rotate(-90 50 50)"
        />
      </svg>
      <div class="gauge-value">{{ percent() }}%</div>
    </div>
  `,
  styles: `
    :host { display: block; }
    .gauge { position: relative; width: 100%; aspect-ratio: 1; }
    .gauge svg { width: 100%; height: 100%; }
    .gauge svg circle[stroke-dasharray] {
      transition: stroke-dashoffset 0.8s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .gauge-value {
      position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
      font-family: 'Inter', sans-serif; font-weight: 700; font-size: 22px; color: #191B23;
      animation: gauge-fade-in 0.5s ease 0.3s both;
    }
    @keyframes gauge-fade-in {
      from { opacity: 0; transform: scale(0.9); }
      to { opacity: 1; transform: scale(1); }
    }
  `,
})
export class RadialGaugeComponent {
  percent = input.required<number>();
  color = input('#004AC6');

  circumference = computed(() => 2 * Math.PI * 42);
  dashOffset = computed(() => this.circumference() * (1 - this.percent() / 100));
}
