import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

export interface DonutSegment {
  label: string;
  value: number;
  color: string;
}

interface DonutArc {
  segment: DonutSegment;
  path: string;
  percent: number;
}

@Component({
  selector: 'app-donut-chart',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <svg viewBox="0 0 100 100" class="donut">
      @for (arc of arcs(); track arc.segment.label) {
        <path [attr.d]="arc.path" [attr.fill]="arc.segment.color" />
      }
      <circle cx="50" cy="50" [attr.r]="innerRadius()" fill="var(--portal-surface, #fff)" />
    </svg>
  `,
  styles: `
    :host { display: block; }
    .donut { width: 100%; height: 100%; display: block; }
    .donut path {
      transform-origin: 50px 50px;
      transition: transform 0.2s ease, opacity 0.2s ease;
      animation: donut-in 0.5s cubic-bezier(0.16, 1, 0.3, 1) both;
    }
    .donut path:hover { transform: scale(1.04); opacity: 0.9; }
    @keyframes donut-in {
      from { opacity: 0; transform: scale(0.85); }
      to { opacity: 1; transform: scale(1); }
    }
  `,
})
export class DonutChartComponent {
  segments = input.required<DonutSegment[]>();
  innerRadius = input(32);

  private polarToCartesian(cx: number, cy: number, r: number, angleDeg: number) {
    const angleRad = ((angleDeg - 90) * Math.PI) / 180;
    return { x: cx + r * Math.cos(angleRad), y: cy + r * Math.sin(angleRad) };
  }

  arcs = computed<DonutArc[]>(() => {
    const segs = this.segments();
    const total = segs.reduce((sum, s) => sum + s.value, 0) || 1;
    const r = 50;
    let cursor = 0;
    return segs.map((segment) => {
      const percent = (segment.value / total) * 100;
      const startAngle = (cursor / total) * 360;
      cursor += segment.value;
      const endAngle = (cursor / total) * 360;
      const start = this.polarToCartesian(50, 50, r, endAngle);
      const end = this.polarToCartesian(50, 50, r, startAngle);
      const largeArc = endAngle - startAngle > 180 ? 1 : 0;
      const path = `M 50 50 L ${start.x.toFixed(3)} ${start.y.toFixed(3)} A ${r} ${r} 0 ${largeArc} 0 ${end.x.toFixed(3)} ${end.y.toFixed(3)} Z`;
      return { segment, path, percent };
    });
  });
}
