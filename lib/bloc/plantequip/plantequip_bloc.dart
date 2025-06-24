import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/plantequip_repository.dart';

part 'plantequip_event.dart';
part 'plantequip_state.dart';

class PlantequipBloc extends Bloc<PlantequipEvent, PlantequipState> {
  final PlantEquipRepository repository;

  PlantequipBloc({required this.repository}) : super(PlantequipInitial()) {
    on<FetchPlantequip>(_onFetchPlantequip);
  }

  Future<void> _onFetchPlantequip(
      FetchPlantequip event, Emitter<PlantequipState> emit) async {
    emit(PlantequipLoading());
    try {
      final equipList = await repository.fetchPlantEquipments();
      emit(PlantequipLoaded(equipList));
    } catch (e) {
      emit(PlantequipError(e.toString()));
    }
  }
}
