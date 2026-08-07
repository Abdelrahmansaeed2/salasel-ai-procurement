import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-portal-settings',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="settings-container">
      <h2>الإعدادات</h2>
      <p>جاري تطوير صفحة الإعدادات. قريباً ستتمكن من تعديل تفاصيل حسابك هنا.</p>
    </div>
  `,
  styles: [`
    .settings-container {
      padding: 2rem;
      background: #ffffff;
      border-radius: 12px;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      margin: 1.5rem;
    }
    h2 {
      color: #1e293b;
      font-size: 1.5rem;
      font-weight: 700;
      margin-bottom: 1rem;
      font-family: 'Cairo', sans-serif;
    }
    p {
      color: #64748b;
      font-size: 1rem;
      font-family: 'Cairo', sans-serif;
    }
  `]
})
export class PortalSettingsComponent {}
