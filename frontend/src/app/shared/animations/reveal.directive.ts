import { Directive, ElementRef, EventEmitter, HostBinding, OnDestroy, OnInit, Output, inject, signal } from '@angular/core';

@Directive({
  selector: '[appReveal]',
  standalone: true,
})
export class RevealDirective implements OnInit, OnDestroy {
  private readonly elementRef = inject(ElementRef<HTMLElement>);
  private observer?: IntersectionObserver;
  private readonly isVisible = signal(false);

  @Output() readonly revealed = new EventEmitter<void>();

  @HostBinding('class.reveal') readonly baseClass = true;
  @HostBinding('class.reveal--visible') get visibleClass(): boolean {
    return this.isVisible();
  }

  ngOnInit(): void {
    if (typeof IntersectionObserver === 'undefined') {
      this.isVisible.set(true);
      this.revealed.emit();
      return;
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            this.isVisible.set(true);
            this.revealed.emit();
            this.observer?.unobserve(entry.target);
          }
        }
      },
      { threshold: 0.15, rootMargin: '0px 0px -60px 0px' },
    );

    this.observer.observe(this.elementRef.nativeElement);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
  }
}
