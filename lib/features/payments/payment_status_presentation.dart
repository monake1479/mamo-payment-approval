import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/widgets/payment_status_chip.dart';

extension PaymentStatusPresentation on PaymentStatus {
  PaymentStatusVisual get visual => switch (this) {
    PaymentStatus.pending => PaymentStatusVisual.pending,
    PaymentStatus.approved => PaymentStatusVisual.approved,
    PaymentStatus.rejected => PaymentStatusVisual.rejected,
  };
}
