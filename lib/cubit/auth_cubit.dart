import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/utils/constant.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _anonymousLogin();
  }

  Future<void> _anonymousLogin() async {
    try {
      await supabase.auth.signInAnonymously().then((value) {
        logger.d(value);
      });
      emit(Authenticated("Anonymous"));
    } catch (e) {
      logger.e(e.toString());
      emit(AuthError());
    }
  }
}
