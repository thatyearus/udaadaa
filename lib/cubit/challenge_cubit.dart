import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/models/challenge.dart';
import 'package:udaadaa/utils/constant.dart';

part 'challenge_state.dart';

class ChallengeCubit extends Cubit<ChallengeState> {
  final AuthCubit authCubit;
  late final StreamSubscription authSubscription;

  ChallengeCubit(this.authCubit) : super(ChallengeInitial()) {
    final authState = authCubit.state;
    if (authState is Authenticated) {
      // 연속 참여 일 계산
    }

    authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        // 연속 참여 일 계산
      } else {
        emit(ChallengeInitial());
      }
    });
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }

  Future<void> enterChallenge() async {
    try {
      final entered = await _isEntered();
      if (!entered){
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final Challenge challenge = Challenge(
          startDay: today,
          endDay: today.add(const Duration(days: 6)),
          userId: supabase.auth.currentUser!.id,
        );
        final challengeMap = challenge.toMap();
        await supabase.from('challenge').insert(challengeMap).select().single();
        emit(ChallengeSuccess());
      }else{
        emit(ChallengeError("이미 참여 중 입니다."));
      }

    } catch (e) {
      logger.e(e);
    }
  }

  Future<bool> _isEntered() async{
    try{
      final r = await supabase.from('challenge')
      .select('id')
      .eq('user_id',supabase.auth.currentUser!.id);

      if(r.isEmpty){
        return false;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final ret = await supabase.from('challenge')
          .select('end_day')
          .lte('end_day', today)
          .eq('user_id', supabase.auth.currentUser!.id);
      if (ret.isEmpty){
        return true;
      }

    }catch (e){
      logger.e(e);
    }
    return false;
  }

}
