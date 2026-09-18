import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/debug_action/debug_action_state.dart';

final class DebugActionCubit extends Cubit<DebugActionPosition?> {
  DebugActionCubit() : super(null);

  void moveTo(DebugActionPosition position) {
    if (!isClosed && position != state) {
      emit(position);
    }
  }
}
