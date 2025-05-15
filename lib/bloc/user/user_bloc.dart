import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:watershooters/models/user.dart';
import 'package:watershooters/config.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUser>((event, emit) async {
      final user = UserModel.fromJson(event.userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('role_id', user.roleId);

      emit(UserLoaded(user));
    });
    
    on<FetchUser>((event, emit) async {
      emit(UserLoading());
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        if (token == null) {
          emit(UserError('No authentication token found'));
          return;
        }
        
        final dio = Dio();
        final response = await dio.get(
          AppConfig.userlink,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        if (response.statusCode == 200) {
          final user = UserModel.fromJson(response.data);
          
          // Save role_id for potential use elsewhere
          await prefs.setInt('role_id', user.roleId);
          
          emit(UserLoaded(user));
        } else {
          emit(UserError('Failed to load user data'));
        }
      } catch (e) {
        emit(UserError('Error: ${e.toString()}'));
      }
    });
  }
}
