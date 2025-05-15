part of 'plantequip_bloc.dart';

abstract class PlantequipState extends Equatable {
  const PlantequipState();
  @override
  List<Object> get props => [];
}

class PlantequipInitial extends PlantequipState {}
class PlantequipLoading extends PlantequipState {}
class PlantequipLoaded extends PlantequipState {
  final List<Map<String, dynamic>> equipList;
  const PlantequipLoaded(this.equipList);
  @override
  List<Object> get props => [equipList];
}
class PlantequipError extends PlantequipState {
  final String message;
  const PlantequipError(this.message);
  @override
  List<Object> get props => [message];
}
