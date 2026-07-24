import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterLink } from '@angular/router';

interface FooterLink {
  label: string;
  route: string | null;
}

interface FooterColumn {
  title: string;
  links: FooterLink[];
}

@Component({
  selector: 'app-site-footer',
  standalone: true,
  imports: [RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './site-footer.component.html',
  styleUrl: './site-footer.component.css',
})
export class SiteFooterComponent {
  readonly footerColumns: FooterColumn[] = [
    {
      title: 'المنتج',
      links: [
        { label: 'المميزات', route: null },
        { label: 'الأسعار', route: null },
        { label: 'الأمان', route: null },
      ],
    },
    {
      title: 'الموارد',
      links: [
        { label: 'وثائق API', route: null },
        { label: 'مركز المساعدة', route: null },
        { label: 'حالة الخدمة', route: null },
        { label: 'التحديثات', route: null },
      ],
    },
    {
      title: 'الشركة',
      links: [
        { label: 'من نحن', route: '/about' },
        { label: 'المدونة', route: null },
        { label: 'شركاء', route: null },
        { label: 'تواصل معنا', route: '/contact' },
      ],
    },
    {
      title: 'القانوني',
      links: [
        { label: 'سياسة الخصوصية', route: null },
        { label: 'شروط الاستخدام', route: null },
      ],
    },
  ];

  readonly socialLinks = ['Twitter / X', 'LinkedIn', 'GitHub'];
}
