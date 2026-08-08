import { ChangeDetectionStrategy, Component, computed, signal, inject, OnInit } from '@angular/core';
import { OrderService } from '../../../core/services/order.service';
import { AuthService } from '../../../core/auth/auth.service';
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
export class PortalOrdersComponent implements OnInit {
  readonly activeFilter = signal<QuickFilter | null>('high-priority');
  readonly detailOrderId = signal<string | null>(null);
  readonly viewMode = signal<ViewMode>('feed');

  readonly biddingOrderId = signal<string | null>(null);
  readonly bidAmount = signal<string>('');
  readonly isSubmittingBid = signal(false);

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
    { key: 'rejected', label: 'مرفوض', count: 0, color: '#7F1D1D', cards: [] },
    { key: 'shipped', label: 'تم الشحن', count: 0, color: '#14532D', cards: [] },
    { key: 'accepted', label: 'مقبول', count: 0, color: '#1E40AF', cards: [] },
    { key: 'pending', label: 'قيد الانتظار', count: 0, color: '#92400E', cards: [] }
  ]);

  private readonly orderService = inject(OrderService);
  private readonly authService = inject(AuthService);

  ngOnInit() {
    this.orderService.getKanban(1).subscribe({
      next: (data) => {
        const columns: BoardColumn[] = [
          { key: 'pending', label: 'قيد الانتظار (Bidding)', count: data.bidding?.length || 0, color: '#92400E', cards: this.mapCards(data.bidding, 'أولوية', 'danger') },
          { key: 'accepted', label: 'مقبول (Accepted)', count: data.accepted?.length || 0, color: '#1E40AF', cards: this.mapCards(data.accepted, 'مقبول', 'success') },
          { key: 'shipped', label: 'تم الشحن (Shipped)', count: data.shipped?.length || 0, color: '#14532D', cards: this.mapCards(data.shipped, 'في الطريق', 'success') },
          { key: 'rejected', label: 'مرفوض (Rejected)', count: data.rejected?.length || 0, color: '#7F1D1D', cards: this.mapCards(data.rejected, 'مرفوض', 'neutral') },
        ];
        this.boardColumns.set(columns);
      },
      error: (err) => console.error('Error fetching Kanban:', err)
    });
  }

  private mapCards(items: any[], badgeLabel: string, badgeVariant: any): BoardCard[] {
    if (!items) return [];
    return items.map(item => ({
      id: `#ORD-${item.subOrderId}`,
      merchant: item.merchantName || 'مشتري',
      subtitle: item.productName || 'منتج',
      badgeLabel: badgeLabel,
      badgeVariant: badgeVariant,
      total: `${item.subTotalAmount} ر.س`,
      metaLeft: `الكمية: ${item.quantity}`,
      metaRight: item.status
    }));
  }

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

  openBiddingDrawer(orderId: string) {
    this.biddingOrderId.set(orderId);
    this.bidAmount.set('');
  }

  closeBiddingDrawer() {
    this.biddingOrderId.set(null);
  }

  // Injectors moved to top

  submitBid() {
    this.isSubmittingBid.set(true);
    const orderIdStr = this.biddingOrderId();
    if (orderIdStr) {
      // Clean '#ORD-' string prefix if any, assuming backend expects int id
      const id = parseInt(orderIdStr.replace(/[^0-9]/g, ''));
      const amount = parseFloat(this.bidAmount());
      
      this.orderService.submitBid(id, amount).subscribe({
        next: () => {
          this.moveCard(orderIdStr, 'pending', 'accepted');
          this.isSubmittingBid.set(false);
          this.closeBiddingDrawer();
          
          // Re-fetch to ensure sync with backend
          this.ngOnInit();
        },
        error: (err) => {
          console.error(err);
          this.isSubmittingBid.set(false);
        }
      });
    }
  }

  markAsOutForDelivery(orderIdStr: string, event: Event) {
    event.stopPropagation();
    const id = parseInt(orderIdStr.replace(/[^0-9]/g, ''));
    
    this.orderService.dispatchOrder(id).subscribe({
      next: () => {
        this.moveCard(orderIdStr, 'accepted', 'shipped');
        this.ngOnInit();
      },
      error: (err) => {
        console.error(err);
      }
    });
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
