import { ChangeDetectionStrategy, Component, signal, viewChild, ElementRef, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PaginationComponent } from '../ui/pagination.component';
import { KnowledgeService, KnowledgeDocument } from '../../../core/services/knowledge.service';

@Component({
  selector: 'app-portal-knowledge-base',
  standalone: true,
  imports: [CommonModule, PaginationComponent],
  templateUrl: './portal-knowledge-base.component.html',
  styleUrl: './portal-knowledge-base.component.css',
})
export class PortalKnowledgeBaseComponent implements OnInit {
  private knowledgeService = inject(KnowledgeService);
  private readonly fileInput = viewChild<ElementRef<HTMLInputElement>>('fileInput');

  readonly isDraggingOver = signal(false);
  readonly showSuggestion = signal(true);

  readonly assets = signal<KnowledgeDocument[]>([]);

  readonly stats = {
    failed: 2,
    vectors: '1.2M',
    archived: 112,
    total: 128,
  };

  readonly page = signal(1);
  readonly totalPages = 13;

  ngOnInit() {
    this.loadDocuments();
  }

  loadDocuments() {
    this.knowledgeService.getDocuments().subscribe({
      next: (docs) => {
        this.assets.set(docs);
      },
      error: (err) => console.error('Failed to load documents', err)
    });
  }

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
    Array.from(files).forEach(file => {
      this.knowledgeService.uploadDocument(file).subscribe({
        next: () => {
          this.loadDocuments();
        },
        error: (err) => console.error('Failed to upload document', err)
      });
    });
  }

  retry(assetId: number) {
    this.knowledgeService.reindexDocument(assetId).subscribe({
      next: () => this.loadDocuments(),
      error: (err) => console.error('Failed to reindex', err)
    });
  }

  remove(assetId: number) {
    this.knowledgeService.deleteDocument(assetId).subscribe({
      next: () => {
        this.assets.update(list => list.filter(a => a.id !== assetId));
      },
      error: (err) => console.error('Failed to delete', err)
    });
  }

  dismissSuggestion() {
    this.showSuggestion.set(false);
  }

  goToPage(page: number) {
    this.page.set(page);
  }
}

