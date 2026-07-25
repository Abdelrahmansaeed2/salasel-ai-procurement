import { ChangeDetectionStrategy, Component, HostListener, Input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';

interface NavLink {
  label: string;
  route: string | null;
}

@Component({
  selector: 'app-site-header',
  standalone: true,
  imports: [RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './site-header.component.html',
  styleUrl: './site-header.component.css',
})
export class SiteHeaderComponent {
  @Input() activeLink = 'المنصة';

  readonly isMobileMenuOpen = signal(false);
  readonly isScrolled = signal(false);

  private scrollTicking = false;

  readonly navLinks: NavLink[] = [
    { label: 'تواصل معنا', route: '/contact' },
    { label: 'الأسعار', route: null },
    { label: 'الموردين', route: null },
    { label: 'الحزمة التقنية', route: null },
    { label: 'من نحن', route: '/about' },
    { label: 'المنصة', route: '/' },
  ];

  toggleMobileMenu(): void {
    this.isMobileMenuOpen.update((open) => !open);
  }

  @HostListener('window:scroll')
  onWindowScroll(): void {
    if (this.scrollTicking) {
      return;
    }
    this.scrollTicking = true;
    requestAnimationFrame(() => {
      this.isScrolled.set(window.scrollY > 8);
      this.scrollTicking = false;
    });
  }
}
