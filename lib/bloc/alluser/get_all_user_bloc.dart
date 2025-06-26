import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
part 'get_all_user_event.dart';
part 'get_all_user_state.dart';

class GetAllUserBloc extends Bloc<GetAllUserEvent, GetAllUserState> {
  final Dio dio;

  GetAllUserBloc(this.dio) : super(GetAllUserInitial()) {
    on<FetchUsersByRole>(_onFetchUsersByRole);
  }

  Future<void> _onFetchUsersByRole(
    FetchUsersByRole event,
    Emitter<GetAllUserState> emit,
  ) async {
    emit(GetAllUserLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(const GetAllUserError('No authentication token found'));
        return;
      }

      final response = await dio.post(
        AppConfig.get,
        data: {'role_id': event.roleId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        emit(GetAllUserLoaded(response.data));
      } else {
        emit(GetAllUserError('Failed to fetch users: ${response.statusCode}'));
      }
    } catch (e) {
      emit(GetAllUserError('Network error: ${e.toString()}'));
    }
  }
}
