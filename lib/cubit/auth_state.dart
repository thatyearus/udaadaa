part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class Authenticated extends AuthState {
  final Profile user;

  Authenticated(this.user);
}

final class AuthError extends AuthState {}

final class AuthKakaoLoginSuccess extends AuthState {
  final Profile user;

  AuthKakaoLoginSuccess(this.user);
}
