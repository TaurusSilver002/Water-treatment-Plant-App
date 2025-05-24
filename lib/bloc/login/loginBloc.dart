import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/models/auth.dart';


part 'loginEvent.dart';
part 'loginState.dart';

class LoginBloc extends Bloc<LoginEvent,LoginState>{
  final AuthRepo _authRepo;
  LoginBloc(this._authRepo):super(LoginInitialState()){
    on<LoginUserEvent>(_onlogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onlogin(LoginUserEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoadingState());
    try {
      String? accessToken = await _authRepo.loginUser(email: event.email, password: event.password);

      if (accessToken != null && accessToken.isNotEmpty) {
        print("Access Token: $accessToken");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', accessToken); // Changed to 'token' for consistency
        emit(LoginSuccessState(token: accessToken));
      } else {
        emit(const LoginFailureState(message: 'Login failed, please try again.'));
      }
    } catch (e) {
      emit(LoginFailureState(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState()); // Show loading state while logging out
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role_id'); 
      await prefs.remove('plant_id');
      emit(LogoutSuccessState());
    } catch (e) {
      emit(LoginFailureState(message: 'Logout failed: ${e.toString()}'));
    }
  }
  //forgotpass


}