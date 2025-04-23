import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/models/reaction.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/constant.dart';

import '../utils/analytics/analytics.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final AuthCubit authCubit;
  final ChallengeCubit challengeCubit;
  late final StreamSubscription authSubscription;
  List<Feed> _myFeeds = [];
  List<Feed> _feeds = [];
  List<List<Feed>> _homeFeeds = [[], [], []];
  List<String> _blockedFeedIds = [];
  List<String> _reactionFeedIds = [];
  final int _limit = 10;
  int _curFeedPage = 0;
  int _myFeedPage = 0;
  List<int> _curHomeFeedPage = [0, 0, 0];
  List<Feed> allFeeds = [];
  bool _fallbackChk = false;

  final String baseUrl = '$supabaseUrl/storage/v1/object/public/FeedImages/';

  final Feed fallbackFeed = Feed(
    id: "f3bfa4e8-9d33-4b63-8bff-4f3a0a7e1eaa",
    userId: "166c0505-768c-422e-a177-39f505f9f7c5",
    createdAt: null,
    review: "",
    type: FeedType.exercise,
    imagePath: "fallback_exercise.jpg", // ✅ fallback-images 버킷 내 경로
    imageUrl:
        "https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/fallback-images/fallback_exercise.jpg", // ✅ 퍼블릭 URL 적용
    profile: Profile(
      id: "166c0505-768c-422e-a177-39f505f9f7c5",
      nickname: "",
    ),
  );

  FeedCategory _currentCategory = FeedCategory.all;

  FeedCubit(this.authCubit, this.challengeCubit) : super(FeedInitial()) {
    if (authCubit.state is Authenticated) {
      Future.wait([fetchBlockedFeed(), fetchReactionFeed()]).then((_) {
        _getFeeds();
      });
      fetchMyFeeds();
    }

    authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        Future.wait([fetchBlockedFeed(), fetchReactionFeed()]).then((_) {
          _getFeeds();
        });
        fetchMyFeeds();
      } else {
        _feeds = [];
        _myFeeds = [];
        emit(FeedInitial());
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['feedId'] != null) {
        logger.d('onMessageOpenedApp: $message');
        emit(FeedPushNotification(
            message.data['feedId'], message.notification!.body!));
        openFeedDetail(message);
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      logger.d('getInitialMessage: $message');
      openFeedDetail(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['feedId'] != null) {
        logger.d('onMessage: $message');
        emit(FeedPushNotification(
            message.data['feedId'], message.notification!.body!));
      }
    });
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }

  void changeCategory(FeedCategory category) {
    if (_currentCategory != category) {
      _currentCategory = category;
      if (_currentCategory == FeedCategory.all) {
        _getFeeds();
      } else {
        _getExerciseFeeds();
      }
    }
  }

  void openFeedDetail(RemoteMessage? message) {
    if (message != null) {
      final feedId = message.data['feedId'];
      logger.d("Feed ID: $feedId");
      if (feedId != null) {
        openFeed(feedId);
      }
    }
  }

  void openFeed(String feedId) {
    final feed = _myFeeds.firstWhere(
      (feed) => feed.id == feedId,
      orElse: () =>
          Feed(userId: '', review: '', type: FeedType.breakfast, imagePath: ''),
    );
    if (feed.id != null) {
      final feedIndex = _myFeeds.indexOf(feed);
      emit(FeedDetail(feed, feedIndex));
    }
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

  Future<void> fetchReactionFeed() async {
    try {
      final data = await supabase
          .from('reactions')
          .select('feed_id')
          .eq('user_id', supabase.auth.currentUser!.id);
      final reactionFeedIds = data.map((item) => item['feed_id'] as String);
      _reactionFeedIds = reactionFeedIds.toList();
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

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      }

      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();

      // 📦 안정적인 signed URL 요청 (폴링 포함)
      final signedUrls = await _getSignedUrlsWithRetry(imagePaths);

      _homeFeeds = [[], [], []];
      _curHomeFeedPage = [0, 0, 0];

      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        final signedUrl = signedUrls[i];

        item['image_url'] = signedUrl;
        _homeFeeds[i % _homeFeeds.length].add(Feed.fromMap(map: item));
      }

      if (_homeFeeds.every((feeds) => feeds.isEmpty)) {
        logger.e("✅ 데이터는 있었지만 signedUrl 실패로 추가된 피드 없음");
        throw "All signed URLs failed";
      }

      logger.d(_homeFeeds);
      emit(FeedLoaded());
    } catch (e) {
      logger.e("❌ 홈 피드 로딩 실패: $e");
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

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      }

      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();

      // 📦 안정적인 signed URL 요청 (폴링 포함)
      final signedUrls = await _getSignedUrlsWithRetry(imagePaths);

      List<Feed> newFeeds = [];

      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        final signedUrl = signedUrls[i];

        item['image_url'] = signedUrl;
        newFeeds.add(Feed.fromMap(map: item));
      }

      if (newFeeds.isEmpty) {
        logger.e("✅ 데이터는 있었지만 signedUrl 실패로 추가된 피드 없음");
        throw "All signed URLs failed";
      }

      _homeFeeds[index] = [..._homeFeeds[index], ...newFeeds];
      emit(FeedLoaded());
    } catch (e) {
      logger.e("❌ 추가 홈 피드 로딩 실패: $e");
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
            .not('id', 'in', _reactionFeedIds.toList())
            .not('type', 'eq', FeedType.exercise.name)
            .order('created_at', ascending: false)
            .limit(_limit);
      } else {
        data = await supabase
            .from('random_feed')
            .select('*, profiles(*)')
            .not('id', 'in', _blockedFeedIds.toList())
            .not('id', 'in', _reactionFeedIds.toList())
            .not('type', 'eq', FeedType.exercise.name)
            .limit(_limit);
      }

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      }

      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();

      // 📦 폴링 처리된 signed URL 요청
      final signedUrls = await _getSignedUrlsWithRetry(imagePaths);

      final List<Feed> newFeeds = [];

      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        final signedUrl = signedUrls[i];

        item['image_url'] = signedUrl;
        newFeeds.add(Feed.fromMap(map: item));
      }

      if (newFeeds.isEmpty) {
        logger.e("✅ 데이터는 있었지만 signedUrl 실패로 추가된 Feed 없음");
        throw "All signed URLs failed";
      }

      _feeds = loadMore ? [..._feeds, ...newFeeds] : newFeeds;
      emit(FeedLoaded());
    } catch (e) {
      logger.e("❌ Feed 로딩 실패: $e");
      emit(FeedError());
    }
  }

  Future<void> _getExerciseFeeds({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _fallbackChk = false; // ✅ 카테고리 변경 시 fallbackChk 초기화
      }

      if (_fallbackChk) {
        logger.w("🚨 Fallback이 실행되었으므로 더 이상 데이터를 가져오지 않음");
        return;
      }

      var data = [];

      if (!loadMore) {
        data = await supabase
            .from('feed')
            .select('*, profiles(*)')
            .not('id', 'in', _blockedFeedIds.toList())
            .not('id', 'in', _reactionFeedIds.toList())
            .eq('type', FeedType.exercise.name)
            .order('created_at', ascending: false)
            .limit(_limit);
      } else {
        final currentFeedId = _feeds[_curFeedPage].id;
        data = await supabase
            .from('random_feed')
            .select('*, profiles(*)')
            .not('id', 'in', _blockedFeedIds.toList())
            .not('id', 'in', _reactionFeedIds.toList())
            .not('id', 'eq', currentFeedId) // ✅ 현재 보고 있는 피드 제외
            .eq('type', FeedType.exercise.name)
            .limit(_limit);
      }

      // ✅ fallback 처리
      if (data.isEmpty) {
        logger.w("🚨 운동 피드 없음 → fallback 피드 추가");
        _fallbackChk = true;

        final List<Feed> newFeeds = [];
        newFeeds.add(fallbackFeed);
        _feeds = loadMore ? [..._feeds, ...newFeeds] : newFeeds;

        emit(FeedLoaded());
        return;
      }

      // const baseUrl =
      //     'https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/FeedImages/';

      final List<Feed> newFeeds = [];
      for (var item in data) {
        final imagePath = item['image_path'] as String?;
        item['image_url'] = imagePath != null ? '$baseUrl$imagePath' : null;
        newFeeds.add(Feed.fromMap(map: item));
      }

      _feeds = loadMore ? [..._feeds, ...newFeeds] : newFeeds;
      emit(FeedLoaded());
    } catch (e) {
      logger.e(e);
      emit(FeedError());
    }
  }

  // Future<void> _getExerciseFeeds({bool loadMore = false}) async {
  //   try {
  //     if (!loadMore) {
  //       _fallbackChk = false; // ✅ 카테고리 변경 시 fallbackChk 초기화
  //     }

  //     if (_fallbackChk) {
  //       logger.w("🚨 Fallback이 실행되었으므로 더 이상 데이터를 가져오지 않음");
  //       return;
  //     }

  //     var data = [];

  //     if (!loadMore) {
  //       data = await supabase
  //           .from('feed')
  //           .select('*, profiles(*)')
  //           .not('id', 'in', _blockedFeedIds.toList())
  //           .not('id', 'in', _reactionFeedIds.toList())
  //           .eq('type', FeedType.exercise.name)
  //           .order('created_at', ascending: false)
  //           .limit(_limit);
  //     } else {
  //       final currentFeedId = _feeds[_curFeedPage].id;
  //       data = await supabase
  //           .from('random_feed')
  //           .select('*, profiles(*)')
  //           .not('id', 'in', _blockedFeedIds.toList())
  //           .not('id', 'in', _reactionFeedIds.toList())
  //           .not('id', 'eq', currentFeedId) // ✅ 현재 보고 있는 피드 제외
  //           .eq('type', FeedType.exercise.name)
  //           .limit(_limit);
  //     }

  //     // ✅ fallback 처리
  //     if (data.isEmpty) {
  //       logger.w("🚨 운동 피드 없음 → fallback 피드 추가");
  //       _fallbackChk = true;

  //       final List<Feed> newFeeds = [];

  //       // ✅ fallbackFeed 추가
  //       newFeeds.add(fallbackFeed);

  //       // ✅ 기존 피드에 추가하는 방식 적용
  //       _feeds = loadMore ? [..._feeds, ...newFeeds] : newFeeds;

  //       emit(FeedLoaded());
  //       return;
  //     }

  //     final imagePaths =
  //         data.map((item) => item['image_path'] as String).toList();
  //     final signedUrls = await supabase.storage
  //         .from('FeedImages')
  //         .createSignedUrls(imagePaths, 3600 * 12);

  //     if (data.isEmpty) {
  //       logger.e("No data");
  //       throw "No data";
  //     } else {
  //       final List<Feed> newFeeds = [];
  //       for (var i = 0; i < data.length; i++) {
  //         final item = data[i];
  //         item['image_url'] = signedUrls[i].signedUrl;
  //         newFeeds.add(Feed.fromMap(map: item));
  //       }
  //       _feeds = loadMore ? [..._feeds, ...newFeeds] : newFeeds;
  //       emit(FeedLoaded());
  //     }
  //   } catch (e) {
  //     logger.e(e);
  //     emit(FeedError());
  //   }
  // }

