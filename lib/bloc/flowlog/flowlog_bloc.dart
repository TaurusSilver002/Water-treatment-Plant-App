import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/flowlog.dart';

part 'flowlog_event.dart';
part 'flowlog_state.dart';

class FlowlogBloc extends Bloc<FlowlogEvent, FlowlogState> {
  final FlowLogRepository repository;

  FlowlogBloc({required this.repository}) : super(FlowlogInitial()) {
    on<FetchFlowlog>(_onFetchFlowlog);
    on<AddFlowlog>(_onAddFlowlog);
  }

  Future<void> _onFetchFlowlog(
      FetchFlowlog event, Emitter<FlowlogState> emit) async {
    emit(FlowlogLoading());
    try {
      final flowlogData = await repository.fetchFlowLogData();
      emit(FlowlogLoaded(flowlogData));
    } catch (e) {
      emit(FlowlogError(e.toString()));
    }
  }

  Future<void> _onAddFlowlog(
      AddFlowlog event, Emitter<FlowlogState> emit) async {
    try {
      final currentState = state;
      // Directly send the dynamic map to the repository (no string conversion)
      final newLog = await repository.addFlowLog(event.log);
      if (currentState is FlowlogLoaded) {
        final updatedLogs = List<dynamic>.from(currentState.flowlogData['logs'] ?? [])
          ..add(newLog);
        emit(FlowlogLoaded({
          'logs': updatedLogs,
        }));
      } else {
        emit(FlowlogLoaded({'logs': [newLog]}));
      }
    } catch (e) {
      emit(FlowlogError('Failed to add flow log: $e'));
    }
  }

  @override
  Future<void> close() {
    repository.dio.close();
    return super.close();
  }
}
