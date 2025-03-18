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

final class FeedPushNotification extends FeedState {
  final String feedId, text;

  FeedPushNotification(this.feedId, this.text);
}

enum FeedCategory { all, challenge }
