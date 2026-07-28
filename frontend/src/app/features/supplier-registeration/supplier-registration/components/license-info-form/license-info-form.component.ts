import { ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StepHeaderComponent } from '../shared/step-header/step-header.component';
import { FormActionsComponent } from '../shared/form-actions/form-actions.component';
import { FileUploadService, UploadFileItem } from '../../services/file-upload.service';

@Component({
  selector: 'app-license-info-form',
  standalone: true,
  imports: [CommonModule, StepHeaderComponent, FormActionsComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './license-info-form.component.html',
  styleUrl: './license-info-form.component.css',
})
export class LicenseInfoFormComponent implements OnInit {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  uploadedFiles = signal<UploadFileItem[]>([
    {
      id: 'license-1',
      name: 'Commercial_License_2024.pdf',
      size: '1.8 MB',
      progress: 100,
      status: 'completed',
    }
  ]);

  isDragOver = signal<boolean>(false);

  constructor(private uploadService: FileUploadService) {}

  ngOnInit(): void {}

  onDragOver(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver.set(true);
  }

  onDragLeave(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver.set(false);
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragOver.set(false);

    if (event.dataTransfer?.files) {
      this.handleFiles(event.dataTransfer.files);
    }
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      this.handleFiles(input.files);
    }
  }

  private handleFiles(files: FileList): void {
    const newItems = this.uploadService.processFiles(
      files,
      (updatedItem) => {
        this.uploadedFiles.update(list => list.map(item => item.id === updatedItem.id ? { ...updatedItem } : item));
      },
      (completedItem) => {
        this.uploadedFiles.update(list => list.map(item => item.id === completedItem.id ? { ...completedItem } : item));
      }
    );

    this.uploadedFiles.update(list => [...list, ...newItems]);
  }

  deleteFile(id: string): void {
    this.uploadedFiles.update(files => files.filter(f => f.id !== id));
  }

  onSubmit(): void {
    const completedFiles = this.uploadedFiles().filter(f => f.status === 'completed');
    if (completedFiles.length === 0) {
      alert('يرجى رفع رخصة تجارية صالحة للمتابعة.');
      return;
    }
    this.next.emit({ files: completedFiles });
  }

  onBackClick(): void {
    this.back.emit();
  }
}
