import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/reaction.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/constant.dart';

import '../utils/analytics/analytics.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final AuthCubit authCubit;
  late final StreamSubscription authSubscription;
  List<Feed> _myFeeds = [];
  List<Feed> _feeds = [];
  List<List<Feed>> _homeFeeds = [[], [], []];
  List<String> _blockedFeedIds = [];
  final int _limit = 10;
  int _curFeedPage = 0;
  int _myFeedPage = 0;
  List<int> _curHomeFeedPage = [0, 0, 0];

  FeedCubit(this.authCubit) : super(FeedInitial()) {
    if (authCubit.state is Authenticated) {
      fetchBlockedFeed().then((_) {
        fetchHomeFeeds();
        _getFeeds();
      });
      fetchMyFeeds();
    }

    authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        fetchBlockedFeed().then((_) {
          fetchHomeFeeds();
          _getFeeds();
        });
        fetchMyFeeds();
      } else {
        _feeds = [];
        _myFeeds = [];
        emit(FeedInitial());
      }
    });
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
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

  Future<void> fetchHomeFeeds() async {
    try {
      final data = await supabase
          .from('random_feed')
          .select('*, profiles(*)')
          .not('id', 'in', _blockedFeedIds.toList())
          .limit(_limit);
      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();
      final signedUrls = await supabase.storage
          .from('FeedImages')
          .createSignedUrls(imagePaths, 3600);

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      } else {
        _homeFeeds = [[], [], []];
        _curHomeFeedPage = [0, 0, 0];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i].signedUrl;
          _homeFeeds[i % _homeFeeds.length].add(Feed.fromMap(map: item));
        }
        logger.d(_homeFeeds);
        emit(FeedLoaded());
      }
    } catch (e) {
      logger.e(e);
      emit(FeedError());
    }
  }

  Future<void> getMoreHomeFeeds(int index) async {
    logger.d("Get more home feeds index: $index");
    try {
      final data = await supabase
          .from('random_feed')
          .select('*, profiles(*)')
          .not('id', 'in', _blockedFeedIds.toList())
          .limit(_limit);
      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();
      final signedUrls = await supabase.storage
          .from('FeedImages')
          .createSignedUrls(imagePaths, 3600);

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      } else {
        List<Feed> newFeeds = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i].signedUrl;
          newFeeds.add(Feed.fromMap(map: item));
        }
        _homeFeeds[index] = [..._homeFeeds[index], ...newFeeds];
        emit(FeedLoaded());
      }
    } catch (e) {
      logger.e(e);
      emit(FeedError());
    }
  }

  Future<void> _getFeeds({bool loadMore = false}) async {
    try {
      var data = [];

      if (!loadMore) {
        data = await supabase
            .from('feed')
            .select('*, profiles(*)')
            .not('id', 'in', _blockedFeedIds.toList())
            .order('created_at', ascending: false)
            .limit(_limit);
      } else {
        data = await supabase
            .from('random_feed')
            .select('*, profiles(*)')
            .not('id', 'in', _blockedFeedIds.toList())
            .limit(_limit);
      }

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
    if (page == _feeds.length - 1) {
      getMoreFeeds();
    }
    logger.d("Current page: $_curFeedPage");
    Analytics().logEvent("피드_피드탐색", parameters: {
      "현재피드": _curFeedPage,
    });
  }

  void changeHomeFeedPage(int index, int page) {
    _curHomeFeedPage[index] = page;
    if (page == _homeFeeds[index].length - 1) {
      getMoreHomeFeeds(index);
    }
    logger.d("Current home feed page: $_curHomeFeedPage");
  }

  void changeMyFeedPage(int page) {
    _myFeedPage = page;
    Analytics().logEvent("피드_내피드탐색", parameters: {
      "현재피드": _myFeedPage,
    });
  }

  Future<void> fetchMyFeeds() async {
    try {
      final data = await supabase
          .from('feed')
          .select('*, profiles(*), reactions(*, profiles(*))')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
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
        _myFeeds = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i].signedUrl;
          _myFeeds.add(Feed.fromMap(map: item));
        }
        logger.d(_myFeeds);
      }
      emit(FeedLoaded());
    } catch (e) {
      logger.e(e);
      emit(FeedError());
    }
  }

  Future<void> addReaction(String feedId, ReactionType reaction) async {
    try {
      Analytics().logEvent(
        "피드_리액션",
        parameters: {"리액션": reaction.toString().split('.').last},
      );
      final newReaction = Reaction(
          userId: supabase.auth.currentUser!.id,
          feedId: feedId,
          type: reaction);
      await supabase
          .from('reactions')
          .upsert(newReaction.toMap(), onConflict: "user_id, feed_id");
      logger.d("Reaction added: $reaction");
    } catch (e) {
      Analytics().logEvent(
        "피드_리액션_에러",
        parameters: {"에러": e.toString()},
      );
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
      _blockedFeedIds.add(feedId);
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

  void blockDetailPage(int stackIndex) {
    final feedId = _homeFeeds[stackIndex][_curHomeFeedPage[stackIndex]].id!;
    blockFeed(feedId).then(
      (_) {
        getMoreHomeFeeds(stackIndex).then((_) =>
            _homeFeeds[stackIndex].removeAt(_curHomeFeedPage[stackIndex]));
      },
    );
  }

  void deleteMyFeed() async {
    final feedId = _myFeeds[_myFeedPage].id!;
    try {
      final reportMap = await supabase.from('report').select().eq(
          'date', _myFeeds[_myFeedPage].createdAt!.toLocal().toIso8601String());
      if (reportMap.isEmpty) {
        logger.e("No report data");
        throw "No report data";
      }
      Report report = Report.fromMap(map: reportMap[0]);
      report = report.copyWith(
        breakfast: (report.breakfast ?? 0) -
            (_myFeeds[_myFeedPage].type == FeedType.breakfast
                ? (_myFeeds[_myFeedPage].calorie ?? 0)
                : 0),
        lunch: (report.lunch ?? 0) -
            (_myFeeds[_myFeedPage].type == FeedType.lunch
                ? (_myFeeds[_myFeedPage].calorie ?? 0)
                : 0),
        dinner: (report.dinner ?? 0) -
            (_myFeeds[_myFeedPage].type == FeedType.dinner
                ? (_myFeeds[_myFeedPage].calorie ?? 0)
                : 0),
        snack: (report.snack ?? 0) -
            (_myFeeds[_myFeedPage].type == FeedType.snack
                ? (_myFeeds[_myFeedPage].calorie ?? 0)
                : 0),
      );
      if ((report.breakfast ?? 0) < 0 ||
          (report.lunch ?? 0) < 0 ||
          (report.dinner ?? 0) < 0 ||
          (report.snack ?? 0) < 0) {
        logger.e("Negative report data");
        throw "Negative report data";
      }
      await supabase
          .from('report')
          .upsert(report.toMap(), onConflict: 'user_id, date');
      await supabase.from('feed').delete().eq('id', feedId);
      fetchMyFeeds();
    } catch (e) {
      logger.e(e);
      Analytics().logEvent("피드_삭제_에러", parameters: {"에러": e.toString()});
    }
  }

  List<Feed> get getMyFeeds => _myFeeds;
  List<Feed> get getFeeds => _feeds;
  List<List<Feed>> get getHomeFeeds => _homeFeeds;

  Iterable<Reaction> getReaction(String feedId, ReactionType reactionField) {
    final feed = _myFeeds.firstWhere((feed) => feed.id == feedId);
    return feed.reaction?.where((reaction) => reaction.type == reactionField) ??
        [];
  }
}
