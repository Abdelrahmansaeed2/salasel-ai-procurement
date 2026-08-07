import { Routes } from '@angular/router';
import { LandingPageComponent } from './features/landing-page/landing-page.component';
import { AboutPageComponent } from './features/about-page/about-page.component';
import { ContactPageComponent } from './features/contact-page/contact-page.component';
import { FeaturesAiComponent } from './features/features-ai/features-ai.component';
import { SupplierLoginComponent } from './features/supplier-auth/supplier-login.component';
import { SupplierDirectoryComponent } from './features/supplier-directory/supplier-directory.component';
import { SupplierDetailsComponent } from './features/supplier-details/supplier-details.component';
import { SupplierRegistration } from './features/supplier-registeration/supplier-registration/supplier-registration';
import { SupplierDashboardComponent } from './features/supplier-dashboard/supplier-dashboard.component';
import { HelpCenterComponent } from './features/help-center/help-center.component';
import { TermsPrivacyComponent } from './features/terms-privacy/terms-privacy.component';
import { ForgotPasswordEmailComponent } from './features/forgot-password/forgot-password-email/forgot-password-email.component';
import { ForgotPasswordSentComponent } from './features/forgot-password/forgot-password-sent/forgot-password-sent.component';
import { ForgotPasswordResetComponent } from './features/forgot-password/forgot-password-reset/forgot-password-reset.component';
import { ForgotPasswordSuccessComponent } from './features/forgot-password/forgot-password-success/forgot-password-success.component';
import { authGuard } from './core/auth/auth.guard';

import { roleGuard } from './core/auth/role.guard';

export const routes: Routes = [
  { path: '', component: LandingPageComponent },
  { path: 'about', component: AboutPageComponent },
  { path: 'contact', component: ContactPageComponent },
  { path: 'features-ai', component: FeaturesAiComponent },
  { path: 'supplier-login', component: SupplierLoginComponent },
  { path: 'forgot-password', component: ForgotPasswordEmailComponent },
  { path: 'forgot-password/sent', component: ForgotPasswordSentComponent },
  { path: 'forgot-password/reset', component: ForgotPasswordResetComponent },
  { path: 'forgot-password/success', component: ForgotPasswordSuccessComponent },
  { path: 'supplier-registration', component: SupplierRegistration },
  { path: 'suppliers', component: SupplierDirectoryComponent },
  { path: 'suppliers/:id', component: SupplierDetailsComponent },
  { path: 'dashboard', component: SupplierDashboardComponent },
  { path: 'supplier-dashboard', component: SupplierDashboardComponent },
  { path: 'help-center', component: HelpCenterComponent },
  { path: 'terms', component: TermsPrivacyComponent },
  { path: 'privacy', component: TermsPrivacyComponent },
  {
    path: 'portal',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./features/portal/layout/portal-layout.component').then((m) => m.PortalLayoutComponent),
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/portal/dashboard/portal-dashboard.component').then((m) => m.PortalDashboardComponent),
      },
      {
        path: 'analytics',
        canActivate: [roleGuard],
        data: { roles: ['Admin'] },
        loadComponent: () =>
          import('./features/portal/analytics/portal-analytics.component').then((m) => m.PortalAnalyticsComponent),
      },
      {
        path: 'orders',
        loadComponent: () =>
          import('./features/portal/orders/portal-orders.component').then((m) => m.PortalOrdersComponent),
      },
      {
        path: 'catalog',
        loadComponent: () =>
          import('./features/portal/catalog/portal-catalog.component').then((m) => m.PortalCatalogComponent),
      },
      {
        path: 'supplier-knowledge',
        loadComponent: () =>
          import('./features/portal/knowledge-base/portal-knowledge-base.component').then(
            (m) => m.PortalKnowledgeBaseComponent,
          ),
      },
      {
        path: 'approvals',
        canActivate: [roleGuard],
        data: { roles: ['Admin'] },
        loadComponent: () =>
          import('./features/portal/admin-approvals/admin-approvals.component').then((m) => m.AdminApprovalsComponent),
      },
      {
        path: 'roles',
        canActivate: [roleGuard],
        data: { roles: ['Admin'] },
        loadComponent: () =>
          import('./features/portal/roles/portal-roles.component').then((m) => m.PortalRolesComponent),
      },
      {
        path: 'help-center-editor',
        canActivate: [roleGuard],
        data: { roles: ['Admin'] },
        loadComponent: () =>
          import('./features/portal/help-center-editor/admin-help-center-editor.component').then(
            (m) => m.AdminHelpCenterEditorComponent,
          ),
      },
      {
        path: 'settings',
        loadComponent: () =>
          import('./features/portal/settings/portal-settings.component').then(
            (m) => m.PortalSettingsComponent,
          ),
      },
      { path: '**', redirectTo: 'dashboard' },
    ],
  },
];
