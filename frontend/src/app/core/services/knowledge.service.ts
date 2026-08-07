import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface KnowledgeDocument {
  id: number;
  fileName: string;
  fileType: string;
  fileUrl: string;
  status: string;
  chunkCount: number | null;
  errorMessage: string | null;
  uploadedAt: string;
  indexedAt: string | null;
  size?: string;
  progress?: number;
  statusLabel?: string;
  updatedAt?: string;
}

@Injectable({
  providedIn: 'root'
})
export class KnowledgeService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/api/v1/suppliers/me/knowledge`;

  uploadDocument(file: File): Observable<{ documentId: number; message: string }> {
    const formData = new FormData();
    formData.append('file', file);
    return this.http.post<{ documentId: number; message: string }>(`${this.apiUrl}/upload`, formData);
  }

  getDocuments(): Observable<KnowledgeDocument[]> {
    return this.http.get<KnowledgeDocument[]>(this.apiUrl);
  }

  deleteDocument(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  reindexDocument(id: number): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/${id}/reindex`, {});
  }
}
