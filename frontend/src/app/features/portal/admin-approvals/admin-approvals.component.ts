import { ChangeDetectionStrategy, Component, signal, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminService, PendingMerchant, PendingSupplier } from '../../../core/services/admin.service';
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

  readonly activeTab = signal<'merchants' | 'suppliers'>('merchants');

  readonly pendingMerchants = signal<PendingMerchant[]>([]);
  readonly selectedMerchant = signal<PendingMerchant | null>(null);

  readonly pendingSuppliers = signal<PendingSupplier[]>([]);
  readonly selectedSupplier = signal<PendingSupplier | null>(null);

  readonly isDrawerOpen = signal(false);

  ngOnInit() {
    this.loadMerchants();
    this.loadSuppliers();
  }

  loadMerchants() {
    this.adminService.getPendingMerchants().pipe(take(1)).subscribe({
      next: (merchants) => {
        console.log('Loaded merchants:', merchants);
        this.pendingMerchants.set(merchants);
      },
      error: (err) => console.error('Error loading merchants:', err)
    });
  }

  loadSuppliers() {
    this.adminService.getPendingSuppliers().pipe(take(1)).subscribe({
      next: (suppliers) => {
        console.log('Loaded suppliers:', suppliers);
        this.pendingSuppliers.set(suppliers);
      },
      error: (err) => console.error('Error loading suppliers:', err)
    });
  }

  setTab(tab: 'merchants' | 'suppliers') {
    this.activeTab.set(tab);
    this.closeDrawer();
  }

  openReviewDrawer(merchant?: PendingMerchant, supplier?: PendingSupplier) {
    if (merchant) {
      this.selectedMerchant.set(merchant);
      this.selectedSupplier.set(null);
    } else if (supplier) {
      this.selectedSupplier.set(supplier);
      this.selectedMerchant.set(null);
    }
    this.isDrawerOpen.set(true);
  }

  closeDrawer() {
    this.isDrawerOpen.set(false);
    setTimeout(() => {
      this.selectedMerchant.set(null);
      this.selectedSupplier.set(null);
    }, 300);
  }

  approveItem() {
    const merchant = this.selectedMerchant();
    const supplier = this.selectedSupplier();

    if (merchant) {
      this.adminService.approveMerchant(merchant.merchantID).subscribe({
        next: () => {
          this.pendingMerchants.update((items) => items.filter((m) => m.merchantID !== merchant.merchantID));
          this.closeDrawer();
        },
        error: (err) => console.error('Failed to approve merchant', err)
      });
    } else if (supplier) {
      this.adminService.approveSupplier(supplier.supplierID).subscribe({
        next: () => {
          this.pendingSuppliers.update((items) => items.filter((s) => s.supplierID !== supplier.supplierID));
          this.closeDrawer();
        },
        error: (err) => console.error('Failed to approve supplier', err)
      });
    }
  }

  rejectItem() {
    const merchant = this.selectedMerchant();
    const supplier = this.selectedSupplier();

    const reason = window.prompt("الرجاء إدخال سبب الرفض:");
    if (reason === null || reason.trim() === '') {
      return; // User cancelled or left it empty
    }

    if (merchant) {
      this.adminService.rejectMerchant(merchant.merchantID, reason).subscribe({
        next: () => {
          this.pendingMerchants.update((items) => items.filter((m) => m.merchantID !== merchant.merchantID));
          this.closeDrawer();
        },
        error: (err) => console.error('Failed to reject merchant', err)
      });
    } else if (supplier) {
      this.adminService.rejectSupplier(supplier.supplierID, reason).subscribe({
        next: () => {
          this.pendingSuppliers.update((items) => items.filter((s) => s.supplierID !== supplier.supplierID));
          this.closeDrawer();
        },
        error: (err) => console.error('Failed to reject supplier', err)
      });
    }
  }
}

