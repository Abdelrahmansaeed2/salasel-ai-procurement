import { ChangeDetectionStrategy, Component, signal, viewChild, ElementRef } from '@angular/core';
import { PaginationComponent } from '../ui/pagination.component';

type AssetStatus = 'archived' | 'processing' | 'uploading' | 'failed';

interface KnowledgeAsset {
  id: string;
  name: string;
  size: string;
  type: 'PDF' | 'XLSX' | 'CSV';
  status: AssetStatus;
  statusLabel: string;
  updatedAt: string;
  progress?: number;
  error?: string;
}

@Component({
  selector: 'app-portal-knowledge-base',
  standalone: true,
  imports: [PaginationComponent],
  templateUrl: './portal-knowledge-base.component.html',
  styleUrl: './portal-knowledge-base.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalKnowledgeBaseComponent {
  private readonly fileInput = viewChild<ElementRef<HTMLInputElement>>('fileInput');

  readonly isDraggingOver = signal(false);
  readonly showSuggestion = signal(true);

  readonly assets = signal<KnowledgeAsset[]>([
    { id: '1', name: 'Q4_Logistics_Strategy.pdf', size: '2.4 ميجابايت', type: 'PDF', status: 'archived', statusLabel: 'مؤرشف', updatedAt: '12 أكتوبر 2023 · 14:20' },
    { id: '2', name: 'Supplier_Master_List_2024.xlsx', size: '12.1 ميجابايت', type: 'XLSX', status: 'processing', statusLabel: 'جاري المعالجة', updatedAt: 'قيد الانتظار...' },
    { id: '3', name: 'Customs_Regulations_Europe.pdf', size: '4.8 ميجابايت', type: 'PDF', status: 'uploading', statusLabel: 'جاري الرفع', updatedAt: '--', progress: 65 },
    { id: '4', name: 'Corrupted_Inventory_File.csv', size: '', type: 'CSV', status: 'failed', statusLabel: 'فشلت', updatedAt: '--', error: 'خطأ في حجم الملف' },
  ]);

  readonly stats = {
    failed: 2,
    vectors: '1.2M',
    archived: 112,
    total: 128,
  };

  readonly page = signal(1);
  readonly totalPages = 13;

  onDragOver(event: DragEvent) {
    event.preventDefault();
    this.isDraggingOver.set(true);
  }

  onDragLeave() {
    this.isDraggingOver.set(false);
  }

  onDrop(event: DragEvent) {
    event.preventDefault();
    this.isDraggingOver.set(false);
    const files = event.dataTransfer?.files;
    if (files?.length) this.ingestFiles(files);
  }

  browseFiles() {
    this.fileInput()?.nativeElement.click();
  }

  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files?.length) this.ingestFiles(input.files);
    input.value = '';
  }

  private ingestFiles(files: FileList) {
    const newAssets: KnowledgeAsset[] = Array.from(files).map((file, index) => ({
      id: `new-${Date.now()}-${index}`,
      name: file.name,
      size: `${(file.size / (1024 * 1024)).toFixed(1)} ميجابايت`,
      type: file.name.toLowerCase().endsWith('.csv') ? 'CSV' : file.name.toLowerCase().endsWith('.xlsx') ? 'XLSX' : 'PDF',
      status: 'uploading',
      statusLabel: 'جاري الرفع',
      updatedAt: 'الآن',
      progress: 0,
    }));
    this.assets.update((list) => [...newAssets, ...list]);
    newAssets.forEach((asset) => this.simulateUpload(asset.id));
  }

  private simulateUpload(assetId: string) {
    const interval = setInterval(() => {
      this.assets.update((list) =>
        list.map((a) => {
          if (a.id !== assetId) return a;
          const nextProgress = Math.min(100, (a.progress ?? 0) + 20);
          if (nextProgress >= 100) {
            clearInterval(interval);
            return { ...a, progress: 100, status: 'archived', statusLabel: 'مؤرشف', updatedAt: 'الآن' };
          }
          return { ...a, progress: nextProgress };
        }),
      );
    }, 400);
  }

  retry(assetId: string) {
    this.assets.update((list) =>
      list.map((a) => (a.id === assetId ? { ...a, status: 'uploading', statusLabel: 'جاري الرفع', progress: 0, error: undefined } : a)),
    );
    this.simulateUpload(assetId);
  }

  remove(assetId: string) {
    this.assets.update((list) => list.filter((a) => a.id !== assetId));
  }

  dismissSuggestion() {
    this.showSuggestion.set(false);
  }

  goToPage(page: number) {
    this.page.set(page);
  }
}
