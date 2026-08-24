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
        { label: 'المميزات', route: '/features-ai' },
        { label: 'دليل الموردين', route: '/suppliers' },
      ],
    },
    {
      title: 'الموارد',
      links: [
        { label: 'مركز المساعدة', route: '/help-center' },
        { label: 'وثائق التوثيق', route: '/help-center' },
        { label: 'الاستفسارات الشائعة', route: '/help-center' },
      ],
    },
    {
      title: 'الشركة',
      links: [
        { label: 'من نحن', route: '/about' },
        { label: 'تواصل معنا', route: '/contact' },
        { label: 'تسجيل الموردين', route: '/supplier-registration' },
      ],
    },
    {
      title: 'القانوني',
      links: [
        { label: 'سياسة الخصوصية', route: '/privacy' },
        { label: 'شروط الاستخدام', route: '/terms' },
      ],
    },
  ];

  readonly socialLinks = [
    { name: 'Facebook', url: 'https://www.facebook.com/people/Salasel/61593526056230/' }
  ];
}
