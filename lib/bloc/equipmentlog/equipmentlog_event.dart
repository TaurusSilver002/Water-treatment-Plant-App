part of 'equipmentlog_bloc.dart';

abstract class EquipmentEvent extends Equatable {
  const EquipmentEvent();

  @override
  List<Object> get props => [];
}

class FetchEquipment extends EquipmentEvent {}

class AddEquipmentLog extends EquipmentEvent {
  final Map<String, String> log;

  const AddEquipmentLog(this.log);

  @override
  List<Object> get props => [log];
}