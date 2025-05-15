import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:watershooters/bloc/user/user_bloc.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/models/auth.dart';
import 'package:watershooters/models/plant_type.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<Dio>(() {
    Dio dio = Dio();
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add interceptor for logging in debug mode
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) async {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          // Handle timeout errors
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: 'Connection timed out. Please check your internet connection.',
            ),
          );
        }
        return handler.next(e);
      },
    ));
    
    return dio;
  });

  locator.registerLazySingleton<AuthRepo>(() => AuthRepo(locator<Dio>()));
  locator.registerLazySingleton<PlantRepo>(() => PlantRepo(locator<Dio>()));
  locator.registerFactory<UserBloc>(() => UserBloc());
}
