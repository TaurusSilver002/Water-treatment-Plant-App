import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/models/plant_type.dart';

part 'type_event.dart';
part 'type_state.dart';

class TypeBloc extends Bloc<TypeEvent, TypeState> {
  final Dio _dio = Dio();

  TypeBloc() : super(TypeInitial()) {
    on<FetchPlantTypes>(_onFetchPlantTypes);
  }

  Future<void> _onFetchPlantTypes(
    FetchPlantTypes event,
    Emitter<TypeState> emit,
  ) async {
    try {
      emit(TypeLoading());
      
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        emit(const TypeError('No authentication token found'));
        return;
      }

      // Make API call with token
      final response = await _dio.get(
        AppConfig.typelink,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final types = data.map((json) => PlantType.fromJson(json)).toList();
        emit(TypeLoaded(types));
      } else {
        emit(TypeError('Failed to load plant types: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TypeError('Error loading plant types: ${e.toString()}'));
    }
  }
}
