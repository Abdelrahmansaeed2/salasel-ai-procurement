import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

@Component({
  selector: 'app-bar-chart',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="bars">
      @for (bar of bars(); track $index) {
        <div class="bar-col">
          <div class="bar" [style.height.%]="bar.heightPercent" [style.background]="bar.highlighted ? highlightColor() : color()"></div>
        </div>
      }
    </div>
    <div class="axis-labels">
      @for (label of labels(); track $index) {
        <span>{{ label }}</span>
      }
    </div>
  `,
  styles: `
    :host { display: flex; flex-direction: column; gap: 8px; width: 100%; }
    .bars { display: flex; align-items: flex-end; gap: 6px; height: 160px; width: 100%; }
    .bar-col { flex: 1; height: 100%; display: flex; align-items: flex-end; }
    .bar { width: 100%; border-radius: 8px 8px 0 0; min-height: 4px; transition: height 0.3s ease; }
    .axis-labels { display: flex; justify-content: space-between; padding: 0 2px; }
    .axis-labels span { font-family: 'JetBrains Mono', monospace; font-size: 10px; color: #94A3B8; }
  `,
})
export class BarChartComponent {
  values = input.required<number[]>();
  labels = input<string[]>([]);
  color = input('#8B5CF6');
  highlightColor = input('#6D28D9');
  highlightLastIndex = input(true);

  bars = computed(() => {
    const vals = this.values();
    const max = Math.max(...vals, 1);
    return vals.map((v, i) => ({
      heightPercent: (v / max) * 100,
      highlighted: this.highlightLastIndex() && i === vals.length - 1,
    }));
  });
}
