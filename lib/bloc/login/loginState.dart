part of 'loginBloc.dart';


abstract class LoginState extends Equatable{
  const LoginState();
  @override 
  List<Object?> get props =>[];
}
class LoginInitialState extends LoginState {}
class LoginLoadingState extends LoginState {}
class LoginSuccessState extends LoginState {
  final String token;
  const LoginSuccessState({required this.token});
  @override
  List<Object?> get props => [token];
}
class LoginFailureState extends LoginState {
  final String message;
  const LoginFailureState({required this.message});
  @override
  List<Object?> get props => [message];
}


//forgotpass
class ForgotPasswordLoadingState extends LoginState {}

class ForgotPasswordSuccessState extends LoginState {}

class ForgotPasswordFailureState extends LoginState {
  final String message;
  const ForgotPasswordFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}

//confirm pass
class ConfirmPasswordLoadingState extends LoginState {}

class ConfirmPasswordSuccessState extends LoginState {}

class ConfirmPasswordFailureState extends LoginState {
  final String message;
  const ConfirmPasswordFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}

//verify
class VerifyUserLoadingState extends LoginState {}

class VerifyUserSuccessState extends LoginState {}

class VerifyUserFailureState extends LoginState {
  final String message;
  const VerifyUserFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
class LogoutSuccessState extends LoginState {}
