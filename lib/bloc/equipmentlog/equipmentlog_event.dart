part of 'equipmentlog_bloc.dart';

abstract class EquipmentEvent extends Equatable {
  const EquipmentEvent();

  @override
  List<Object> get props => [];
}

class FetchEquipment extends EquipmentEvent {
  final String? createdAt;

  const FetchEquipment({this.createdAt});

  @override
  List<Object> get props => createdAt != null ? [createdAt!] : [];
}

class AddEquipmentLog extends EquipmentEvent {
  final Map<String, dynamic> log;

  const AddEquipmentLog(this.log);

  @override
  List<Object> get props => [log];
}