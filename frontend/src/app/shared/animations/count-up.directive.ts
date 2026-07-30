import { Directive, ElementRef, Input, OnChanges, SimpleChanges, inject } from '@angular/core';

/**
 * Animates a numeric value from 0 to the target value using requestAnimationFrame
 * with an easeOutQuad easing curve. Respects `prefers-reduced-motion`.
 *
 * Usage:
 *   <span [appCountUp]="142"></span>
 *   <span [appCountUp]="12450" [countUpFormatter]="myFormatter"></span>
 */
@Directive({
  selector: '[appCountUp]',
  standalone: true,
})
export class CountUpDirective implements OnChanges {
  private readonly elementRef = inject(ElementRef<HTMLElement>);
  private frameId: number | null = null;
  private hasAnimated = false;

  @Input('appCountUp') target = 0;
  @Input() countUpDuration = 800;
  @Input() countUpDecimals = 0;
  @Input() countUpFormatter?: (value: number) => string;

  ngOnChanges(changes: SimpleChanges): void {
    if (!('target' in changes)) {
      return;
    }

    const prefersReducedMotion =
      typeof window !== 'undefined' &&
      typeof window.matchMedia === 'function' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (prefersReducedMotion) {
      this.render(this.target);
      return;
    }

    // Only run the count-up animation once (on first meaningful value), then
    // just re-render immediately on subsequent updates to avoid re-animating
    // every time change detection runs.
    if (this.hasAnimated) {
      this.render(this.target);
      return;
    }

    this.animate();
  }

  private animate(): void {
    if (this.frameId !== null) {
      cancelAnimationFrame(this.frameId);
    }

    this.hasAnimated = true;
    const target = this.target;
    const duration = this.countUpDuration;
    const start = performance.now();

    const step = (now: number) => {
      const elapsed = now - start;
      const t = Math.min(elapsed / duration, 1);
      const eased = 1 - (1 - t) * (1 - t); // easeOutQuad
      const value = target * eased;

      this.render(value);

      if (t < 1) {
        this.frameId = requestAnimationFrame(step);
      } else {
        this.frameId = null;
        this.render(target);
      }
    };

    this.frameId = requestAnimationFrame(step);
  }

  private render(value: number): void {
    const rounded =
      this.countUpDecimals > 0
        ? Number(value.toFixed(this.countUpDecimals))
        : Math.round(value);

    this.elementRef.nativeElement.textContent = this.countUpFormatter
      ? this.countUpFormatter(rounded)
      : String(rounded);
  }
}
