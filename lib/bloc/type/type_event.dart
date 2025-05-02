part of 'type_bloc.dart';

abstract class TypeEvent extends Equatable {
  const TypeEvent();

  @override
  List<Object> get props => [];
}

class FetchPlantTypes extends TypeEvent {}
