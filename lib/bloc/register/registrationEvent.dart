part of 'registrationBloc.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class RegistrationCreateUserEvent extends RegistrationEvent {
  final String email;
  final String password;
  final String firstname;
  final String lastname;
  final String aadharNumber;
  final String phoneNumber;
  final String address;
  final String dateOfBirth;
  final String qualification;
  final int roleId;
  final String? operatorId;

  RegistrationCreateUserEvent({
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.aadharNumber,
    required this.phoneNumber,
    required this.address,
    required this.dateOfBirth,
    required this.qualification,
    required this.roleId,
    this.operatorId,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    firstname,
    lastname,
    aadharNumber,
    phoneNumber,
    address,
    dateOfBirth,
    qualification,
    roleId,
    operatorId,
  ];
}
