import 'package:freezed_annotation/freezed_annotation.dart';

part 'debug_action_state.freezed.dart';

@freezed
abstract class DebugActionState with _$DebugActionState {
  const factory DebugActionState({required double x, required double y}) =
      _DebugActionState;
}
