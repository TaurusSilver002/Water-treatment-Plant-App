import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {
  final Map<String, dynamic> userData;

  const LoadUser(this.userData);

  @override
  List<Object?> get props => [userData];
}

// Adding new event for fetching user data
class FetchUser extends UserEvent {
  const FetchUser();
}
