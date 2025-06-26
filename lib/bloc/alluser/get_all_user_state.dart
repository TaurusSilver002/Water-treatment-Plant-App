
part of'get_all_user_bloc.dart';
abstract class GetAllUserState extends Equatable {
  const GetAllUserState();

  @override
  List<Object?> get props => [];
}

class GetAllUserInitial extends GetAllUserState {}



class GetAllUserLoading extends GetAllUserState {}

class GetAllUserLoaded extends GetAllUserState {
  final List<dynamic> users;
  const GetAllUserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class GetAllUserError extends GetAllUserState {
  final String message;
  const GetAllUserError(this.message);

  @override
  List<Object?> get props => [message];
}
