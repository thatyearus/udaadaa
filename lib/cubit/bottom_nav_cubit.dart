import 'package:bloc/bloc.dart';

part 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(BottomNavState.home);

  void selectTab(BottomNavState tab) {
    emit(tab);
  }
}
