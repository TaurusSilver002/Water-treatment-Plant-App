part of 'plant_bloc.dart';

abstract class PlantState extends Equatable {
  const PlantState();

  @override
  List<Object?> get props => [];
}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<Map<String, dynamic>> plantData;

  const PlantLoaded(this.plantData);

  @override
  List<Object?> get props => [plantData];
}

class PlantError extends PlantState {
  final String message;

  const PlantError(this.message);

  @override
  List<Object?> get props => [message];
}
