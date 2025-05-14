part of 'equipmentlog_bloc.dart';

abstract class EquipmentState extends Equatable {
  const EquipmentState();

  @override
  List<Object> get props => [];
}

class EquipmentInitial extends EquipmentState {}

class EquipmentLoading extends EquipmentState {}

class EquipmentLoaded extends EquipmentState {
  final Map<String, dynamic> equipmentData;

  const EquipmentLoaded(this.equipmentData);

  @override
  List<Object> get props => [equipmentData];
}

class EquipmentError extends EquipmentState {
  final String message;

  const EquipmentError(this.message);

  @override
  List<Object> get props => [message];
}