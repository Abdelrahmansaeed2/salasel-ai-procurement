import { ChangeDetectionStrategy, Component, inject, signal, computed } from '@angular/core';
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

  // Notifications State
  readonly notificationsOpen = signal(false);
  readonly unreadCount = signal(3);
  readonly showToast = signal(false);
  
  readonly recentNotifications = signal([
    { id: 1, title: 'طلب تسعير جديد', text: 'تم استلام طلب تسعير من "بقالة ركن الياسمين".', time: 'منذ دقيقتين', unread: true },
    { id: 2, title: 'تحديث حالة الطلب', text: 'الطلب #ORD-8791 تم تسليمه بنجاح.', time: 'منذ ٤٥ دقيقة', unread: true },
    { id: 3, title: 'اعتماد حساب', text: 'تم توثيق حسابك كمورد معتمد بنجاح.', time: 'منذ ساعتين', unread: true },
  ]);

  toggleNotifications() {
    this.notificationsOpen.update((v) => !v);
    if (this.notificationsOpen()) {
      this.userMenuOpen.set(false);
    }
  }

  markAllAsRead() {
    this.unreadCount.set(0);
    this.recentNotifications.update(n => n.map(item => ({ ...item, unread: false })));
  }

  triggerDemoToast() {
    this.showToast.set(true);
    setTimeout(() => this.showToast.set(false), 5000);
  }

  readonly navItems = computed<PortalNavItem[]>(() => {
    const role = this.currentUser()?.role;

    if (role === 'Admin') {
      return [
        { label: 'التحليلات', route: '/portal/analytics', icon: 'analytics' },
        { label: 'اعتمادات النظام', route: '/portal/approvals', icon: 'audit', badge: 2 },
        { label: 'مصفوفة الأدوار', route: '/portal/roles', icon: 'roles' },
        { label: 'إدارة مركز المساعدة', route: '/portal/help-center-editor', icon: 'settings' },
        { label: 'الإعدادات', route: '/portal/settings', icon: 'settings' },
      ];
    } else {
      // Default: Supplier
      return [
        { label: 'لوحة التحكم', route: '/portal/dashboard', icon: 'dashboard' },
        { label: 'الطلبات', route: '/portal/orders', icon: 'orders', badge: 7 },
        { label: 'الكتالوج (قاعدة المعرفة)', route: '/portal/supplier-knowledge', icon: 'catalog' },
        { label: 'الإعدادات', route: '/portal/settings', icon: 'settings' },
      ];
    }
  });

  toggleSidebar() {
    this.sidebarCollapsed.update((v) => !v);
  }

  toggleUserMenu() {
    this.userMenuOpen.update((v) => !v);
    if (this.userMenuOpen()) {
      this.notificationsOpen.set(false);
    }
  }

  logout() {
    this.auth.logout();
    this.router.navigate(['/supplier-login']);
  }
}
