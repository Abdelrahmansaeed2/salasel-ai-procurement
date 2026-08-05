import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

@Component({
  selector: 'app-area-line-chart',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <svg [attr.viewBox]="'0 0 ' + width() + ' ' + height()" preserveAspectRatio="none" class="area-chart">
      <defs>
        <linearGradient [attr.id]="gradientId()" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" [attr.stop-color]="color()" stop-opacity="0.22" />
          <stop offset="100%" [attr.stop-color]="color()" stop-opacity="0" />
        </linearGradient>
      </defs>
      @for (y of gridLines(); track y) {
        <line x1="0" [attr.y1]="y" [attr.x2]="width()" [attr.y2]="y" stroke="#F1F5F9" stroke-width="1" stroke-dasharray="3 3" />
      }
      <path [attr.d]="areaPath()" [attr.fill]="'url(#' + gradientId() + ')'" stroke="none" />
      <path [attr.d]="linePath()" fill="none" [attr.stroke]="color()" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
    </svg>
    <div class="axis-labels">
      @for (label of labels(); track $index) {
        <span>{{ label }}</span>
      }
    </div>
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 8px; width: 100%; }
    .area-chart { width: 100%; height: 220px; display: block; }
    .area-chart path[stroke] {
      stroke-dasharray: 1400;
      stroke-dashoffset: 1400;
      animation: line-draw 1s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    .area-chart path[fill^="url"] {
      opacity: 0;
      animation: area-fade-in 0.8s ease 0.3s forwards;
    }
    @keyframes line-draw {
      to { stroke-dashoffset: 0; }
    }
    @keyframes area-fade-in {
      to { opacity: 1; }
    }
    .axis-labels { display: flex; justify-content: space-between; padding: 0 4px; }
    .axis-labels span { font-family: 'JetBrains Mono', monospace; font-size: 11px; color: #94A3B8; }
  `,
})
export class AreaLineChartComponent {
  points = input.required<number[]>();
  labels = input<string[]>([]);
  color = input('#004AC6');
  width = input(660);
  height = input(220);

  gradientId = computed(() => 'area-grad-' + Math.random().toString(36).slice(2, 9));

  private coords = computed(() => {
    const values = this.points();
    const w = this.width();
    const h = this.height();
    if (!values.length) return [] as { x: number; y: number }[];
    const min = Math.min(...values);
    const max = Math.max(...values);
    const range = max - min || 1;
    const stepX = w / (values.length - 1 || 1);
    return values.map((v, i) => ({
      x: i * stepX,
      y: h - 12 - ((v - min) / range) * (h - 24),
    }));
  });

  gridLines = computed(() => {
    const h = this.height();
    return [0.15, 0.4, 0.65, 0.9].map((f) => h * f);
  });

  linePath = computed(() => {
    const pts = this.coords();
    if (!pts.length) return '';
    return pts.map((p, i) => `${i === 0 ? 'M' : 'L'}${p.x.toFixed(2)} ${p.y.toFixed(2)}`).join(' ');
  });

  areaPath = computed(() => {
    const pts = this.coords();
    if (!pts.length) return '';
    const h = this.height();
    const first = pts[0];
    const last = pts[pts.length - 1];
    const line = pts.map((p, i) => `${i === 0 ? 'M' : 'L'}${p.x.toFixed(2)} ${p.y.toFixed(2)}`).join(' ');
    return `${line} L${last.x.toFixed(2)} ${h} L${first.x.toFixed(2)} ${h} Z`;
  });
}
