import 'package:json_annotation/json_annotation.dart';

final class UtcDateTimeJsonConverter extends JsonConverter<DateTime, String> {
  const UtcDateTimeJsonConverter();

  @override
  DateTime fromJson(String json) {
    if (!json.endsWith('Z')) {
      throw const FormatException('Timestamp must use UTC');
    }
    final DateTime? value = DateTime.tryParse(json);
    if (value == null || !value.isUtc) {
      throw const FormatException('Invalid UTC timestamp');
    }
    return value;
  }

  @override
  String toJson(DateTime object) {
    if (!object.isUtc) {
      throw const FormatException('Timestamp must use UTC');
    }
    return object.toIso8601String();
  }
}
