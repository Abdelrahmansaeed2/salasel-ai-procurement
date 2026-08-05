import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

export interface PendingMerchant {
  merchantID: number;
  shopName: string;
  ownerName: string;
  crNumber: string;
  businessCity: string;
  createdAt: string;
  verificationStatus: string;
}

export interface AdminAnalytics {
  totalMerchants: number;
  totalSuppliers: number;
  totalOrders: number;
  totalGmv: number;
  totalRfqs: number;
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

  getPendingMerchants() {
    return this.http.get<PendingMerchant[]>(`${this.apiUrl}/merchants/pending`);
  }

  approveMerchant(merchantId: number) {
    return this.http.put<{ message: string }>(`${this.apiUrl}/merchants/${merchantId}/approve`, {});
  }

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
}
