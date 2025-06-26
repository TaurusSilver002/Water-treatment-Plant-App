part of 'get_all_user_bloc.dart';

abstract class GetAllUserEvent extends Equatable {
  const GetAllUserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUsersByRole extends GetAllUserEvent {
  final int roleId;
  const FetchUsersByRole(this.roleId);

  @override
  List<Object?> get props => [roleId];
}
