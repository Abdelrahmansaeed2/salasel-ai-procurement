import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

@Component({
  selector: 'app-sparkline',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <svg [attr.viewBox]="'0 0 80 28'" preserveAspectRatio="none" class="sparkline">
      <path [attr.d]="path()" fill="none" [attr.stroke]="color()" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" opacity="0.85" />
    </svg>
  `,
  styles: `
    :host { display: block; width: 80px; height: 28px; }
    .sparkline { width: 100%; height: 100%; display: block; }
    .sparkline path {
      stroke-dasharray: 200;
      stroke-dashoffset: 200;
      animation: spark-draw 0.9s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    @keyframes spark-draw {
      to { stroke-dashoffset: 0; }
    }
  `,
})
export class SparklineComponent {
  points = input.required<number[]>();
  color = input('#2563EB');

  path = computed(() => {
    const values = this.points();
    if (!values.length) return '';
    const min = Math.min(...values);
    const max = Math.max(...values);
    const range = max - min || 1;
    const stepX = 80 / (values.length - 1 || 1);
    return values
      .map((v, i) => {
        const x = i * stepX;
        const y = 26 - ((v - min) / range) * 24;
        return `${i === 0 ? 'M' : 'L'}${x.toFixed(2)} ${y.toFixed(2)}`;
      })
      .join(' ');
  });
}
