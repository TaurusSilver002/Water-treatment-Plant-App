import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/equiplog.dart';

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
      await repository.addEquipmentLog(event.log);
      // After successful add, reload from backend
      add(FetchEquipment());
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