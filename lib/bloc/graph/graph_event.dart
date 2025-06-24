import 'package:equatable/equatable.dart';

abstract class GraphEvent extends Equatable {
  const GraphEvent();
  @override
  List<Object?> get props => [];
}

class FetchGraphData extends GraphEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String logType;
  const FetchGraphData({
    required this.startDate,
    required this.endDate,
    required this.logType,
  });
  @override
  List<Object?> get props => [startDate, endDate, logType];
}

class FetchParamGraphData extends GraphEvent {
  final DateTime startDate;
  final DateTime endDate;
  const FetchParamGraphData({
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [startDate, endDate];
}

class FetchFlowGraphData extends GraphEvent {
  final DateTime startDate;
  final DateTime endDate;
  const FetchFlowGraphData({
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [startDate, endDate];
}

class FetchChemUsedGraphData extends GraphEvent {
  final DateTime startDate;
  final DateTime endDate;
  const FetchChemUsedGraphData({
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [startDate, endDate];
}

class FetchChemRemGraphData extends GraphEvent {
  final DateTime startDate;
  final DateTime endDate;
  const FetchChemRemGraphData({
    required this.startDate,
    required this.endDate,
  });
  @override
  List<Object?> get props => [startDate, endDate];
}
