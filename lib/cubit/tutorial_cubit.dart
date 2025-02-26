import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'tutorial_state.dart';

class TutorialCubit extends Cubit<TutorialState> {
  TutorialCubit() : super(TutorialInitial());

  void showTutorialRoom() {
    emit(TutorialRoom());
  }

  void showTutorialChat() {
    emit(TutorialChat());
  }

  final GlobalKey _enterRoomKey = GlobalKey();
  final GlobalKey _verifyButtonKey = GlobalKey();
  final GlobalKey _chatRoomKey = GlobalKey();

  GlobalKey get enterRoomKey => _enterRoomKey;
  GlobalKey get chatRoomKey => _chatRoomKey;
  GlobalKey get verifyButtonKey => _verifyButtonKey;
}
