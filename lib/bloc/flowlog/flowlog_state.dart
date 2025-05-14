part of 'flowlog_bloc.dart';

abstract class FlowlogState extends Equatable {
  const FlowlogState();

  @override
  List<Object> get props => [];
}

class FlowlogInitial extends FlowlogState {}

class FlowlogLoading extends FlowlogState {}

class FlowlogLoaded extends FlowlogState {
  final Map<String, dynamic> flowlogData;

  const FlowlogLoaded(this.flowlogData);

  @override
  List<Object> get props => [flowlogData];
}

class FlowlogError extends FlowlogState {
  final String message;

  const FlowlogError(this.message);

  @override
  List<Object> get props => [message];
}
