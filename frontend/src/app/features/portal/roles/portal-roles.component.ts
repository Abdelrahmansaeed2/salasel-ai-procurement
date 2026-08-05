import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';
import { PaginationComponent } from '../ui/pagination.component';

type PermissionKey = 'read' | 'write' | 'delete' | 'approve';

interface ResourcePermissions {
  key: string;
  name: string;
  description: string;
  read: boolean;
  write: boolean;
  delete: boolean;
  approve: boolean;
}

const INITIAL_RESOURCES: ResourcePermissions[] = [
  { key: 'orders', name: 'الطلبات', description: 'طلبات شراء العملاء وحالات التنفيذ.', read: true, write: true, delete: false, approve: false },
  { key: 'catalog', name: 'الكتالوج', description: 'قوائم المنتجات والأوصاف ومستويات المخزون.', read: true, write: false, delete: false, approve: false },
  { key: 'suppliers', name: 'الموردين', description: 'إدارة بيانات الموردين وعقود التوريد.', read: true, write: false, delete: false, approve: false },
  { key: 'warehouses', name: 'المستودعات', description: 'التحكم في مواقع التخزين وحركات المخزون.', read: true, write: true, delete: false, approve: false },
  { key: 'finance', name: 'التقارير المالية', description: 'الوصول إلى الميزانيات والتقارير الضريبية.', read: false, write: false, delete: false, approve: false },
  { key: 'users', name: 'إدارة المستخدمين', description: 'إضافة وتعديل حسابات الموظفين وصلاحياتهم.', read: false, write: false, delete: false, approve: false },
  { key: 'system', name: 'إعدادات النظام', description: 'تكوين المعلمات الأساسية للنظام والواجهات.', read: true, write: false, delete: false, approve: false },
];

@Component({
  selector: 'app-portal-roles',
  standalone: true,
  imports: [PaginationComponent],
  templateUrl: './portal-roles.component.html',
  styleUrl: './portal-roles.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalRolesComponent {
  readonly roles = ['موظف مستودع', 'مدير مشتريات', 'محاسب', 'مسؤول النظام'];
  readonly activeRole = signal(this.roles[0]);
  readonly roleMenuOpen = signal(false);

  readonly resources = signal<ResourcePermissions[]>(INITIAL_RESOURCES.map((r) => ({ ...r })));
  private readonly savedSnapshot = signal(JSON.stringify(INITIAL_RESOURCES));

  readonly isDirty = computed(() => JSON.stringify(this.resources()) !== this.savedSnapshot());

  readonly page = signal(1);
  readonly totalPages = 4;

  toggleRoleMenu() {
    this.roleMenuOpen.update((v) => !v);
  }

  selectRole(role: string) {
    this.activeRole.set(role);
    this.roleMenuOpen.set(false);
  }

  togglePermission(resourceKey: string, permission: PermissionKey) {
    this.resources.update((list) =>
      list.map((r) => (r.key === resourceKey ? { ...r, [permission]: !r[permission] } : r)),
    );
  }

  save() {
    this.savedSnapshot.set(JSON.stringify(this.resources()));
  }

  discard() {
    this.resources.set(INITIAL_RESOURCES.map((r) => ({ ...r })));
    this.savedSnapshot.set(JSON.stringify(INITIAL_RESOURCES));
  }

  goToPage(page: number) {
    this.page.set(page);
  }
}
