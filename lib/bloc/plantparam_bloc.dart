import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/plantparam_repository.dart';

part 'plantparam_event.dart';
part 'plantparam_state.dart';

class PlantparamBloc extends Bloc<PlantparamEvent, PlantparamState> {
  final PlantParamRepository repository;

  PlantparamBloc({required this.repository}) : super(PlantparamInitial()) {
    on<FetchPlantparam>(_onFetchPlantparam);
    on<AddPlantparam>(_onAddPlantparam);
  }

  Future<void> _onFetchPlantparam(
      FetchPlantparam event, Emitter<PlantparamState> emit) async {
    emit(PlantparamLoading());
    try {
      final paramList = await repository.fetchPlantParams();
      emit(PlantparamLoaded(paramList));
    } catch (e) {
      emit(PlantparamError(e.toString()));
    }
  }

  Future<void> _onAddPlantparam(
      AddPlantparam event, Emitter<PlantparamState> emit) async {
    try {
      await repository.addPlantParam(
        parameterName: event.parameterName,
        parameterUnit: event.parameterUnit,
        targetValue: event.targetValue,
        tolerance: event.tolerance,
      );
      add(FetchPlantparam());
    } catch (e) {
      emit(PlantparamError('Failed to add plant parameter: $e'));
    }
  }
}
