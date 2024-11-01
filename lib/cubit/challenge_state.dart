part of 'challenge_cubit.dart';

@immutable
sealed class ChallengeState {}

final class ChallengeInitial extends ChallengeState {}

final class ChallengeSuccess extends ChallengeState {}

final class ChallengeError extends ChallengeState {
  final String error;

  ChallengeError(this.error);
}

final class ChallengeEnd extends ChallengeState {}
