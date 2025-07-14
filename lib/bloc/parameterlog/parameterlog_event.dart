part of 'parameterlog_bloc.dart';

abstract class ParameterlogEvent extends Equatable {
  const ParameterlogEvent();

  @override
  List<Object> get props => [];
}

class FetchParameterlog extends ParameterlogEvent {
  final String? createdAt;

  const FetchParameterlog({this.createdAt});

  @override
  List<Object> get props => createdAt != null ? [createdAt!] : [];
}

class AddParameterlog extends ParameterlogEvent {
  final Map<String, dynamic> log;

  const AddParameterlog(this.log);

  @override
  List<Object> get props => [log];
}
