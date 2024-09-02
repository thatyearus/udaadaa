import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthCubit authCubit;
  late final StreamSubscription authSubscription;

  ProfileCubit(this.authCubit) : super(ProfileInitial()) {
    final authState = authCubit.state;
    if (authState is Authenticated) {
      emit(ProfileLoaded(authState.user));
    }

    authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        emit(ProfileLoaded(authState.user));
      } else {
        emit(ProfileInitial());
      }
    });
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }
}
