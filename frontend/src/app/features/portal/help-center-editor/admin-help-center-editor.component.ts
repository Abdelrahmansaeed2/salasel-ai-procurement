import { ChangeDetectionStrategy, Component, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../../core/services/admin.service';

@Component({
  selector: 'app-admin-help-center-editor',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin-help-center-editor.component.html',
  styleUrls: ['./admin-help-center-editor.component.css'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AdminHelpCenterEditorComponent {
  private readonly adminService = inject(AdminService);

  articleTitle = signal('');
  articleContent = signal('');
  isSaving = signal(false);

  saveArticle() {
    if (!this.articleTitle().trim() || !this.articleContent().trim()) return;
    
    this.isSaving.set(true);

    this.adminService.createKnowledgeBaseArticle({
      title: this.articleTitle(),
      content: this.articleContent(),
      category: 'General'
    }).subscribe({
      next: () => {
        this.isSaving.set(false);
        this.articleTitle.set('');
        this.articleContent.set('');
        window.alert('تم حفظ المقال بنجاح ونشره في مركز المساعدة.');
      },
      error: (err) => {
        this.isSaving.set(false);
        console.error('Failed to save article', err);
        window.alert('فشل حفظ المقال. يرجى المحاولة مرة أخرى.');
      }
    });
  }
}
