part of 'plantchem_bloc.dart';

abstract class PlantchemState extends Equatable {
  const PlantchemState();
  @override
  List<Object> get props => [];
}

class PlantchemInitial extends PlantchemState {}
class PlantchemLoading extends PlantchemState {}
class PlantchemLoaded extends PlantchemState {
  final List<Map<String, dynamic>> chemList;
  const PlantchemLoaded(this.chemList);
  @override
  List<Object> get props => [chemList];
}
class PlantchemError extends PlantchemState {
  final String message;
  const PlantchemError(this.message);
  @override
  List<Object> get props => [message];
}
