import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SiteHeaderComponent } from '../../shared/site-header/site-header.component';
import { SiteFooterComponent } from '../../shared/site-footer/site-footer.component';

@Component({
  selector: 'app-terms-privacy',
  standalone: true,
  imports: [CommonModule, SiteHeaderComponent, SiteFooterComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './terms-privacy.component.html',
  styleUrl: './terms-privacy.component.css',
})
export class TermsPrivacyComponent {
  readonly activeTab = signal<'terms' | 'privacy'>('terms');

  setTab(tab: 'terms' | 'privacy'): void {
    this.activeTab.set(tab);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  printPolicy(): void {
    window.print();
  }
}
