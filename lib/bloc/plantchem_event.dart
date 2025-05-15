part of 'plantchem_bloc.dart';

abstract class PlantchemEvent extends Equatable {
  const PlantchemEvent();
  @override
  List<Object> get props => [];
}

class FetchPlantchem extends PlantchemEvent {}

class AddPlantchem extends PlantchemEvent {
  final String chemicalName;
  final double quantity;
  final String chemicalUnit;
  const AddPlantchem({required this.chemicalName, required this.quantity, required this.chemicalUnit});
  @override
  List<Object> get props => [chemicalName, quantity, chemicalUnit];
}
