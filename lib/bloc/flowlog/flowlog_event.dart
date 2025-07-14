part of 'flowlog_bloc.dart';

abstract class FlowlogEvent extends Equatable {
  const FlowlogEvent();

  @override
  List<Object> get props => [];
}

class FetchFlowlog extends FlowlogEvent {
  final String? createdAt;

  const FetchFlowlog({this.createdAt});

  @override
  List<Object> get props => createdAt != null ? [createdAt!] : [];
}

class AddFlowlog extends FlowlogEvent {
  final Map<String, dynamic> log;

  const AddFlowlog(this.log);

  @override
  List<Object> get props => [log];
}
