import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { AdminSettingsService, SystemConfigurationDto } from '../../../core/services/admin-settings.service';

@Component({
  selector: 'app-admin-settings',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="admin-settings-container">
      <div class="header">
        <h2>Global Platform Settings</h2>
        <p>Manage AI routing thresholds, platform fees, and other core parameters.</p>
      </div>

      <div class="settings-content" *ngIf="settingsForm">
        <form [formGroup]="settingsForm" (ngSubmit)="saveSettings()" class="settings-form">
          
          <div class="setting-group">
            <div class="setting-info">
              <h3>Platform Commission Fee (%)</h3>
              <p>The percentage fee deducted from each sub-order payout via Stripe.</p>
            </div>
            <div class="setting-input">
              <input type="number" formControlName="PlatformFeePercentage" class="form-control" step="0.1">
            </div>
          </div>

          <div class="setting-group">
            <div class="setting-info">
              <h3>AI Threshold: Max Suppliers per Order</h3>
              <p>Maximum number of suppliers the AI will split an order among.</p>
            </div>
            <div class="setting-input">
              <input type="number" formControlName="AiMaxSuppliers" class="form-control">
            </div>
          </div>

          <div class="setting-group">
            <div class="setting-info">
              <h3>Supplier Lead Time Penalty (Score)</h3>
              <p>How much a supplier's routing score is penalized per day of lead time.</p>
            </div>
            <div class="setting-input">
              <input type="number" formControlName="LeadTimePenalty" class="form-control" step="0.1">
            </div>
          </div>

          <div class="form-actions">
            <button type="submit" [disabled]="settingsForm.invalid || isSaving" class="btn-primary">
              {{ isSaving ? 'Saving...' : 'Save Settings' }}
            </button>
            <div *ngIf="successMessage" class="success-msg">{{ successMessage }}</div>
          </div>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .admin-settings-container {
      padding: 2rem;
      background: #ffffff;
      border-radius: 12px;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      margin: 1.5rem;
      font-family: 'Inter', sans-serif;
    }
    .header {
      margin-bottom: 2.5rem;
      border-bottom: 1px solid #e2e8f0;
      padding-bottom: 1.5rem;
    }
    .header h2 {
      font-size: 1.5rem;
      font-weight: 700;
      color: #0f172a;
      margin: 0 0 0.5rem 0;
    }
    .header p {
      color: #64748b;
      margin: 0;
    }
    .setting-group {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1.5rem 0;
      border-bottom: 1px solid #f1f5f9;
    }
    .setting-info h3 {
      font-size: 1.05rem;
      font-weight: 600;
      color: #334155;
      margin: 0 0 0.25rem 0;
    }
    .setting-info p {
      margin: 0;
      color: #64748b;
      font-size: 0.9rem;
    }
    .setting-input input {
      width: 120px;
      padding: 0.75rem 1rem;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      font-size: 1rem;
      color: #1e293b;
      outline: none;
      text-align: center;
      transition: border-color 0.2s;
    }
    .setting-input input:focus {
      border-color: #2563eb;
      box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
    }
    .form-actions {
      display: flex;
      align-items: center;
      gap: 1.5rem;
      margin-top: 2.5rem;
    }
    .btn-primary {
      background: #0f172a;
      color: white;
      border: none;
      padding: 0.75rem 2rem;
      border-radius: 6px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
    .btn-primary:hover:not([disabled]) {
      background: #1e293b;
    }
    .btn-primary[disabled] {
      opacity: 0.7;
      cursor: not-allowed;
    }
    .success-msg {
      color: #16a34a;
      font-weight: 500;
    }
  `]
})
export class AdminSettingsComponent implements OnInit {
  private settingsService = inject(AdminSettingsService);
  private fb = inject(FormBuilder);

  settingsForm!: FormGroup;
  isSaving = false;
  successMessage = '';
  
  // Default values mapped to keys
  defaults: Record<string, string> = {
    'PlatformFeePercentage': '5.0',
    'AiMaxSuppliers': '3',
    'LeadTimePenalty': '2.0'
  };

  ngOnInit() {
    this.loadSettings();
  }

  loadSettings() {
    this.settingsService.getSettings().subscribe({
      next: (data) => {
        const settingsMap: Record<string, string> = { ...this.defaults };
        data.forEach(s => settingsMap[s.key] = s.value);
        
        this.settingsForm = this.fb.group({
          PlatformFeePercentage: [settingsMap['PlatformFeePercentage'], Validators.required],
          AiMaxSuppliers: [settingsMap['AiMaxSuppliers'], Validators.required],
          LeadTimePenalty: [settingsMap['LeadTimePenalty'], Validators.required],
        });
      },
      error: (err) => {
        console.error('Failed to load settings', err);
        // Fallback to defaults if api fails
        this.settingsForm = this.fb.group({
          PlatformFeePercentage: [this.defaults['PlatformFeePercentage'], Validators.required],
          AiMaxSuppliers: [this.defaults['AiMaxSuppliers'], Validators.required],
          LeadTimePenalty: [this.defaults['LeadTimePenalty'], Validators.required],
        });
      }
    });
  }

  saveSettings() {
    if (this.settingsForm.invalid) return;
    this.isSaving = true;
    this.successMessage = '';

    const updates = Object.keys(this.settingsForm.value).map(key => {
      return this.settingsService.updateSetting(key, { value: this.settingsForm.value[key].toString() }).toPromise();
    });

    Promise.all(updates).then(() => {
      this.isSaving = false;
      this.successMessage = 'Global settings saved successfully.';
      setTimeout(() => this.successMessage = '', 3000);
    }).catch(err => {
      console.error('Failed to save settings', err);
      this.isSaving = false;
    });
  }
}
