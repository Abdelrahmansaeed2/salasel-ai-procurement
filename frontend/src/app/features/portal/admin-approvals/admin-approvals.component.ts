import { ChangeDetectionStrategy, Component, signal, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminService, PendingMerchant } from '../../../core/services/admin.service';
import { take } from 'rxjs';

@Component({
  selector: 'app-admin-approvals',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './admin-approvals.component.html',
  styleUrl: './admin-approvals.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AdminApprovalsComponent implements OnInit {
  private readonly adminService = inject(AdminService);

  readonly pendingMerchants = signal<PendingMerchant[]>([]);
  readonly selectedMerchant = signal<PendingMerchant | null>(null);
  readonly isDrawerOpen = signal(false);

  ngOnInit() {
    this.loadMerchants();
  }

  loadMerchants() {
    this.adminService.getPendingMerchants().pipe(take(1)).subscribe((merchants) => {
      this.pendingMerchants.set(merchants);
    });
  }

  openReviewDrawer(merchant: PendingMerchant) {
    this.selectedMerchant.set(merchant);
    this.isDrawerOpen.set(true);
  }

  closeDrawer() {
    this.isDrawerOpen.set(false);
    setTimeout(() => this.selectedMerchant.set(null), 300); // Wait for transition
  }

  approveMerchant(id: number) {
    this.adminService.approveMerchant(id).subscribe({
      next: () => {
        this.pendingMerchants.update((merchants) => merchants.filter((m) => m.merchantID !== id));
        this.closeDrawer();
      },
      error: (err) => console.error('Failed to approve merchant', err)
    });
  }

  rejectMerchant(id: number) {
    // Backend doesn't have an explicit reject yet, but we can simulate removing it from UI
    this.pendingMerchants.update((merchants) => merchants.filter((m) => m.merchantID !== id));
    this.closeDrawer();
  }
}

