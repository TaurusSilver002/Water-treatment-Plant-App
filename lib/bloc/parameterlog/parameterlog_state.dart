part of 'parameterlog_bloc.dart';

abstract class ParameterlogState extends Equatable {
  const ParameterlogState();

  @override
  List<Object> get props => [];
}

class ParameterlogInitial extends ParameterlogState {}

class ParameterlogLoading extends ParameterlogState {}

class ParameterlogLoaded extends ParameterlogState {
  final Map<String, dynamic> parameterlogData;

  const ParameterlogLoaded(this.parameterlogData);

  @override
  List<Object> get props => [parameterlogData];
}

class ParameterlogError extends ParameterlogState {
  final String message;

  const ParameterlogError(this.message);

  @override
  List<Object> get props => [message];
}
