import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/constant.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  Profile? _profile;
  bool _isChallenger = false;
  bool _wasChallenger = false;
  bool _isAuthenticating = false;

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
    supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        try {
          final provider = data.session?.user.appMetadata['provider'];
          if (provider == 'kakao' || provider == 'apple') {
            try {
              final existing = await supabase
                  .from('profiles')
                  .select()
                  .eq('id', supabase.auth.currentUser!.id)
                  .maybeSingle();

              if (existing != null) {
                _profile = Profile.fromMap(map: existing);
                emit(Authenticated(_profile!));
              } else {
                makeProfile();
              }
            } catch (e) {
              emit(AuthError());
              logger.e('Error getting profile: ${e.toString()}');
            }
          } else {
            makeProfile();
          }
        } catch (e) {
          logger.e('Error logging sign-in details: ${e.toString()}');
        }
      } else if (data.event == AuthChangeEvent.signedOut) {
        emit(AuthInitial());
      }
    }, onError: (error) {
      logger.e(error.toString());
      emit(AuthError());
    });
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
        pushOption: true,
      );

      bool insertSuccess = false;
      int retryCount = 0;
      const maxRetries = 3; // 원하는 만큼 재시도 횟수를 설정

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
          FirebaseMessaging.instance.onTokenRefresh.listen((token) {
            _updateFCMToken(token, profile);
          });
        } catch (error) {
          logger.d("error: $error");
          // UNIQUE 제약 조건 위반 시 새로운 닉네임을 생성하고 다시 시도
          if (error is PostgrestException && error.code == '23505') {
            //먼저 있나 확인
            final existing = await supabase
                .from('profiles')
                .select()
                .eq('id', response.user!.id)
                .maybeSingle();

            if (existing != null) {
              Profile profile = Profile.fromMap(map: existing);
              _profile = profile;
              emit(Authenticated(profile));
              logger.d("중복 찾았음 그걸로 들어감");
              return;
            }
            // 23505는 PostgreSQL에서 고유 제약 조건 위반에 대한 에러 코드입니다.
            logger.d("Nickname ${profile.nickname} already exists");
            logger.d("id ${profile.id} already exists");
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

  Future<void> setFCMToken() async {
    if (_profile == null) {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User is not authenticated');
      }
      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();
      Profile profile = Profile.fromMap(map: res);
      _profile = profile;
    }
    await _setFCMToken(_profile!);
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
      profile = profile.copyWith(pushOption: false);
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
      if (_profile?.pushOption == false) {
        await _setFCMToken(_profile!.copyWith(pushOption: true));
      } else {
        await turnOffPush(_profile!);
      }
      emit(Authenticated(_profile!));
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void setIsChallenger(bool newValue) {
    _isChallenger = newValue;
  }

  void setWasChallenger(bool newValue) {
    _wasChallenger = newValue;
  }

  // Future<int> linkEmail(String email, String password) async {
  //   try {
  //     await supabase.auth
  //         .updateUser(UserAttributes(email: email, password: password));
  //     return 1;
  //   } catch (e) {
  //     logger.e(e.toString());
  //     if (e is AuthException) {
  //       if (e.code == 'weak_password' && e.statusCode == '422') {
  //         return 4;
  //       } else if (e.code == 'email_exists' && e.statusCode == '422') {
  //         return 5;
  //       } else if (e.code == 'validation_failed' && e.statusCode == '400') {
  //         return 6;
  //       }
  //       return 0;
  //     }
  //     return 0;
  //   }
  // }

  // Future<int> signInWithEmail(String email, String password) async {
  //   try {
  //     await supabase.auth.signInWithPassword(email: email, password: password);
  //     final currentUser = supabase.auth.currentUser;
  //     logger.d("currentUser: $currentUser");
  //     if (_profile != null || _profile!.id != currentUser!.id) {
  //       final res = await supabase
  //           .from('profiles')
  //           .select()
  //           .eq('id', currentUser!.id)
  //           .single();
  //       Profile profile = Profile.fromMap(map: res);
  //       _profile = profile;
  //     }
  //     emit(Authenticated(_profile!));
  //     return 3;
  //   } catch (e) {
  //     logger.e(e.toString());
  //     if (e is AuthException) {
  //       if (e.code == 'validation_failed' && e.statusCode == '400') {
  //         return 7;
  //       } else if (e.code == 'invalid_credentials' && e.statusCode == '400') {
  //         return 8;
  //       }
  //       return 2;
  //     }
  //     return 2;
  //   }
  // }

  Future<AuthResponse> signInWithApple() async {
    _isAuthenticating = true;
    final rawNonce = supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
          'Could not find ID Token from generated credential');
    }
    return supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  // Future<bool> signInWithAppleAndroid() async {
  //   return supabase.auth.signInWithOAuth(
  //     OAuthProvider.apple,
  //     redirectTo: redirectUrl,
  //     authScreenLaunchMode:
  //         kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
  //   );
  // }

  Future<void> signInWithKakao() async {
    _isAuthenticating = true;
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: redirectUrl,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> makeProfile() async {
    if (_profile?.id == supabase.auth.currentUser!.id) {
      return;
    }
    Profile profile = Profile(
      id: supabase.auth.currentUser!.id,
      nickname: RandomNicknameGenerator.generateNickname(),
      pushOption: true,
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
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          _updateFCMToken(token, profile);
        });
      } catch (error) {
        // UNIQUE 제약 조건 위반 시 새로운 닉네임을 생성하고 다시 시도
        // 이게 핵심
        final existing = await supabase
            .from('profiles')
            .select()
            .eq('id', supabase.auth.currentUser!.id)
            .maybeSingle();

        if (existing != null) {
          _profile = Profile.fromMap(map: existing);
          emit(Authenticated(_profile!));
          return;
        }
        if (error is PostgrestException && error.code == '23505') {
          // 23505는 PostgreSQL에서 고유 제약 조건 위반에 대한 에러 코드입니다.
          logger.d("Nickname ${profile.nickname} already exists");
          logger.d("id ${profile.id} already exists");
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
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    emit(AuthInitial());
  }

  String getChallengeStatus() {
    try {
      // Check challenge status and return appropriate string
      if (_isChallenger) {
        return 'isChallenger';
      } else if (!_isChallenger && _wasChallenger) {
        return 'wasChallenger';
      } else {
        return 'noChallenger';
      }
    } catch (e) {
      // Log error for debugging purposes
      logger.e('Error determining challenge status: ${e.toString()}');
      return 'noChallenger'; // Default fallback value
    }
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
    return getCurProfile?.pushOption == true && getCurProfile?.fcmToken != null;
  }

  bool get getIsChallenger => _isChallenger;
  bool get wasChallenger => _wasChallenger;

  set setIsAuthenticating(bool value) {
    _isAuthenticating = value;
  }

  bool get getIsAuthenticating => _isAuthenticating;
}
