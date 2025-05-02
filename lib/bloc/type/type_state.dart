part of 'type_bloc.dart';

abstract class TypeState extends Equatable {
  const TypeState();
  
  @override
  List<Object> get props => [];
}

class TypeInitial extends TypeState {}

class TypeLoading extends TypeState {}

class TypeLoaded extends TypeState {
  final List<PlantType> types;

  const TypeLoaded(this.types);

  @override
  List<Object> get props => [types];
}

class TypeError extends TypeState {
  final String message;

  const TypeError(this.message);

  @override
  List<Object> get props => [message];
}
