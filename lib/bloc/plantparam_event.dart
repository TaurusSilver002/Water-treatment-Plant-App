part of 'plantparam_bloc.dart';

abstract class PlantparamEvent extends Equatable {
  const PlantparamEvent();
  @override
  List<Object> get props => [];
}

class FetchPlantparam extends PlantparamEvent {}

class AddPlantparam extends PlantparamEvent {
  final String parameterName;
  final String parameterUnit;
  final double targetValue;
  final double tolerance;
  const AddPlantparam({
    required this.parameterName,
    required this.parameterUnit,
    required this.targetValue,
    required this.tolerance,
  });
  @override
  List<Object> get props => [parameterName, parameterUnit, targetValue, tolerance];
}
