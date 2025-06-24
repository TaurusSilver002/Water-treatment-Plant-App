part of 'plantequip_bloc.dart';

abstract class PlantequipEvent extends Equatable {
  const PlantequipEvent();
  @override
  List<Object> get props => [];
}

class FetchPlantequip extends PlantequipEvent {}
