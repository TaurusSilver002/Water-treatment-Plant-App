import 'package:equatable/equatable.dart';

abstract class GraphState extends Equatable {
  const GraphState();
  @override
  List<Object?> get props => [];
}

class GraphInitial extends GraphState {}
class GraphLoading extends GraphState {}
class GraphLoaded extends GraphState {
  final Map<String, dynamic> graphData;
  const GraphLoaded(this.graphData);
  @override
  List<Object?> get props => [graphData];
}
class GraphError extends GraphState {
  final String message;
  const GraphError(this.message);
  @override
  List<Object?> get props => [message];
}
