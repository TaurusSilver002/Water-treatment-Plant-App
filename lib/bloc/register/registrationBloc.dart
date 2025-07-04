import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/auth.dart';

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
      String? result = await _authRepo.registerUser(
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

      if (result != null) {
        if (result.startsWith("SUCCESS:")) {
          String token = result.substring(8); // Remove "SUCCESS:" prefix
          emit(RegistrationSuccessState(token: token));
        } else if (result.startsWith("ERROR:")) {
          String errorMessage = result.substring(6); // Remove "ERROR:" prefix
          emit(RegistrationFailedState(message: errorMessage));
        } else {
          emit(RegistrationFailedState(message: 'Invalid response format'));
        }
      } else {
        emit(RegistrationFailedState(message: 'Registration failed'));
      }
    } catch (e) {
      emit(RegistrationFailedState(message: 'An error occurred: ${e.toString()}'));
    }
  }
}
