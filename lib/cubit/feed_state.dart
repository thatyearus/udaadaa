part of 'feed_cubit.dart';

@immutable
sealed class FeedState {}

final class FeedInitial extends FeedState {}

final class FeedLoaded extends FeedState {
  final List<Feed> feeds;

  FeedLoaded(this.feeds);
}

final class FeedError extends FeedState {}
