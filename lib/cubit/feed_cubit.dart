import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/reaction.dart';
import 'package:udaadaa/utils/constant.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  List<Feed> _myFeeds = [];
  List<Feed> _feeds = [];
  List<String> _blockedFeedIds = [];
  final int _limit = 10;
  int _curFeedPage = 0;

  FeedCubit() : super(FeedInitial()) {
    fetchBlockedFeed().then((_) => _getFeeds());
    fetchMyFeeds();
  }

  Future<void> fetchBlockedFeed() async {
    try {
      final data = await supabase
          .from('blocked_feed')
          .select('feed_id')
          .eq('user_id', supabase.auth.currentUser!.id);
      final blockedFeedIds = data.map((item) => item['feed_id'] as String);
      _blockedFeedIds = blockedFeedIds.toList();
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> _getFeeds({bool loadMore = false}) async {
    try {
      final data = await supabase
          .from('random_feed')
          .select('*, profiles(*)')
          .not('id', 'in', _blockedFeedIds.toList())
          .limit(_limit);
      logger.d(data);
      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();
      final signedUrls = await supabase.storage
          .from('FeedImages')
          .createSignedUrls(imagePaths, 3600);

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      } else {
        final List<Feed> newFeeds = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i].signedUrl;
          newFeeds.add(Feed.fromMap(map: item));
        }
        _feeds = loadMore ? [..._feeds, ...newFeeds] : newFeeds;
        emit(FeedLoaded());
      }
    } catch (e) {
      logger.e(e);
      emit(FeedError());
    }
  }

  void changePage(int page) {
    _curFeedPage = page;
    logger.d("Current page: $_curFeedPage");
  }

  Future<void> fetchMyFeeds() async {
    try {
      final data = await supabase
          .from('feed')
          .select('*, profiles(*)')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();
      final signedUrls = await supabase.storage
          .from('FeedImages')
          .createSignedUrls(imagePaths, 3600);

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      } else {
        _myFeeds = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i].signedUrl;
          _myFeeds.add(Feed.fromMap(map: item));
        }
      }
      emit(FeedLoaded());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> addReaction(String feedId, ReactionType reaction) async {
    try {
      final newReaction = Reaction(
          userId: supabase.auth.currentUser!.id,
          feedId: feedId,
          type: reaction);
      await supabase
          .from('reactions')
          .upsert(newReaction.toMap(), onConflict: "user_id, feed_id");
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> getMoreFeeds() async {
    await _getFeeds(loadMore: true);
  }

  Future<void> blockFeed(String feedId) async {
    try {
      await supabase.from('blocked_feed').upsert(
          {'user_id': supabase.auth.currentUser!.id, 'feed_id': feedId},
          onConflict: 'user_id, feed_id');
    } catch (e) {
      logger.e(e);
    }
  }

  void blockFeedPage() {
    final feedId = _feeds[_curFeedPage].id!;
    blockFeed(feedId).then(
      (_) {
        getMoreFeeds().then((_) => _feeds.removeAt(_curFeedPage));
      },
    );
  }

  List<Feed> get getMyFeeds => _myFeeds;
  List<Feed> get getFeeds => _feeds;
}
