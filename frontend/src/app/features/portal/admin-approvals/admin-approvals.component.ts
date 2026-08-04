import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

interface MerchantApproval {
  id: string;
  name: string;
  crNumber: string;
  location: string;
  category: string;
  submittedAt: Date;
  status: 'Pending' | 'Approved' | 'Rejected';
}

@Component({
  selector: 'app-admin-approvals',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './admin-approvals.component.html',
  styleUrl: './admin-approvals.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AdminApprovalsComponent {
  // Mock Data for UI/UX Review
  readonly pendingMerchants = signal<MerchantApproval[]>([
    {
      id: 'MER-1002',
      name: 'أسواق التميمي',
      crNumber: '1010998877',
      location: 'الرياض، السعودية',
      category: 'سوبر ماركت',
      submittedAt: new Date(Date.now() - 3600000 * 2), // 2 hours ago
      status: 'Pending',
    },
    {
      id: 'MER-1005',
      name: 'بقالة ركن الياسمين',
      crNumber: '2050112233',
      location: 'جدة، السعودية',
      category: 'تموينات',
      submittedAt: new Date(Date.now() - 3600000 * 5),
      status: 'Pending',
    },
  ]);

  readonly selectedMerchant = signal<MerchantApproval | null>(null);
  readonly isDrawerOpen = signal(false);

  openReviewDrawer(merchant: MerchantApproval) {
    this.selectedMerchant.set(merchant);
    this.isDrawerOpen.set(true);
  }

  closeDrawer() {
    this.isDrawerOpen.set(false);
    setTimeout(() => this.selectedMerchant.set(null), 300); // Wait for transition
  }

  approveMerchant(id: string) {
    this.pendingMerchants.update((merchants) =>
      merchants.filter((m) => m.id !== id)
    );
    this.closeDrawer();
  }

  rejectMerchant(id: string) {
    this.pendingMerchants.update((merchants) =>
      merchants.filter((m) => m.id !== id)
    );
    this.closeDrawer();
  }
}
