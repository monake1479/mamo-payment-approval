import 'package:freezed_annotation/freezed_annotation.dart';

part 'debug_action_state.freezed.dart';

@freezed
abstract class DebugActionPosition with _$DebugActionPosition {
  const factory DebugActionPosition({required double x, required double y}) =
      _DebugActionPosition;
}
