import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:waterplant/models/equiplog.dart';

part 'equipmentlog_event.dart';
part 'equipmentlog_state.dart';

class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  final EquipmentRepository repository;

  EquipmentBloc({required this.repository}) : super(EquipmentInitial()) {
    on<FetchEquipment>(_onFetchEquipment);
    on<AddEquipmentLog>(_onAddEquipmentLog);
  }

  Future<void> _onFetchEquipment(
      FetchEquipment event, Emitter<EquipmentState> emit) async {
    emit(EquipmentLoading());
    try {
      final equipmentData = await repository.fetchEquipmentData();
      emit(EquipmentLoaded(equipmentData));
    } catch (e) {
      emit(EquipmentError(e.toString()));
    }
  }

  Future<void> _onAddEquipmentLog(
      AddEquipmentLog event, Emitter<EquipmentState> emit) async {
    try {
      final currentState = state;
      final newLog = await repository.addEquipmentLog(event.log);
      if (currentState is EquipmentLoaded) {
        final updatedLogs = List<dynamic>.from(currentState.equipmentData['logs'] ?? [])
          ..add(newLog);
        emit(EquipmentLoaded({
          'logs': updatedLogs,
        }));
      } else {
        emit(EquipmentLoaded({'logs': [newLog]}));
      }
    } catch (e) {
      emit(EquipmentError('Failed to add equipment log: $e'));
    }
  }

  @override
  Future<void> close() {
    repository.dio.close();
    return super.close();
  }
}