import 'package:bloc/bloc.dart';
import 'package:udaadaa/service/shared_preferences.dart';

part 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(BottomNavState.home) {
    // final isTutorialFinished =
    //     PreferencesService().getBool('isTutorialFinished');
    // if (isTutorialFinished == null || !isTutorialFinished) {
    //   emit(BottomNavState.register);
    // }
  }

  void selectTab(BottomNavState tab) {
    emit(tab);
  }
}
