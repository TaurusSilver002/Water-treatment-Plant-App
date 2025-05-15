import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/plantchem_repository.dart';

part 'plantchem_event.dart';
part 'plantchem_state.dart';

class PlantchemBloc extends Bloc<PlantchemEvent, PlantchemState> {
  final PlantChemRepository repository;

  PlantchemBloc({required this.repository}) : super(PlantchemInitial()) {
    on<FetchPlantchem>(_onFetchPlantchem);
    on<AddPlantchem>(_onAddPlantchem);
  }

  Future<void> _onFetchPlantchem(
      FetchPlantchem event, Emitter<PlantchemState> emit) async {
    emit(PlantchemLoading());
    try {
      final chemList = await repository.fetchPlantChemicals();
      emit(PlantchemLoaded(chemList));
    } catch (e) {
      emit(PlantchemError(e.toString()));
    }
  }

  Future<void> _onAddPlantchem(
      AddPlantchem event, Emitter<PlantchemState> emit) async {
    try {
      await repository.addPlantChem(
        chemicalName: event.chemicalName,
        quantity: event.quantity,
        chemicalUnit: event.chemicalUnit,
      );
      add(FetchPlantchem());
    } catch (e) {
      emit(PlantchemError('Failed to add plant chemical: $e'));
    }
  }
}
