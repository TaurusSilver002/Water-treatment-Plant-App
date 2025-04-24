import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterplant/models/auth.dart';


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
      await prefs.setString('access_token', accessToken);
      emit(LoginSuccessState(token: accessToken));
    } else {
      emit(const LoginFailureState(message: 'Login failed, please try again.'));
    }
  } catch (e) {
    emit(LoginFailureState(message: 'An error occurred: ${e.toString()}'));
  }
}
//logout
 Future<void> _onLogout(LogoutEvent event, Emitter<LoginState> emit) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token'); 
      emit(LoginInitialState());
    } catch (e) {
      emit(LoginFailureState(message: 'Logout failed: ${e.toString()}'));
    }
  }
  //forgotpass


}