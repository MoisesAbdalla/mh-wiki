import 'package:mh_wiki/core/domain/failure.dart';

/// Outcome of an operation that can fail with an expected [Failure].
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
