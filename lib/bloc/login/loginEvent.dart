part of 'loginBloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginUserEvent extends LoginEvent {
  final String email;
  final String password;

  LoginUserEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}




class LogoutEvent extends LoginEvent {}


