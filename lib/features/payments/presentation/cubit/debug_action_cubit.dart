import 'package:flutter_bloc/flutter_bloc.dart';

final class DebugActionPosition {
  const DebugActionPosition({required this.x, required this.y});

  final double x;
  final double y;

  @override
  bool operator ==(Object other) =>
      other is DebugActionPosition && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

final class DebugActionCubit extends Cubit<DebugActionPosition?> {
  DebugActionCubit() : super(null);

  void moveTo(DebugActionPosition position) {
    if (!isClosed && position != state) {
      emit(position);
    }
  }
}
