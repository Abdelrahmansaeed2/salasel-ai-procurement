import { ChangeDetectionStrategy, Component, Input } from '@angular/core';

@Component({
  selector: 'app-dashboard-topbar',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './dashboard-topbar.component.html',
  styleUrl: './dashboard-topbar.component.css',
})
export class DashboardTopbarComponent {
  @Input() userName = 'مورد سلاسل';
  @Input() userRole = 'صلاحيات المسؤول';
  @Input() avatarUrl = 'assets/images/avatar-supplier-admin.png';
  @Input() hasUnreadNotifications = true;
}
