part of 'chemicallog_bloc.dart';


abstract class ChemicallogEvent extends Equatable {
  const ChemicallogEvent();

  @override
  List<Object> get props => [];
}

class FetchChemicallog extends ChemicallogEvent {}

class AddChemicallog extends ChemicallogEvent {
  final Map<String, String> log;

  const AddChemicallog(this.log);

  @override
  List<Object> get props => [log];
}