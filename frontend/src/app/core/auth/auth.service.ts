import { Injectable, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';

const STORAGE_KEY = 'jawhra_portal_session';
const TOKEN_KEY = 'jawhra_auth_token';

interface PortalSession {
  name: string;
  email: string;
  role: string;
}

export interface AuthResponseDto {
  userID: number;
  fullName: string;
  email: string;
  token: string;
  role: string;
  isSetupCompleted: boolean;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly session = signal<PortalSession | null>(this.restoreSession());

  readonly isAuthenticated = computed(() => this.session() !== null);
  readonly currentUser = computed(() => this.session());

  getToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  login(email: string, password: string): Observable<AuthResponseDto> {
    return this.http.post<AuthResponseDto>(`${environment.apiUrl}/auth/login`, { email, password }).pipe(
      tap((res) => {
        const session: PortalSession = { name: res.fullName, email: res.email, role: res.role };
        this.session.set(session);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
        localStorage.setItem(TOKEN_KEY, res.token);
      })
    );
  }

  register(data: any): Observable<AuthResponseDto> {
    return this.http.post<AuthResponseDto>(`${environment.apiUrl}/auth/register`, data).pipe(
      tap((res) => {
        const session: PortalSession = { name: res.fullName, email: res.email, role: res.role };
        this.session.set(session);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
        localStorage.setItem(TOKEN_KEY, res.token);
      })
    );
  }

  forgotPassword(email: string): Observable<void> {
    return this.http.post<void>(`${environment.apiUrl}/auth/forgot-password`, { email });
  }

  resetPassword(token: string, newPassword: string): Observable<void> {
    return this.http.post<void>(`${environment.apiUrl}/auth/reset-password`, { token, newPassword });
  }

  logout(): void {
    this.session.set(null);
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(TOKEN_KEY);
  }

  private restoreSession(): PortalSession | null {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? (JSON.parse(raw) as PortalSession) : null;
    } catch {
      return null;
    }
  }
}
