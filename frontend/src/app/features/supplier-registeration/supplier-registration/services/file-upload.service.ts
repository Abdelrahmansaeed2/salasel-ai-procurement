import { Injectable } from '@angular/core';

export interface UploadFileItem {
  id: string;
  name: string;
  size: string;
  progress: number;
  status: 'uploading' | 'completed';
}

@Injectable({
  providedIn: 'root'
})
export class FileUploadService {
  formatBytes(bytes: number, decimals: number = 1): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  }

  processFiles(
    files: FileList | File[],
    onProgress: (fileItem: UploadFileItem) => void,
    onComplete: (fileItem: UploadFileItem) => void
  ): UploadFileItem[] {
    const fileArray = Array.from(files);
    const newItems: UploadFileItem[] = [];

    fileArray.forEach((file) => {
      const fileId = Math.random().toString(36).substring(2, 9);
      const item: UploadFileItem = {
        id: fileId,
        name: file.name,
        size: this.formatBytes(file.size),
        progress: 0,
        status: 'uploading'
      };

      newItems.push(item);
      this.simulateProgress(item, onProgress, onComplete);
    });

    return newItems;
  }

  private simulateProgress(
    item: UploadFileItem,
    onProgress: (fileItem: UploadFileItem) => void,
    onComplete: (fileItem: UploadFileItem) => void
  ): void {
    const interval = setInterval(() => {
      item.progress += Math.floor(Math.random() * 25) + 15;
      if (item.progress >= 100) {
        item.progress = 100;
        item.status = 'completed';
        clearInterval(interval);
        onComplete(item);
      } else {
        onProgress(item);
      }
    }, 250);
  }
}
