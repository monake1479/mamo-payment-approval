import 'package:json_annotation/json_annotation.dart';

final class PaymentAmountJsonConverter extends JsonConverter<double, String> {
  const PaymentAmountJsonConverter();

  @override
  double fromJson(String json) {
    final double? amount = double.tryParse(json);
    if (amount == null) {
      throw const FormatException('Invalid payment amount');
    }
    return amount;
  }

  @override
  String toJson(double object) => object.toString();
}
