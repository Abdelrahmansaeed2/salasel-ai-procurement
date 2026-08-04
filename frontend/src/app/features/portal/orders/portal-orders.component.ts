import { ChangeDetectionStrategy, Component, computed, signal } from '@angular/core';

type OrderPriority = 'review' | 'urgent' | 'scheduled';
type QuickFilter = 'premium' | 'low-confidence' | 'high-priority';
type ViewMode = 'feed' | 'board';
type BoardColumnKey = 'rejected' | 'shipped' | 'accepted' | 'pending';

interface OperationsOrder {
  id: string;
  merchant: string;
  priority: OrderPriority;
  priorityLabel: string;
  confidence: number;
  confidenceColor: string;
  warning?: string;
  aiNote?: string;
  items: { label: string; price: string }[];
  total: string;
  currency: string;
}

interface OrderDetailItem {
  name: string;
  qty: string;
  total: string;
}

interface OrderTimelineStep {
  label: string;
  time: string;
  done: boolean;
}

interface BoardCard {
  id: string;
  merchant: string;
  subtitle: string;
  avatarInitials?: string;
  badgeLabel?: string;
  badgeVariant?: 'success' | 'danger' | 'neutral';
  total: string;
  metaLeft: string;
  metaRight?: string;
}

interface BoardColumn {
  key: BoardColumnKey;
  label: string;
  count: number;
  color: string;
  cards: BoardCard[];
}

