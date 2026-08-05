import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';

@Component({
  selector: 'app-pagination',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="pagination">
      <button class="page-btn" type="button" [disabled]="page() >= totalPages()" (click)="go(page() + 1)" aria-label="السابق">
        <svg width="6" height="9" viewBox="0 0 6 9" fill="none"><path d="M4.5 9L0 4.5L4.5 0L5.55 1.05L2.1 4.5L5.55 7.95L4.5 9Z" fill="#737686"/></svg>
      </button>
      @for (p of pages(); track p) {
        <button class="page-btn" type="button" [class.active]="p === page()" (click)="go(p)">{{ toArabicDigits(p) }}</button>
      }
      <button class="page-btn" type="button" [disabled]="page() <= 1" (click)="go(page() - 1)" aria-label="التالي">
        <svg width="6" height="9" viewBox="0 0 6 9" fill="none"><path d="M3.45 4.5L0 1.05L1.05 0L5.55 4.5L1.05 9L0 7.95L3.45 4.5Z" fill="#737686"/></svg>
      </button>
    </div>
  `,
  styles: `
    :host { display: block; }
    .pagination { display: flex; align-items: center; gap: 8px; }
    .page-btn {
      width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;
      border-radius: 4px; border: 1px solid rgba(195, 198, 215, 0.5); background: #fff;
      font-family: 'Noto Sans Arabic', sans-serif; font-weight: 700; font-size: 12px; color: #434655;
      cursor: pointer; transition: background 0.15s ease;
    }
    .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }
    .page-btn.active { background: #004AC6; border-color: #004AC6; color: #fff; }
    .page-btn:not(.active):not(:disabled):hover { background: #F8FAFC; }
  `,
})
export class PaginationComponent {
  page = input.required<number>();
  totalPages = input.required<number>();
  pageChange = output<number>();

  private static readonly ARABIC_DIGITS = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  pages = computed(() => {
    const total = this.totalPages();
    const current = this.page();
    const start = Math.max(1, Math.min(current - 1, total - 2));
    const list: number[] = [];
    for (let i = start; i < start + 3 && i <= total; i++) list.push(i);
    return list.reverse();
  });

  go(p: number) {
    if (p < 1 || p > this.totalPages()) return;
    this.pageChange.emit(p);
  }

  toArabicDigits(n: number): string {
    return String(n)
      .split('')
      .map((d) => PaginationComponent.ARABIC_DIGITS[Number(d)] ?? d)
      .join('');
  }
}
