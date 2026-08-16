import { Injectable, signal } from '@angular/core';
import * as signalR from '@microsoft/signalr';
import { AuthService } from '../auth/auth.service';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class SignalRService {
  private hubConnection: signalR.HubConnection | null = null;
  public isConnected = signal<boolean>(false);

  constructor(private authService: AuthService) {}

  public startConnection(): void {
    const token = this.authService.getToken();
    if (!token) return;

    this.hubConnection = new signalR.HubConnectionBuilder()
      .withUrl(`${environment.apiUrl.replace('/api/v1', '')}/hubs/notifications`, {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .build();

    this.hubConnection
      .start()
      .then(() => {
        console.log('SignalR connected');
        this.isConnected.set(true);
      })
      .catch(err => console.error('Error while starting connection: ' + err));
  }

  public on(eventName: string, action: (...args: any[]) => void): void {
    if (this.hubConnection) {
      this.hubConnection.on(eventName, action);
    } else {
      // Wait for connection to start before subscribing
      setTimeout(() => this.on(eventName, action), 500);
    }
  }

  public stopConnection(): void {
    if (this.hubConnection) {
      this.hubConnection.stop();
      this.isConnected.set(false);
    }
  }
}
