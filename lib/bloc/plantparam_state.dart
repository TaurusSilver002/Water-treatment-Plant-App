part of 'plantparam_bloc.dart';

abstract class PlantparamState extends Equatable {
  const PlantparamState();
  @override
  List<Object> get props => [];
}

class PlantparamInitial extends PlantparamState {}
class PlantparamLoading extends PlantparamState {}
class PlantparamLoaded extends PlantparamState {
  final List<Map<String, dynamic>> paramList;
  const PlantparamLoaded(this.paramList);
  @override
  List<Object> get props => [paramList];
}
class PlantparamError extends PlantparamState {
  final String message;
  const PlantparamError(this.message);
  @override
  List<Object> get props => [message];
}
