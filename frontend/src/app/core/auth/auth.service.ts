import { Injectable, computed, signal } from '@angular/core';

const STORAGE_KEY = 'jawhra_portal_session';

interface PortalSession {
  name: string;
  email: string;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly session = signal<PortalSession | null>(this.restoreSession());

  readonly isAuthenticated = computed(() => this.session() !== null);
  readonly currentUser = computed(() => this.session());

  login(email: string, name = 'محمد العتيبي'): void {
    const session: PortalSession = { name, email };
    this.session.set(session);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
  }

  logout(): void {
    this.session.set(null);
    localStorage.removeItem(STORAGE_KEY);
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
