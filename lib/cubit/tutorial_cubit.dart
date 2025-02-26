import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'tutorial_state.dart';

class TutorialCubit extends Cubit<TutorialState> {
  TutorialCubit() : super(TutorialInitial());

  void showTutorialRoom() {
    emit(TutorialRoom());
  }

  final GlobalKey _enterRoomKey = GlobalKey();
  final GlobalKey _verifyButtonKey = GlobalKey();

  GlobalKey get enterRoomKey => _enterRoomKey;
  GlobalKey get verifyButtonKey => _verifyButtonKey;
}
