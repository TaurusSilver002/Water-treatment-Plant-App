part of 'plant_bloc.dart';

abstract class PlantEvent extends Equatable {
  const PlantEvent();

  @override
  List<Object> get props => [];
}

class FetchPlantsByType extends PlantEvent {
  final int plantTypeId;

  const FetchPlantsByType(this.plantTypeId);

  @override
  List<Object> get props => [plantTypeId];
}


