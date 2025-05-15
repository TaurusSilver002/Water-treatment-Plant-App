import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/models/plant_type.dart'; // Contains PlantRepo

part 'plant_event.dart';
part 'plant_state.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final PlantRepo plantRepo;

  PlantBloc({required this.plantRepo}) : super(PlantInitial()) {
    on<FetchPlantsByType>(_onFetchPlantsByType);
  }

 Future<void> _onFetchPlantsByType(
  FetchPlantsByType event,
  Emitter<PlantState> emit,
) async {
  emit(PlantLoading());
  try {
    final allPlants = await plantRepo.fetchAllPlants();
    final filtered = allPlants
        .where((plant) => plant['plant_type_id'] == event.plantTypeId)
        .toList();
    emit(PlantLoaded(filtered));
  } catch (e) {
    emit(PlantError('Error filtering plant data: ${e.toString()}'));
  }
}

}
