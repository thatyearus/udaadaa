import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  List<Feed> _myFeeds = [];

  FeedCubit() : super(FeedInitial()) {
    _getFeeds();
    _getMyFeeds();
  }

  Future<void> _getFeeds() async {
    try {
      final data = await supabase.from('feed').select();
      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();
      logger.d(imagePaths);
      final signedUrls = await supabase.storage
          .from('FeedImages')
          .createSignedUrls(imagePaths, 3600);

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      } else {
        List<Feed> feeds = [];
        logger.d(data.length);
        logger.d(signedUrls.length);
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i].signedUrl;
          feeds.add(Feed.fromMap(map: item));
        }
        logger.d(feeds);
        emit(FeedLoaded(feeds));
      }
    } catch (e) {
      logger.e(e);
      emit(FeedError());
    }
  }

  Future<void> _getMyFeeds() async {
    try {
      final data = await supabase
          .from('feed')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      final imagePaths =
          data.map((item) => item['image_path'] as String).toList();
      logger.d(imagePaths);
      final signedUrls = await supabase.storage
          .from('FeedImages')
          .createSignedUrls(imagePaths, 3600);

      if (data.isEmpty) {
        logger.e("No data");
        throw "No data";
      } else {
        _myFeeds = [];
        logger.d(data.length);
        logger.d(signedUrls.length);
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          item['image_url'] = signedUrls[i].signedUrl;
          _myFeeds.add(Feed.fromMap(map: item));
        }
      }
    } catch (e) {
      logger.e(e);
    }
  }

  List<Feed> get getMyFeeds => _myFeeds;
}
