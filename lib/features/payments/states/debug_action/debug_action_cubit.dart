import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/features/payments/states/debug_action/debug_action_state.dart';

final class DebugActionCubit extends Cubit<DebugActionState?> {
  DebugActionCubit() : super(null);

  void moveTo(DebugActionState position) {
    if (!isClosed && position != state) {
      emit(position);
    }
  }
}
