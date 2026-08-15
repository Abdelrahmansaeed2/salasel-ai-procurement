class StatusMapper {
  static String translate(String status) {
    switch (status) {
      case 'Pending':
        return 'قيد الانتظار';
      case 'PendingPayment':
        return 'بانتظار الدفع';
      case 'Accepted':
        return 'مقبول';
      case 'Shipped':
        return 'تم الشحن';
      case 'Completed':
        return 'مكتمل';
      case 'Rejected':
        return 'مرفوض';
      case 'Manually_Approved':
        return 'مقبول يدوياً';
      case 'ApprovalStatus.Manually_Approved':
        return 'مقبول يدوياً';
      default:
        return status;
    }
  }
}
