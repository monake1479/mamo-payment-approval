import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<F, T> with _$Result<F, T> {
  const Result._();

  const factory Result.success(T value) = Success<F, T>;

  const factory Result.failure(F failure) = Failure<F, T>;

  bool get isSuccess => this is Success<F, T>;

  bool get isFailure => this is Failure<F, T>;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    return switch (this) {
      Success<F, T>(:final value) => onSuccess(value),
      Failure<F, T>(:final failure) => onFailure(failure),
    };
  }
}
