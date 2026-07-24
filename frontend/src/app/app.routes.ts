import { Routes } from '@angular/router';
import { LandingPageComponent } from './features/landing-page/landing-page.component';
import { AboutPageComponent } from './features/about-page/about-page.component';
import { ContactPageComponent } from './features/contact-page/contact-page.component';
import { FeaturesAiComponent } from './features/features-ai/features-ai.component';
import { SupplierLoginComponent } from './features/supplier-auth/supplier-login.component';
import { SupplierDirectoryComponent } from './features/supplier-directory/supplier-directory.component';
import { SupplierDetailsComponent } from './features/supplier-details/supplier-details.component';

export const routes: Routes = [
  { path: '', component: LandingPageComponent },
  { path: 'about', component: AboutPageComponent },
  { path: 'contact', component: ContactPageComponent },
  { path: 'features-ai', component: FeaturesAiComponent },
  { path: 'supplier-login', component: SupplierLoginComponent },
  { path: 'suppliers', component: SupplierDirectoryComponent },
  { path: 'suppliers/:id', component: SupplierDetailsComponent },
];
