part of 'challenge_cubit.dart';

@immutable
sealed class ChallengeState {}

final class ChallengeInitial extends ChallengeState {}

final class ChallengeSuccess extends ChallengeState {}

final class ChallengeError extends ChallengeState {
  final String error;

  ChallengeError(this.error);
}

final class ChallengeEnd extends ChallengeState {
  final DateTime endDay;

  ChallengeEnd(this.endDay);
}

final class ChallengeLoading extends ChallengeState {}

final class ChallengeList extends ChallengeState {
  final List<Challenge> challenges;

  ChallengeList(this.challenges);
}
