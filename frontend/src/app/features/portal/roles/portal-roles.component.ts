import { ChangeDetectionStrategy, Component, computed, signal, inject, OnInit } from '@angular/core';
import { SupplierRolesService, SupplierRoleDto, ResourcePermissionsDto } from '../../../core/services/supplier-roles.service';
import { PaginationComponent } from '../ui/pagination.component';

type PermissionKey = 'read' | 'write' | 'delete' | 'approve';



@Component({
  selector: 'app-portal-roles',
  standalone: true,
  imports: [PaginationComponent],
  templateUrl: './portal-roles.component.html',
  styleUrl: './portal-roles.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalRolesComponent implements OnInit {
  private rolesService = inject(SupplierRolesService);

  readonly roles = signal<SupplierRoleDto[]>([]);
  readonly activeRole = signal<string | null>(null);
  readonly roleMenuOpen = signal(false);
  readonly isSaving = signal(false);

  readonly resources = signal<ResourcePermissionsDto[]>([]);
  private readonly savedSnapshot = signal<string>('');

  readonly isDirty = computed(() => JSON.stringify(this.resources()) !== this.savedSnapshot());

  readonly page = signal(1);
  readonly totalPages = 4;

  ngOnInit() {
    this.rolesService.getRoles().subscribe({
      next: (data) => {
        this.roles.set(data);
        if (data.length > 0) {
          this.selectRole(data[0].roleName);
        }
      },
      error: (err) => console.error('Failed to load roles', err)
    });
  }

  toggleRoleMenu() {
    this.roleMenuOpen.update((v) => !v);
  }

  selectRole(roleName: string) {
    this.activeRole.set(roleName);
    this.roleMenuOpen.set(false);
    
    const role = this.roles().find(r => r.roleName === roleName);
    if (role) {
      // deep copy
      const resCopy = JSON.parse(JSON.stringify(role.resources));
      this.resources.set(resCopy);
      this.savedSnapshot.set(JSON.stringify(resCopy));
    }
  }

  togglePermission(resourceKey: string, permission: PermissionKey) {
    this.resources.update((list) =>
      list.map((r) => (r.key === resourceKey ? { ...r, [permission]: !r[permission] } : r)),
    );
  }

  save() {
    this.isSaving.set(true);
    
    // Update local role list with new resources
    const updatedRoles = this.roles().map(r => 
      r.roleName === this.activeRole() ? { ...r, resources: this.resources() } : r
    );
    
    this.rolesService.saveRoles(updatedRoles).subscribe({
      next: () => {
        this.roles.set(updatedRoles);
        this.savedSnapshot.set(JSON.stringify(this.resources()));
        this.isSaving.set(false);
        window.alert('تم حفظ الصلاحيات بنجاح.');
      },
      error: (err) => {
        console.error('Failed to save roles', err);
        this.isSaving.set(false);
      }
    });
  }

  discard() {
    if (this.savedSnapshot()) {
      this.resources.set(JSON.parse(this.savedSnapshot()));
    }
  }

  goToPage(page: number) {
    this.page.set(page);
  }
}
