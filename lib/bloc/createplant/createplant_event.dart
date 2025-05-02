import 'package:equatable/equatable.dart';
import 'package:waterplant/models/plant_type.dart';

abstract class PlantCreateEvent extends Equatable {
  const PlantCreateEvent();
  
  @override
  List<Object?> get props => [];
}

class CreatePlant extends PlantCreateEvent {
  final PlantModel plant;

  const CreatePlant(this.plant);

  @override
  List<Object?> get props => [plant];
}
