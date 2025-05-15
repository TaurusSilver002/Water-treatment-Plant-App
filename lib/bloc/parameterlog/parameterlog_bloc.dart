import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/parameterlog.dart';

part 'parameterlog_event.dart';
part 'parameterlog_state.dart';

class ParameterlogBloc extends Bloc<ParameterlogEvent, ParameterlogState> {
  final ParameterLogRepository repository;

  ParameterlogBloc({required this.repository}) : super(ParameterlogInitial()) {
    on<FetchParameterlog>(_onFetchParameterlog);
    on<AddParameterlog>(_onAddParameterlog);
  }

  Future<void> _onFetchParameterlog(
      FetchParameterlog event, Emitter<ParameterlogState> emit) async {
    emit(ParameterlogLoading());
    try {
      final parameterlogData = await repository.fetchParameterLogData();
      emit(ParameterlogLoaded(parameterlogData));
    } catch (e) {
      emit(ParameterlogError(e.toString()));
    }
  }

  Future<void> _onAddParameterlog(
      AddParameterlog event, Emitter<ParameterlogState> emit) async {
    try {
      final currentState = state;
      final newLog = await repository.addParameterLog(event.log);
      if (currentState is ParameterlogLoaded) {
        final updatedLogs = List<dynamic>.from(currentState.parameterlogData['logs'] ?? [])
          ..add(newLog);
        emit(ParameterlogLoaded({
          'logs': updatedLogs,
        }));
      } else {
        emit(ParameterlogLoaded({'logs': [newLog]}));
      }
    } catch (e) {
      emit(ParameterlogError('Failed to add parameter log: $e'));
    }
  }

  @override
  Future<void> close() {
    repository.dio.close();
    return super.close();
  }
}
