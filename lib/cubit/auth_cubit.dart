import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/utils/constant.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      emit(Authenticated(currentUser.id));
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
      emit(Authenticated(response.user!.id));
    } catch (e) {
      logger.e(e.toString());
      emit(AuthError());
    }
  }
}
