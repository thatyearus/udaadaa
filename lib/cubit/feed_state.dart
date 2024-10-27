part of 'feed_cubit.dart';

@immutable
sealed class FeedState {}

final class FeedInitial extends FeedState {}

final class FeedLoaded extends FeedState {}

final class FeedError extends FeedState {}

final class FeedDetail extends FeedState {
  final Feed feed;
  final int index;

  FeedDetail(this.feed, this.index);
}

enum FeedCategory {
  all,
  challenge
}