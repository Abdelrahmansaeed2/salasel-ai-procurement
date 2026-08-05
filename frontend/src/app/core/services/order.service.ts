import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface SubmitBidDto {
  amount: number;
}

@Injectable({
  providedIn: 'root'
})
export class OrderService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/v1/orders`;

  getKanban(supplierId: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/rfqs/kanban?supplierId=${supplierId}`);
  }

  submitBid(id: number, amount: number): Observable<any> {
    return this.http.put(`${this.apiUrl}/rfqs/${id}/bid`, { amount });
  }

  dispatchOrder(id: number): Observable<any> {
    return this.http.put(`${this.apiUrl}/voice/${id}/dispatch`, {});
  }
}