@Component({
  selector: 'app-portal-orders',
  standalone: true,
  templateUrl: './portal-orders.component.html',
  styleUrl: './portal-orders.component.css',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PortalOrdersComponent {
  readonly activeFilter = signal<QuickFilter | null>('high-priority');
  readonly detailOrderId = signal<string | null>(null);
  readonly viewMode = signal<ViewMode>('feed');

  // --- Bidding & Dispatch States ---
  readonly biddingOrderId = signal<string | null>(null);
  readonly bidAmount = signal<string>('');
  readonly isSubmittingBid = signal(false);

  // --- Orders Feed (List View) ---

  readonly orders = signal<OperationsOrder[]>([
    {
      id: '#ORD-9776',
      merchant: 'نيو سيتي إكسبريس',
      priority: 'review',
      priorityLabel: 'مراجعة يدوية مطلوبة',
      confidence: 45,
      confidenceColor: '#BA1A1A',
      warning: 'تم اكتشاف غموض في العنوان.',
      items: [{ label: '15x صناديق عصير مشكل', price: '450 جنيه' }],
      total: '3,950.00 ر.س',
      currency: 'ر.س',
    },
    {
      id: '#ORD-9921',
      merchant: 'سوبر ماركت المدينة',
      priority: 'urgent',
      priorityLabel: 'إرسالية عاجلة',
      confidence: 98,
      confidenceColor: '#2563EB',
      items: [
        { label: '50x حليب (كامل الدسم، 1 لتر)', price: '2,500 جنيه' },
        { label: '20x سكر (ناعم، 5 كجم)', price: '1,750 جنيه' },
      ],
      total: '4,250 جنيه',
      currency: 'جنيه',
    },
    {
      id: '#ORD-9912',
      merchant: 'محامص قهوة السلطان',
      priority: 'scheduled',
      priorityLabel: 'مجدول',
      confidence: 82,
      confidenceColor: '#505F76',
      aiNote: 'ملاحظة الذكاء الاصطناعي: مشترٍ متميز متكرر. يوصى بالقبول الفوري.',
      items: [{ label: '40x بن قهوة (أرابيكا)', price: '8,200 جنيه' }],
      total: '8,200 جنيه',
      currency: 'جنيه',
    },
  ]);

  readonly activeOrdersCount = computed(() => this.orders().length);

  readonly detailOrder = computed(() => {
    const id = this.detailOrderId();
    return id ? (this.orders().find((o) => o.id === id) ?? null) : null;
  });

  readonly detailItems: OrderDetailItem[] = [
    { name: 'Heavy Duty Turbine X-1', qty: 'الكمية: 2 وحدة', total: '38,000 ر.س' },
    { name: 'Thermal Sensor Probe', qty: 'الكمية: 15 وحدة', total: '4,400 ر.س' },
  ];

  readonly timeline: OrderTimelineStep[] = [
    { label: 'تم استلام الطلب', time: 'اليوم، 10:42 ص', done: true },
    { label: 'اكتمل التحقق بالذكاء الاصطناعي', time: 'اليوم، 10:43 ص', done: true },
    { label: 'بانتظار الاستلام من المستودع', time: 'قيد التنفيذ', done: false },
  ];

  readonly boardColumns = signal<BoardColumn[]>([
    {
      key: 'rejected',
      label: 'مرفوض',
      count: 2,
      color: '#7F1D1D',
      cards: [
        {
          id: '#ORD-8655',
          merchant: 'بقالة المدينة',
          subtitle: 'السبب: عدم توفر المخزون',
          total: '1,200.00 جنيه',
          metaLeft: '24 منتج',
        },
      ],
    },
    {
      key: 'shipped',
      label: 'تم الشحن',
      count: 42,
      color: '#14532D',
      cards: [
        {
          id: '#ORD-8791',
          merchant: 'الواحة للتجزئة',
          subtitle: 'متجر #44 - الرياض',
          avatarInitials: 'MS',
          badgeLabel: 'تم التوصيل',
          badgeVariant: 'success',
          total: '9,800.00 جنيه',
          metaLeft: '24 منتج',
          metaRight: 'تم التسليم',
        },
      ],
    },
    {
      key: 'accepted',
      label: 'مقبول',
      count: 8,
      color: '#1E40AF',
      cards: [
        {
          id: '#ORD-8790',
          merchant: 'كويك مارت إكسبريس',
          subtitle: 'مركز الدمام',
          avatarInitials: 'QM',
          badgeLabel: 'منخفض',
          badgeVariant: 'neutral',
          total: '2,150.00 جنيه',
          metaLeft: '45 منتج',
          metaRight: 'مجدول',
        },
      ],
    },
    {
      key: 'pending',
      label: 'قيد الانتظار',
      count: 12,
      color: '#92400E',
      cards: [
        {
          id: '#ORD-8821',
          merchant: 'سوبر ماركت المدينة',
          subtitle: 'متجر #44 - الرياض',
          avatarInitials: 'MS',
          badgeLabel: 'أولوية عالية',
          badgeVariant: 'danger',
          total: '12,450.00 جنيه',
          metaLeft: '24 منتج',
          metaRight: 'منذ 14 دقيقة',
        },
        {
          id: '#ORD-8819',
          merchant: 'زاوية الذواقة',
          subtitle: 'جدة الرئيسي',
          avatarInitials: 'GC',
          badgeLabel: 'متوسط',
          badgeVariant: 'neutral',
          total: '4,200.00 جنيه',
          metaLeft: '8 منتجات',
          metaRight: 'منذ ساعتين',
        },
      ],
    },
  ]);

  setViewMode(mode: ViewMode) {
    this.viewMode.set(mode);
  }

  toggleFilter(filter: QuickFilter) {
    this.activeFilter.update((current) => (current === filter ? null : filter));
  }

  accept(orderId: string) {
    this.orders.update((list) => list.filter((o) => o.id !== orderId));
  }

  reject(orderId: string) {
    this.orders.update((list) => list.filter((o) => o.id !== orderId));
  }

  resolve(orderId: string) {
    this.orders.update((list) =>
      list.map((o) => (o.id === orderId ? { ...o, warning: undefined, priority: 'scheduled', priorityLabel: 'تمت المعالجة' } : o)),
    );
  }

  openDetail(orderId: string) {
    this.detailOrderId.set(orderId);
  }

  closeDetail() {
    this.detailOrderId.set(null);
  }

  // --- Bidding Drawer ---
  openBiddingDrawer(orderId: string) {
    this.biddingOrderId.set(orderId);
    this.bidAmount.set('');
  }

  closeBiddingDrawer() {
    this.biddingOrderId.set(null);
  }

  submitBid() {
    this.isSubmittingBid.set(true);
    // Mock API call
    setTimeout(() => {
      const orderId = this.biddingOrderId();
      if (orderId) {
        // Move from Pending to Accepted in the mock board (for demonstration)
        this.moveCard(orderId, 'pending', 'accepted');
      }
      this.isSubmittingBid.set(false);
      this.closeBiddingDrawer();
    }, 1500);
  }

  // --- Delivery Dispatch ---
  markAsOutForDelivery(orderId: string, event: Event) {
    event.stopPropagation(); // prevent opening drawer/detail
    this.moveCard(orderId, 'accepted', 'shipped');
  }

  private moveCard(cardId: string, fromCol: BoardColumnKey, toCol: BoardColumnKey) {
    this.boardColumns.update(cols => {
      const newCols = JSON.parse(JSON.stringify(cols)) as BoardColumn[];
      const sourceCol = newCols.find(c => c.key === fromCol);
      const destCol = newCols.find(c => c.key === toCol);
      if (!sourceCol || !destCol) return cols;

      const cardIdx = sourceCol.cards.findIndex(c => c.id === cardId);
      if (cardIdx > -1) {
        const [card] = sourceCol.cards.splice(cardIdx, 1);
        destCol.cards.unshift(card);
        sourceCol.count--;
        destCol.count++;
      }
      return newCols;
    });
  }
}
