part of 'tutorial_cubit.dart';

@immutable
sealed class TutorialState {}

final class TutorialInitial extends TutorialState {}

final class TutorialRoom extends TutorialState {}

final class TutorialChat extends TutorialState {}

final class TutorialRoom2 extends TutorialState {}

final class TutorialProfile extends TutorialState {}

final class TutorialPush extends TutorialState {}
