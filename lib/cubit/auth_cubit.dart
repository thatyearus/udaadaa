import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/constant.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single()
          .then((res) {
        if (res.isNotEmpty) {
          final profile = Profile.fromMap(map: res);
          emit(Authenticated(profile));
        } else {
          _anonymousLogin();
        }
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

      final res = await supabase
          .from('profiles')
          .insert(profile.toMap())
          .select()
          .single();
      profile = Profile.fromMap(map: res);
      emit(Authenticated(profile));
    } catch (e) {
      logger.e(e.toString());
      emit(AuthError());
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    emit(AuthInitial());
  }
}
