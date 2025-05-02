import 'package:equatable/equatable.dart';

abstract class PlantCreateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlantCreateInitial extends PlantCreateState {}

class PlantCreateLoading extends PlantCreateState {}

class PlantCreateSuccess extends PlantCreateState {}

class PlantCreateFailure extends PlantCreateState {
  final String error;

  PlantCreateFailure(this.error);

  @override
  List<Object?> get props => [error];
}