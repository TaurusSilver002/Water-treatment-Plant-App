import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterplant/models/plant_type.dart';
import 'package:waterplant/bloc/createplant/createplant_event.dart';
import 'package:waterplant/bloc/createplant/createplant_state.dart';

abstract class PlantCreateEvent extends Equatable {
  const PlantCreateEvent();
  
  @override
  List<Object?> get props => [];
}

class SubmitPlant extends PlantCreateEvent {
  final PlantModel plant;

  const SubmitPlant(this.plant);

  @override
  List<Object?> get props => [plant];
}

class PlantCreateBloc extends Bloc<PlantCreateEvent, PlantCreateState> {
  final PlantRepository repository;

  PlantCreateBloc(this.repository) : super(PlantCreateInitial()) {
    on<SubmitPlant>((event, emit) async {
      emit(PlantCreateLoading());
      try {
        final success = await repository.postPlant(event.plant);
        if (success) {
          emit(PlantCreateSuccess());
        } else {
          emit(PlantCreateFailure('Failed to post plant.'));
        }
      } catch (e) {
        emit(PlantCreateFailure(e.toString()));
      }
    });
  }
}
