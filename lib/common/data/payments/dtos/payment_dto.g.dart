// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentDto _$PaymentDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PaymentDto', json, ($checkedConvert) {
      final val = _PaymentDto(
        id: $checkedConvert('id', (v) => v as String),
        counterparty: $checkedConvert('counterparty', (v) => v as String),
        amount: $checkedConvert(
          'amount',
          (v) => const PaymentAmountJsonConverter().fromJson(v as String),
        ),
        currency: $checkedConvert('currency', (v) => v as String),
        reference: $checkedConvert('reference', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => const UtcDateTimeJsonConverter().fromJson(v as String),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$PaymentStatusEnumMap, v),
        ),
        decidedAt: $checkedConvert(
          'decidedAt',
          (v) => _$JsonConverterFromJson<String, DateTime>(
            v,
            const UtcDateTimeJsonConverter().fromJson,
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PaymentDtoToJson(_PaymentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'counterparty': instance.counterparty,
      'amount': const PaymentAmountJsonConverter().toJson(instance.amount),
      'currency': instance.currency,
      'reference': instance.reference,
      'createdAt': const UtcDateTimeJsonConverter().toJson(instance.createdAt),
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'decidedAt': _$JsonConverterToJson<String, DateTime>(
        instance.decidedAt,
        const UtcDateTimeJsonConverter().toJson,
      ),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.approved: 'approved',
  PaymentStatus.rejected: 'rejected',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
