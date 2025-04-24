
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/models/auth.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<Dio>(() {
    Dio dio = Dio();
    dio.options.baseUrl =AppConfig.baseUrl;
    return dio;
  });

  locator.registerLazySingleton<AuthRepo>(() => AuthRepo(locator<Dio>()));
}
