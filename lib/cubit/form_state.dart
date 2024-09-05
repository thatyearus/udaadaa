part of 'form_cubit.dart';

@immutable
sealed class FormState {}

final class FormInitial extends FormState {}

final class FormError extends FormState {
  final String error;

  FormError(this.error);
}

final class FormLoading extends FormState {}

final class FormSuccess extends FormState {}
