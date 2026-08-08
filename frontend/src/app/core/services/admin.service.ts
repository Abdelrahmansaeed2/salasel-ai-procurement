import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

export interface PendingMerchant {
  merchantId: number;
  shopName: string;
  ownerName: string;
  crNumber: string;
  businessCity: string;
  createdAt: string;
  verificationStatus: string;
}

export interface PendingSupplier {
  supplierId: number;
  companyName: string;
  crNumber: string;
  registrationStep: number;
  createdAt: string;
  verificationStatus: string;
}

export interface AdminRejectRequest {
  reason: string;
}

export interface AdminAnalytics {
  activeMerchants: number;
  activeSuppliers: number;
  totalGmv: number;
  averageAiLatency: string;
}

export interface KnowledgeBaseArticle {
  id: number;
  title: string;
  content: string;
  category: string;
  createdAt: string;
  updatedAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class AdminService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/admin`;

  // Merchants
  getPendingMerchants() {
    return this.http.get<PendingMerchant[]>(`${this.apiUrl}/pending-merchants`);
  }

  approveMerchant(merchantId: number) {
    return this.http.put<{ message: string }>(`${this.apiUrl}/merchants/${merchantId}/approve`, {});
  }

  rejectMerchant(merchantId: number, reason: string) {
    return this.http.put<{ message: string }>(`${this.apiUrl}/merchants/${merchantId}/reject`, { reason } as AdminRejectRequest);
  }

  // Suppliers
  getPendingSuppliers() {
    return this.http.get<PendingSupplier[]>(`${this.apiUrl}/pending-suppliers`);
  }

  approveSupplier(supplierId: number) {
    return this.http.put<{ message: string }>(`${this.apiUrl}/suppliers/${supplierId}/approve`, {});
  }

  rejectSupplier(supplierId: number, reason: string) {
    return this.http.put<{ message: string }>(`${this.apiUrl}/suppliers/${supplierId}/reject`, { reason } as AdminRejectRequest);
  }

  // Analytics
  getAnalytics() {
    return this.http.get<AdminAnalytics>(`${this.apiUrl}/analytics`);
  }

  // Text-based Knowledge Base
  getKnowledgeBaseArticles() {
    return this.http.get<KnowledgeBaseArticle[]>(`${this.apiUrl}/knowledge-base`);
  }

  createKnowledgeBaseArticle(article: Partial<KnowledgeBaseArticle>) {
    return this.http.post<KnowledgeBaseArticle>(`${this.apiUrl}/knowledge-base`, article);
  }

  updateKnowledgeBaseArticle(id: number, article: Partial<KnowledgeBaseArticle>) {
    return this.http.put(`${this.apiUrl}/knowledge-base/${id}`, article);
  }

  deleteKnowledgeBaseArticle(id: number) {
    return this.http.delete(`${this.apiUrl}/knowledge-base/${id}`);
  }

  // AI Sync
  forceSyncCatalogToAi() {
    return this.http.post<{ message: string; attempted: number }>(`${this.apiUrl}/ai/sync-catalog`, {});
  }
}
