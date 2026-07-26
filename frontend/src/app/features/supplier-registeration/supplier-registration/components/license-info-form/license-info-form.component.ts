import { ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface UploadedFile {
  id: string;
  name: string;
  size: string;
  progress: number;
  status: 'uploading' | 'completed' | 'failed';
}

@Component({
  selector: 'app-license-info-form',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './license-info-form.component.html',
  styleUrl: './license-info-form.component.css',
})
export class LicenseInfoFormComponent implements OnInit, OnDestroy {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  // Seeded list to match Figma mockup precisely:
  // - Commercial_License_2024.pdf showing 45% progress
  // - CR_Back_View.jpg successfully completed (2.4 MB)
  uploadedFiles = signal<UploadedFile[]>([
    {
      id: 'figma-uploading',
      name: 'Commercial_License_2024.pdf',
      size: '1.8 MB',
      progress: 45,
      status: 'uploading',
    },
    {
      id: 'figma-success',
      name: 'CR_Back_View.jpg',
      size: '2.4 MB',
      progress: 100,
      status: 'completed',
    }
  ]);

  isDragOver = signal<boolean>(false);
  private progressIntervals: { [key: string]: any } = {};

  ngOnInit(): void {
    // Start simulation for any pre-seeded uploading files
    this.uploadedFiles().forEach(file => {
      if (file.status === 'uploading') {
        this.simulateUpload(file.id);
      }
    });
  }

  ngOnDestroy(): void {
    // Clear all running intervals to prevent memory leaks
    Object.values(this.progressIntervals).forEach(interval => clearInterval(interval));
  }

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
      this.handleFileList(event.dataTransfer.files);
    }
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      this.handleFileList(input.files);
    }
  }

  deleteFile(id: string): void {
    if (this.progressIntervals[id]) {
      clearInterval(this.progressIntervals[id]);
      delete this.progressIntervals[id];
    }
    this.uploadedFiles.update(files => files.filter(f => f.id !== id));
  }

  onSubmit(): void {
    // Proceed if there is at least one completed file
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

  private handleFileList(files: FileList): void {
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const id = 'file-' + Date.now() + '-' + i;
      const formattedSize = this.formatBytes(file.size);

      const newFile: UploadedFile = {
        id,
        name: file.name,
        size: formattedSize,
        progress: 0,
        status: 'uploading'
      };

      this.uploadedFiles.update(current => [...current, newFile]);
      this.simulateUpload(id);
    }
  }

  private simulateUpload(id: string): void {
    if (this.progressIntervals[id]) return;

    this.progressIntervals[id] = setInterval(() => {
      this.uploadedFiles.update(files => {
        return files.map(file => {
          if (file.id === id) {
            const nextProgress = file.progress + Math.floor(Math.random() * 15) + 5;
            if (nextProgress >= 100) {
              clearInterval(this.progressIntervals[id]);
              delete this.progressIntervals[id];
              return { ...file, progress: 100, status: 'completed' };
            }
            return { ...file, progress: nextProgress };
          }
          return file;
        });
      });
    }, 700);
  }

  private formatBytes(bytes: number, decimals = 1): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    const sizeVal = parseFloat((bytes / Math.pow(k, i)).toFixed(dm));
    
    // Format label for Arabic localization
    const sizeName = sizes[i] === 'MB' ? 'ميجابايت' : (sizes[i] === 'KB' ? 'كيلوبايت' : sizes[i]);
    return `${sizeVal} ${sizeName}`;
  }
}
