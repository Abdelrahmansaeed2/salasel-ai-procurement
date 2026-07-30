import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../../core/auth/auth.service';

interface PortalNavItem {
  label: string;
  route: string;
  icon: 'dashboard' | 'orders' | 'catalog' | 'analytics' | 'audit' | 'team' | 'roles' | 'settings';
  badge?: number;
}

@Component({
  selector: 'app-portal-layout',
  standalone: true,
  imports: [RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './portal-layout.component.html',
  styleUrl: './portal-layout.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { dir: 'rtl' },
})
export class PortalLayoutComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  readonly sidebarCollapsed = signal(false);
  readonly userMenuOpen = signal(false);
  readonly currentUser = this.auth.currentUser;

  readonly navItems: PortalNavItem[] = [
    { label: 'لوحة التحكم', route: '/portal/dashboard', icon: 'dashboard' },
    { label: 'الطلبات', route: '/portal/orders', icon: 'orders', badge: 7 },
    { label: 'الكتالوج', route: '/portal/catalog', icon: 'catalog' },
    { label: 'التحليلات', route: '/portal/analytics', icon: 'analytics' },
    { label: 'مصفوفة الأدوار', route: '/portal/roles', icon: 'roles' },
    { label: 'الإعدادات', route: '/portal/settings', icon: 'settings' },
  ];

  toggleSidebar() {
    this.sidebarCollapsed.update((v) => !v);
  }

  toggleUserMenu() {
    this.userMenuOpen.update((v) => !v);
  }

  logout() {
    this.auth.logout();
    this.router.navigate(['/supplier-login']);
  }
}
