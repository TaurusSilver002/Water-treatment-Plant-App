import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:waterplant/models/auth.dart';

part 'registrationEvent.dart';
part 'registrationState.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AuthRepo _authRepo; 

  RegistrationBloc(this._authRepo) : super(RegistrationInitialState()) {
    on<RegistrationCreateUserEvent>(_onCreateUser);
  }

  Future<void> _onCreateUser(
      RegistrationCreateUserEvent event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoadingState());

    try {
      String? errorMessage = await _authRepo.registerUser(
        email: event.email,
        password: event.password,
        firstname: event.firstname,
        lastname: event.lastname,
        aadharNumber: event.aadharNumber,
        phoneNumber: event.phoneNumber,
        address: event.address,
        dateOfBirth: event.dateOfBirth,
        qualification: event.qualification,
        roleId: event.roleId,
      );

      if (errorMessage == null) {
        emit(RegistrationSuccessState());
      } else {
        emit(RegistrationFailedState(message: errorMessage));
      }
    } catch (e) {
      emit(RegistrationFailedState(message: 'An error occurred: ${e.toString()}'));
    }
  }
}
