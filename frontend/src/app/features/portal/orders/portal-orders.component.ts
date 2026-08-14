import { ChangeDetectionStrategy, Component, computed, signal, inject, OnInit } from '@angular/core';
import { OrderService } from '../../../core/services/order.service';
import { AuthService } from '../../../core/auth/auth.service';
import { ToastService } from '../../../core/services/toast.service';
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
  badgeVariant?: 'success' | 'danger' | 'neutral' | 'warning';
  total: string;
  metaLeft: string;
  metaRight?: string;
  paymentStatus?: string;
  paymentMethod?: string;
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
  readonly viewMode = signal<ViewMode>('board');

  readonly biddingOrderId = signal<string | null>(null);
  readonly bidAmount = signal<string>('');
  readonly isSubmittingBid = signal(false);

  readonly orders = signal<OperationsOrder[]>([]);

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
    { key: 'pending', label: 'طلبات جديدة', count: 0, color: '#92400E', cards: [] },
    { key: 'accepted', label: 'قيد التنفيذ', count: 0, color: '#1E40AF', cards: [] },
    { key: 'shipped', label: 'تم التسليم', count: 0, color: '#14532D', cards: [] },
    { key: 'rejected', label: 'مرفوض', count: 0, color: '#7F1D1D', cards: [] }
  ]);

  private readonly orderService = inject(OrderService);
  private readonly authService = inject(AuthService);
  private readonly toastService = inject(ToastService);

  ngOnInit() {
    this.orderService.getKanban().subscribe({
      next: (data) => {
        // Map the columns from backend
        if (data && data.columns) {
          const cols: BoardColumn[] = data.columns.map((col: any) => {
            let color = '#191B23';
            if (col.key === 'Pending') color = '#92400E';
            if (col.key === 'Accepted' || col.key === 'Bidding') color = '#1E40AF';
            if (col.key === 'Shipped') color = '#B45309';
            if (col.key === 'Delivered') color = '#14532D';
            if (col.key === 'Rejected') color = '#7F1D1D';

            return {
              key: col.key.toLowerCase(),
              label: col.label,
              count: col.cards?.length || 0,
              color: color,
              cards: this.mapCards(col.cards || [], col.label, 'neutral')
            };
          });
          this.boardColumns.set(cols);
        }
      },
      error: (err) => console.error('Error fetching Kanban:', err)
    });

    this.orderService.getOrdersFeed().subscribe({
      next: (feedData) => {
        this.orders.set(feedData || []);
      },
      error: (err) => console.error('Error fetching Orders Feed:', err)
    });
  }

  private mapCards(items: any[], badgeLabel: string, badgeVariant: any): BoardCard[] {
    if (!items) return [];
    return items.map(item => ({
      id: item.id,
      merchant: item.merchant || 'مشتري',
      subtitle: item.productName || 'منتج',
      badgeLabel: badgeLabel,
      badgeVariant: badgeVariant,
      total: `${item.subTotalAmount} ر.س`,
      metaLeft: `الكمية: ${item.quantity}`,
      metaRight: item.status,
      paymentStatus: item.paymentStatus,
      paymentMethod: item.paymentMethod
    }));
  }

  setViewMode(mode: ViewMode) {
    this.viewMode.set(mode);
  }

  toggleFilter(filter: QuickFilter) {
    this.activeFilter.update((current) => (current === filter ? null : filter));
  }

  accept(orderIdStr: string) {
    let subOrderId: number;
    if (orderIdStr.startsWith('ORD-')) {
      const parts = orderIdStr.split('-');
      subOrderId = parseInt(parts[2], 10);
    } else {
      subOrderId = parseInt(orderIdStr.replace(/[^0-9]/g, ''), 10);
    }

    if (!subOrderId) return;

    this.orderService.updateOrderStatus(subOrderId, 'Accepted').subscribe({
      next: () => {
        // Refresh both views from backend to reflect the real state
        this.ngOnInit();
      },
      error: (err) => {
        const msg = err.error?.message || err.message || 'حدث خطأ غير متوقع';
        console.error('Failed to accept order:', err);
        this.toastService.error(msg);
      }
    });
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
      let id: number;
      if (orderIdStr.startsWith('ORD-')) {
        // Format: ORD-{masterId}-{subId} -> we need subId
        const parts = orderIdStr.split('-');
        id = parseInt(parts[2], 10);
      } else {
        // Format: SUB-{id}
        id = parseInt(orderIdStr.replace(/[^0-9]/g, ''), 10);
      }
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
          const msg = err.error?.message || err.message || 'فشل تقديم العرض';
          console.error(err);
          this.toastService.error(msg);
          this.isSubmittingBid.set(false);
        }
      });
    }
  }

  markAsOutForDelivery(orderIdStr: string, event: Event) {
    event.stopPropagation();
    let id: number;
    if (orderIdStr.startsWith('ORD-')) {
      const parts = orderIdStr.split('-');
      id = parseInt(parts[2], 10);
    } else {
      id = parseInt(orderIdStr.replace(/[^0-9]/g, ''), 10);
    }
    
    this.orderService.dispatchOrder(id).subscribe({
      next: () => {
        this.moveCard(orderIdStr, 'accepted', 'shipped');
        this.ngOnInit();
      },
      error: (err) => {
        const msg = err.error?.message || err.message || 'حدث خطأ';
        console.error(err);
        this.toastService.error(msg);
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
