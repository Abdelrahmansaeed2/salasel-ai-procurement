import { ChangeDetectionStrategy, Component, EventEmitter, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StepHeaderComponent } from '../shared/step-header/step-header.component';
import { FormActionsComponent } from '../shared/form-actions/form-actions.component';
import { FileUploadService, UploadFileItem } from '../../services/file-upload.service';

interface DocumentFilesState {
  bankStatement: UploadFileItem | null;
  articleOfAssociation: UploadFileItem | null;
  managerId: UploadFileItem | null;
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
  imports: [CommonModule, StepHeaderComponent, FormActionsComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './additional-documents-form.component.html',
  styleUrl: './additional-documents-form.component.css',
})
export class AdditionalDocumentsFormComponent {
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

  constructor(private uploadService: FileUploadService) {}

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
    this.documentFiles.update(current => ({ ...current, [key]: null }));
  }

  private uploadFile(file: File, key: DocSlotKey): void {
    if (file.size > 10 * 1024 * 1024) {
      alert('حجم الملف كبير جداً. الحد الأقصى هو 10 ميجابايت.');
      return;
    }

    const items = this.uploadService.processFiles(
      [file],
      (updated) => {
        this.documentFiles.update(current => ({ ...current, [key]: { ...updated } }));
      },
      (completed) => {
        this.documentFiles.update(current => ({ ...current, [key]: { ...completed } }));
      }
    );

    if (items.length > 0) {
      this.documentFiles.update(current => ({ ...current, [key]: items[0] }));
    }
  }

  private updateDragState(key: DocSlotKey, state: boolean): void {
    this.dragOverStates.update(current => ({ ...current, [key]: state }));
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
}
