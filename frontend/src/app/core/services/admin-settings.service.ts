import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface SystemConfigurationDto {
  id: number;
  key: string;
  value: string;
  description: string;
  lastUpdated: string;
}

export interface UpdateSystemConfigurationDto {
  value: string;
}

@Injectable({
  providedIn: 'root'
})
export class AdminSettingsService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/admin/settings`;

  getSettings(): Observable<SystemConfigurationDto[]> {
    return this.http.get<SystemConfigurationDto[]>(this.apiUrl);
  }

  updateSetting(key: string, data: UpdateSystemConfigurationDto): Observable<SystemConfigurationDto> {
    return this.http.put<SystemConfigurationDto>(`${this.apiUrl}/${key}`, data);
  }
}