/*
  Future<void> _getChallengeFeeds({bool loadMore = false}) async {
    if (_currentCategory != FeedCategory.challenge) return;

    try {
      if (!loadMore) {
        final challengeData = await supabase.from('challenge').select('*');
        allFeeds = [];
        for (final challengeMap in challengeData) {
          Challenge challenge = Challenge.fromMap(map: challengeMap);
          final feedData = await supabase
              .from('feed')
              .select('*, profiles(*)')
              .gte('created_at', challenge.startDay.toIso8601String())
              .lte('created_at', challenge.endDay.toIso8601String())
              .not('id', 'in', _blockedFeedIds.toList())
              .eq('user_id', challenge.userId);
          for (var i = 0; i < feedData.length; i++) {
            allFeeds.add(Feed.fromMap(map: feedData[i]));
          }
        }
        allFeeds.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      }
      if (allFeeds.isEmpty) {
        _currentCategory = FeedCategory.all;
        return;
      }
      if (!loadMore) _feeds = [];
      final newFeeds = allFeeds.sublist(
        _feeds.length,
        min(_feeds.length + _limit, allFeeds.length),
      );
      final imagePaths = newFeeds.map((item) => item.imagePath).toList();
      final signedUrls = await supabase.storage
          .from('FeedImages')
          .createSignedUrls(imagePaths, 3600);
      for (var i = 0; i < newFeeds.length; i++) {
        newFeeds[i] = newFeeds[i].copyWith(imageUrl: signedUrls[i].signedUrl);
      }

      _feeds = loadMore ? [..._feeds, ...newFeeds] : newFeeds;
      emit(FeedLoaded());
    } catch (e) {
      logger.e(e);
      emit(FeedError());
    }
  }
*/
  void changePage(int page) {
    _curFeedPage = page;
    if (page == _feeds.length - 1) {
      getMoreFeeds();
    }
    logger.d("Current page: $_curFeedPage");
    Analytics().logEvent("피드_피드탐색", parameters: {
      "현재피드": _curFeedPage,
      "카테고리": _currentCategory.toString(),
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
          .order('created_at', ascending: false)
          .limit(30);

      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();

      final signedUrls = await _getPublicUrls(imagePaths);

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      } else {
        _myFeeds = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i]; // 실패했으면 null일 수도 있음
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

  Future<List<String>> _getPublicUrls(List<String> paths) async {
    // const baseUrl =
    //     'https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/FeedImages/';

    logger.d("🧵 총 ${paths.length}개의 퍼블릭 이미지 URL 생성 시작");

    final results = paths.map((path) => '$baseUrl$path').toList();

    logger.d("🎉 퍼블릭 URL 생성 완료 (${results.length}/${paths.length})");

    return results;
  }

  // Future<List<String?>> _getSignedUrlsInBatches(List<String> paths,
  //     {int batchSize = 6, int retry = 3}) async {
  //   List<String?> allResults = [];

  //   logger.d("🧵 총 ${paths.length}개의 이미지 Signed URL 생성 시작");

  //   for (int i = 0; i < paths.length; i += batchSize) {
  //     final batch = paths.skip(i).take(batchSize).toList();
  //     // logger.d("📦 [${i ~/ batchSize + 1}번째 배치] ${batch.length}개 처리 시작");

  //     final results = await Future.wait(batch.map((path) async {
  //       for (int j = 0; j < retry; j++) {
  //         try {
  //           final url = await supabase.storage
  //               .from('FeedImages')
  //               .createSignedUrl(path, 3600 * 3)
  //               .timeout(const Duration(milliseconds: 1000));

  //           // logger.d("✅ Signed URL 생성 성공: $path");
  //           return url;
  //         } catch (e) {
  //           logger.w("🔁 Signed URL 실패 (path: $path, 시도: ${j + 1}/$retry): $e");
  //           await Future.delayed(const Duration(milliseconds: 200));
  //         }
  //       }

  //       logger.e("❌ Signed URL 최종 실패: $path");
  //       return null;
  //     }));

  //     allResults.addAll(results);
  //   }

  //   logger.d(
  //       "🎉 Signed URL 생성 완료 (${allResults.whereType<String>().length}/${paths.length})");
  //   return allResults;
  // }

  Future<List<String>> _getSignedUrlsWithRetry(List<String> paths) async {
    // const baseUrl =
    //     'https://ccpcclfqofyvksajnrpg.supabase.co/storage/v1/object/public/FeedImages/';

    logger.d("🧵 총 ${paths.length}개의 퍼블릭 이미지 URL 생성 시작");

    final results = paths.map((path) => '$baseUrl$path').toList();

    logger.d("🎉 퍼블릭 URL 생성 완료 (${results.length}/${paths.length})");
    return results;
  }

  // Future<List<String?>> _getSignedUrlsWithRetry(List<String> paths,
  //     {int retry = 3}) async {
  //   for (int i = 0; i < retry; i++) {
  //     try {
  //       final signedUrlObjects = await supabase.storage
  //           .from('FeedImages')
  //           .createSignedUrls(paths, 3600 * 3)
  //           .timeout(const Duration(milliseconds: 1000)); // ⏱️ 타임아웃 설정

  //       return signedUrlObjects.map((e) => e.signedUrl).toList();
  //     } catch (e) {
  //       logger.w("🔁 Signed URLs 생성 실패 (시도 ${i + 1}/$retry): $e");
  //       await Future.delayed(Duration(milliseconds: 200));
  //     }
  //   }
  //   return List.filled(paths.length, null);
  // }

  Future<void> addReaction(String feedId, ReactionType reaction) async {
    // ✅ fallback 피드인지 확인
    if (feedId == fallbackFeed.id) {
      logger.w("⚠️ fallback 피드에는 리액션을 추가할 수 없습니다.");
      return;
    }

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
      _reactionFeedIds.add(feedId);
      updateMission();
    } catch (e) {
      Analytics().logEvent(
        "피드_리액션_에러",
        parameters: {"에러": e.toString()},
      );
      logger.e(e);
    }
  }

  Future<void> getMoreFeeds() async {
    if (_currentCategory == FeedCategory.all) {
      await _getFeeds(loadMore: true);
    } else {
      await _getExerciseFeeds(loadMore: true);
    }
  }

  Future<void> refreshFeeds() async {
    if (_currentCategory == FeedCategory.all) {
      await _getFeeds();
    } else {
      await _getExerciseFeeds();
    }
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

  Future<void> updateMission() async {
    await challengeCubit.updateMission();
  }

  List<Feed> get getMyFeeds => _myFeeds;
  List<Feed> get getFeeds => _feeds;
  List<List<Feed>> get getHomeFeeds => _homeFeeds;
  FeedCategory get getFeedCategory => _currentCategory;

  Iterable<Reaction> getReaction(String feedId, ReactionType reactionField) {
    final feed = _myFeeds.firstWhere((feed) => feed.id == feedId);
    return feed.reaction?.where((reaction) => reaction.type == reactionField) ??
        [];
  }
}
