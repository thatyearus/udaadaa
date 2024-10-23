import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/constant.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  Profile? _profile;

  AuthCubit() : super(AuthInitial()) {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single()
          .then((res) {
        final profile = Profile.fromMap(map: res);
        _profile = profile;
        emit(Authenticated(profile));
        _setFCMToken(profile);
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          _updateFCMToken(token, profile);
        });
      }).onError((error, stackTrace) {
        logger.e(error.toString());
        emit(AuthError());
        _anonymousLogin();
      });
    } else {
      _anonymousLogin();
    }
  }

  Future<void> _anonymousLogin() async {
    try {
      final response = await supabase.auth.signInAnonymously();
      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      Profile profile = Profile(
        id: response.user!.id,
        nickname: RandomNicknameGenerator.generateNickname(),
      );

      bool insertSuccess = false;
      int retryCount = 0;
      const maxRetries = 5; // 원하는 만큼 재시도 횟수를 설정

      while (!insertSuccess && retryCount < maxRetries) {
        try {
          final res = await supabase
              .from('profiles')
              .insert(profile.toMap())
              .select()
              .single();

          profile = Profile.fromMap(map: res);
          _profile = profile;
          emit(Authenticated(profile));
          insertSuccess = true; // 성공적으로 삽입된 경우 루프를 탈출
          _setFCMToken(profile);
          FirebaseMessaging.instance.onTokenRefresh.listen((token) {
            _updateFCMToken(token, profile);
          });
        } catch (error) {
          // UNIQUE 제약 조건 위반 시 새로운 닉네임을 생성하고 다시 시도
          if (error is PostgrestException && error.code == '23505') {
            // 23505는 PostgreSQL에서 고유 제약 조건 위반에 대한 에러 코드입니다.
            logger.d("Nickname ${profile.nickname} already exists");
            profile = profile.copyWith(
              nickname: RandomNicknameGenerator.generateNickname(),
            );
            _profile = profile;
            retryCount++;
          } else {
            // 다른 오류에 대한 처리
            logger.e(error.toString());
            break; // 반복을 중지하고 에러 처리를 할 수 있습니다.
          }
        }
      }

      if (!insertSuccess) {
        // 최종적으로 실패한 경우에 대한 처리 (예: 에러 메시지 표시)
        logger.e('Failed to insert profile');
        emit(AuthError());
        // 필요에 따라 추가 처리 (예: 사용자에게 알림, 다른 로직 시도 등)
      }
    } catch (e) {
      logger.e(e.toString());
      emit(AuthError());
    }
  }

  Future<void> _setFCMToken(Profile profile) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User is not authenticated');
      }

      await FirebaseMessaging.instance.requestPermission();

      await FirebaseMessaging.instance.getAPNSToken();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }
      _updateFCMToken(fcmToken, profile);
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> _updateFCMToken(String token, Profile profile) async {
    try {
      profile = profile.copyWith(fcmToken: token);
      _profile = profile;
      await supabase.from('profiles').upsert(profile.toMap());
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> updateNickname(String nickname) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User is not authenticated');
      }
      final res = await supabase
          .from('profiles')
          .update({'nickname': nickname})
          .eq('id', currentUser.id)
          .select()
          .single();
      Profile profile = Profile.fromMap(map: res);
      _profile = profile;
      emit(Authenticated(profile));
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> turnOffPush(Profile profile) async {
    try {
      profile = profile.copyWith(fcmToken: "");
      _profile = profile;
      await supabase.from('profiles').upsert(profile.toMap());
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> togglePush() async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User is not authenticated');
      }
      if (_profile == null) {
      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();
      Profile profile = Profile.fromMap(map: res);
        _profile = profile;
      }
      if (_profile?.fcmToken == null) {
        await _setFCMToken(_profile!);
      } else {
        await turnOffPush(_profile!);
      }
      emit(Authenticated(_profile!));
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    emit(AuthInitial());
  }

  Profile? get getProfile {
    if (state is Authenticated) {
      return (state as Authenticated).user;
    }
    return null;
  }

  Profile? get getCurProfile => _profile;

  bool? get getPushOption {
    logger.d("${getCurProfile?.fcmToken}");
    logger.d("getPushOption: ${getCurProfile?.fcmToken != null}");
    return getCurProfile?.fcmToken != null;
  }
}
