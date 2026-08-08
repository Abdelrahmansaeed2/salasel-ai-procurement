import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface ResourcePermissionsDto {
  key: string;
  name: string;
  description: string;
  read: boolean;
  write: boolean;
  delete: boolean;
  approve: boolean;
}

export interface SupplierRoleDto {
  roleName: string;
  resources: ResourcePermissionsDto[];
}

@Injectable({
  providedIn: 'root'
})
export class SupplierRolesService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/suppliers/roles`;

  getRoles(): Observable<SupplierRoleDto[]> {
    return this.http.get<SupplierRoleDto[]>(this.apiUrl);
  }

  saveRoles(roles: SupplierRoleDto[]): Observable<{ message: string }> {
    return this.http.post<{ message: string }>(this.apiUrl, roles);
  }
}
