part of 'registrationBloc.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitialState extends RegistrationState {}

class RegistrationLoadingState extends RegistrationState {}

class RegistrationSuccessState extends RegistrationState {
  final String token;
  const RegistrationSuccessState({required this.token});

  @override
  List<Object?> get props => [token];
}

class RegistrationFailedState extends RegistrationState {
  final String message;
  const RegistrationFailedState({required this.message});

  @override
  List<Object?> get props => [message];
}
