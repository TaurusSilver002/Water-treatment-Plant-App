part of 'flowlog_bloc.dart';

abstract class FlowlogEvent extends Equatable {
  const FlowlogEvent();

  @override
  List<Object> get props => [];
}

class FetchFlowlog extends FlowlogEvent {}

class AddFlowlog extends FlowlogEvent {
  final Map<String, String> log;

  const AddFlowlog(this.log);

  @override
  List<Object> get props => [log];
}
