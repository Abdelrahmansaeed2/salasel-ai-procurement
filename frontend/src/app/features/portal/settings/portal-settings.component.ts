import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SupplierService, SupplierProfileDto } from '../../../core/services/supplier.service';

@Component({
  selector: 'app-portal-settings',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="settings-container" *ngIf="profile" dir="rtl">
      <div class="settings-header">
        <h2>إعدادات المورد</h2>
        <p>إدارة الملف الشخصي لعملك، تفضيلات الخدمات اللوجستية، والمدفوعات.</p>
      </div>

      <div class="tabs">
        <button [class.active]="activeTab === 'profile'" (click)="activeTab = 'profile'">الملف الشخصي</button>
        <button [class.active]="activeTab === 'logistics'" (click)="activeTab = 'logistics'">الخدمات اللوجستية</button>
        <button [class.active]="activeTab === 'financials'" (click)="activeTab = 'financials'">المدفوعات (Stripe)</button>
      </div>

      <div class="tab-content">
        <!-- Profile Form -->
        <form *ngIf="activeTab === 'profile' || activeTab === 'logistics'" [formGroup]="settingsForm" (ngSubmit)="saveSettings()" class="settings-form">
          <div *ngIf="activeTab === 'profile'">
            <div class="form-row">
              <div class="form-group">
                <label>اسم الشركة</label>
                <input type="text" formControlName="companyName" class="form-control">
              </div>
              <div class="form-group">
                <label>نوع العمل</label>
                <input type="text" formControlName="businessType" class="form-control">
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>هاتف التواصل</label>
                <input type="text" formControlName="contactPhone" class="form-control">
              </div>
              <div class="form-group">
                <label>المسمى الوظيفي</label>
                <input type="text" formControlName="jobTitle" class="form-control">
              </div>
            </div>

            <div class="form-group">
              <label>العنوان</label>
              <textarea formControlName="address" class="form-control" rows="2"></textarea>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>رقم السجل التجاري</label>
                <input type="text" formControlName="crNumber" class="form-control">
              </div>
              <div class="form-group">
                <label>الرقم الضريبي</label>
                <input type="text" formControlName="taxNumber" class="form-control">
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>رقم ضريبة القيمة المضافة (VAT)</label>
                <input type="text" formControlName="vatNumber" class="form-control">
              </div>
              <div class="form-group checkbox-group">
                <label>
                  <input type="checkbox" formControlName="isVatExempt"> معفى من الضريبة
                </label>
              </div>
            </div>
          </div>

          <div *ngIf="activeTab === 'logistics'">
            <div class="form-row">
              <div class="form-group">
                <label>نطاق التغطية (كم) <small>يستخدم لمطابقة الذكاء الاصطناعي</small></label>
                <input type="number" formControlName="coverageRadiusKm" class="form-control">
              </div>
              <div class="form-group">
                <label>شروط الدفع <small>مثال: الدفع عند الاستلام، خلال 30 يوم</small></label>
                <input type="text" formControlName="paymentTerms" class="form-control">
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button type="submit" [disabled]="settingsForm.invalid || isSaving" class="btn-primary">
              {{ isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات' }}
            </button>
            <div *ngIf="successMessage" class="success-msg">{{ successMessage }}</div>
          </div>
        </form>

        <!-- Stripe Financials -->
        <div *ngIf="activeTab === 'financials'" class="stripe-section">
          <h3>المدفوعات عبر بوابة Stripe</h3>
          <p>نحن نستخدم Stripe لضمان استلامك لأموالك في الوقت المحدد وللحفاظ على أمان تفاصيل حسابك البنكي.</p>
          
          <div *ngIf="profile.isStripeOnboardingComplete" class="stripe-success">
            <div class="icon-circle">
              <i class="fas fa-check"></i>
            </div>
            <div>
              <h4>تم ربط الحساب بنجاح</h4>
              <p>حساب Stripe الخاص بك جاهز تمامًا لاستقبال المدفوعات.</p>
            </div>
          </div>

          <div *ngIf="!profile.isStripeOnboardingComplete" class="stripe-pending">
            <p>يجب عليك ربط حساب بنكي لتلقي المدفوعات من منصة Salasel AI Procurement.</p>
            <button (click)="connectStripe()" [disabled]="isConnectingStripe" class="btn-stripe">
              {{ isConnectingStripe ? 'جاري التحميل...' : 'ربط الحساب البنكي' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .settings-container {
      padding: 2rem;
      background: #ffffff;
      border-radius: 12px;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      margin: 1.5rem;
      font-family: 'Cairo', sans-serif;
    }
    .settings-header {
      margin-bottom: 2rem;
    }
    .settings-header h2 {
      font-size: 1.5rem;
      font-weight: 700;
      color: #0f172a;
      margin: 0 0 0.5rem 0;
    }
    .settings-header p {
      color: #64748b;
      margin: 0;
    }
    .tabs {
      display: flex;
      border-bottom: 1px solid #e2e8f0;
      margin-bottom: 2rem;
    }
    .tabs button {
      background: none;
      border: none;
      padding: 1rem 1.5rem;
      font-size: 1rem;
      color: #64748b;
      font-weight: 500;
      cursor: pointer;
      position: relative;
    }
    .tabs button.active {
      color: #2563eb;
    }
    .tabs button.active::after {
      content: '';
      position: absolute;
      bottom: -1px;
      left: 0;
      right: 0;
      height: 2px;
      background: #2563eb;
    }
    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1.5rem;
      margin-bottom: 1.5rem;
    }
    .form-group {
      display: flex;
      flex-direction: column;
      margin-bottom: 1.5rem;
    }
    .form-group label {
      font-weight: 500;
      color: #334155;
      margin-bottom: 0.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .form-group label small {
      font-weight: 400;
      color: #94a3b8;
    }
    .form-control {
      padding: 0.75rem 1rem;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      font-size: 0.95rem;
      color: #1e293b;
      outline: none;
      transition: border-color 0.2s;
    }
    .form-control:focus {
      border-color: #2563eb;
      box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
    }
    .checkbox-group label {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      cursor: pointer;
      justify-content: flex-start;
      margin-top: 2rem;
    }
    .form-actions {
      display: flex;
      align-items: center;
      gap: 1.5rem;
      margin-top: 2rem;
      padding-top: 1.5rem;
      border-top: 1px solid #e2e8f0;
    }
    .btn-primary {
      background: #2563eb;
      color: white;
      border: none;
      padding: 0.75rem 2rem;
      border-radius: 6px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
    .btn-primary:hover:not([disabled]) {
      background: #1d4ed8;
    }
    .btn-primary[disabled] {
      opacity: 0.7;
      cursor: not-allowed;
    }
    .success-msg {
      color: #16a34a;
      font-weight: 500;
    }
    .stripe-section {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 2rem;
    }
    .stripe-section h3 {
      margin-top: 0;
      color: #0f172a;
    }
    .stripe-section p {
      color: #475569;
    }
    .stripe-success {
      display: flex;
      align-items: center;
      gap: 1rem;
      background: #ecfdf5;
      padding: 1.5rem;
      border-radius: 8px;
      border: 1px solid #a7f3d0;
      margin-top: 1.5rem;
    }
    .icon-circle {
      width: 40px;
      height: 40px;
      background: #10b981;
      color: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.25rem;
    }
    .stripe-success h4 {
      margin: 0 0 0.25rem 0;
      color: #065f46;
    }
    .stripe-success p {
      margin: 0;
      color: #047857;
      font-size: 0.9rem;
    }
    .stripe-pending {
      margin-top: 1.5rem;
    }
    .btn-stripe {
      background: #635bff;
      color: white;
      border: none;
      padding: 0.75rem 1.5rem;
      border-radius: 6px;
      font-weight: 600;
      cursor: pointer;
      font-size: 1rem;
      transition: background 0.2s;
    }
    .btn-stripe:hover {
      background: #544ada;
    }
    .btn-stripe[disabled] {
      opacity: 0.7;
      cursor: not-allowed;
    }
  `]
})
export class PortalSettingsComponent implements OnInit {
  private supplierService = inject(SupplierService);
  private fb = inject(FormBuilder);

  profile!: SupplierProfileDto;
  activeTab: 'profile' | 'logistics' | 'financials' = 'profile';
  settingsForm!: FormGroup;
  
  isSaving = false;
  successMessage = '';
  isConnectingStripe = false;

  ngOnInit() {
    this.loadProfile();
  }

  loadProfile() {
    this.supplierService.getMe().subscribe({
      next: (data) => {
        this.profile = data;
        this.initForm();
      },
      error: (err) => {
        console.error('Failed to load profile', err);
      }
    });
  }

  initForm() {
    this.settingsForm = this.fb.group({
      companyName: [this.profile.companyName, Validators.required],
      businessType: [this.profile.businessType || ''],
      contactPhone: [this.profile.contactPhone, Validators.required],
      jobTitle: [this.profile.jobTitle || ''],
      address: [this.profile.address || ''],
      crNumber: [this.profile.crNumber || ''],
      taxNumber: [this.profile.taxNumber || ''],
      vatNumber: [this.profile.vatNumber || ''],
      isVatExempt: [this.profile.isVatExempt || false],
      coverageRadiusKm: [this.profile.coverageRadiusKm || 50],
      paymentTerms: [this.profile.paymentTerms || ''],
      bankName: [this.profile.bankName || ''],
      iban: [this.profile.iban || '']
    });
  }

  saveSettings() {
    if (this.settingsForm.invalid) return;

    this.isSaving = true;
    this.successMessage = '';

    const payload = this.settingsForm.value;

    this.supplierService.updateMe(payload).subscribe({
      next: (updatedProfile) => {
        this.profile = updatedProfile;
        this.isSaving = false;
        this.successMessage = 'Settings saved successfully.';
        setTimeout(() => this.successMessage = '', 3000);
      },
      error: (err) => {
        console.error('Failed to update settings', err);
        this.isSaving = false;
      }
    });
  }

  connectStripe() {
    this.isConnectingStripe = true;
    this.supplierService.createStripeAccountSession(this.profile.supplierID).subscribe({
      next: (response) => {
        // Stripe usually returns a URL for Connect Onboarding, let's assume clientSecret is actually the URL 
        // since our backend currently doesn't implement Stripe properly or might be returning it as clientSecret
        if (response.clientSecret && response.clientSecret.startsWith('http')) {
          window.location.href = response.clientSecret;
        } else {
          alert('Failed to obtain Stripe redirect URL. Please check backend configuration.');
          this.isConnectingStripe = false;
        }
      },
      error: (err) => {
        console.error('Stripe connect failed', err);
        alert('Could not start Stripe onboarding.');
        this.isConnectingStripe = false;
      }
    });
  }
}
