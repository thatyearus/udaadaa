import 'package:bloc/bloc.dart';
import 'package:udaadaa/service/shared_preferences.dart';

part 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(BottomNavState.home) {
    final isOnboardingComplete =
        PreferencesService().getBool('isOnboardingComplete');
    if (isOnboardingComplete == null || !isOnboardingComplete) {
      emit(BottomNavState.register);
    }
  }

  void selectTab(BottomNavState tab) {
    emit(tab);
  }
}
