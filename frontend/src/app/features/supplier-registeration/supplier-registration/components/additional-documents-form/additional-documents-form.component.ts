import { ChangeDetectionStrategy, Component, EventEmitter, OnDestroy, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface DocFile {
  name: string;
  size: string;
  progress: number;
  status: 'uploading' | 'completed' | 'failed';
}

interface DocumentFilesState {
  bankStatement: DocFile | null;
  articleOfAssociation: DocFile | null;
  managerId: DocFile | null;
}

interface DragOverState {
  bankStatement: boolean;
  articleOfAssociation: boolean;
  managerId: boolean;
}

type DocSlotKey = keyof DocumentFilesState;

@Component({
  selector: 'app-additional-documents-form',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './additional-documents-form.component.html',
  styleUrl: './additional-documents-form.component.css',
})
export class AdditionalDocumentsFormComponent implements OnDestroy {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  documentFiles = signal<DocumentFilesState>({
    bankStatement: null,
    articleOfAssociation: null,
    managerId: null
  });

  dragOverStates = signal<DragOverState>({
    bankStatement: false,
    articleOfAssociation: false,
    managerId: false
  });

  private uploadIntervals: Record<string, any> = {};

  ngOnDestroy(): void {
    Object.values(this.uploadIntervals).forEach(interval => clearInterval(interval));
  }

  onDragOver(event: DragEvent, key: DocSlotKey): void {
    event.preventDefault();
    event.stopPropagation();
    this.updateDragState(key, true);
  }

  onDragLeave(event: DragEvent, key: DocSlotKey): void {
    event.preventDefault();
    event.stopPropagation();
    this.updateDragState(key, false);
  }

  onDrop(event: DragEvent, key: DocSlotKey): void {
    event.preventDefault();
    event.stopPropagation();
    this.updateDragState(key, false);

    if (event.dataTransfer?.files && event.dataTransfer.files.length > 0) {
      this.uploadFile(event.dataTransfer.files[0], key);
    }
  }

  onFileSelected(event: Event, key: DocSlotKey): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.uploadFile(input.files[0], key);
    }
  }

  deleteFile(key: DocSlotKey): void {
    if (this.uploadIntervals[key]) {
      clearInterval(this.uploadIntervals[key]);
      delete this.uploadIntervals[key];
    }

    this.documentFiles.update(current => ({ ...current, [key]: null }));
  }

  onSubmit(): void {
    const current = this.documentFiles();
    const slots: DocSlotKey[] = ['bankStatement', 'articleOfAssociation', 'managerId'];
    const allComplete = slots.every(k => current[k]?.status === 'completed');

    if (!allComplete) {
      alert('يرجى رفع كافة الوثائق المطلوبة (كشف الحساب، عقد التأسيس، وهوية المدير) للمتابعة.');
      return;
    }

    this.next.emit(current);
  }

  onBackClick(): void {
    this.back.emit();
  }

  private updateDragState(key: DocSlotKey, isOver: boolean): void {
    this.dragOverStates.update(current => ({ ...current, [key]: isOver }));
  }

  private uploadFile(file: File, key: DocSlotKey): void {
    if (this.uploadIntervals[key]) {
      clearInterval(this.uploadIntervals[key]);
    }

    const formattedSize = this.formatBytes(file.size);
    const newDoc: DocFile = {
      name: file.name,
      size: formattedSize,
      progress: 0,
      status: 'uploading'
    };

    this.documentFiles.update(current => ({ ...current, [key]: newDoc }));
    this.simulateUpload(key);
  }

  private simulateUpload(key: DocSlotKey): void {
    this.uploadIntervals[key] = setInterval(() => {
      this.documentFiles.update(current => {
        const doc = current[key];
        if (!doc) return current;

        const nextProgress = doc.progress + Math.floor(Math.random() * 20) + 10;

        if (nextProgress >= 100) {
          clearInterval(this.uploadIntervals[key]);
          delete this.uploadIntervals[key];
          return { ...current, [key]: { ...doc, progress: 100, status: 'completed' as const } };
        }

        return { ...current, [key]: { ...doc, progress: nextProgress } };
      });
    }, 600);
  }

  private formatBytes(bytes: number, decimals = 1): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    const sizeVal = parseFloat((bytes / Math.pow(k, i)).toFixed(dm));

    const sizeName = sizes[i] === 'MB' ? 'ميجابايت' : (sizes[i] === 'KB' ? 'كيلوبايت' : sizes[i]);
    return `${sizeVal} ${sizeName}`;
  }
}
