part of 'chemicallog_bloc.dart';

abstract class ChemicallogState extends Equatable {
  const ChemicallogState();

  @override
  List<Object> get props => [];
}

class ChemicallogInitial extends ChemicallogState {}

class ChemicallogLoading extends ChemicallogState {}

class ChemicallogLoaded extends ChemicallogState {
  final Map<String, dynamic> chemicallogData;

  const ChemicallogLoaded(this.chemicallogData);

  @override
  List<Object> get props => [chemicallogData];
}

class ChemicallogError extends ChemicallogState {
  final String message;

  const ChemicallogError(this.message);

  @override
  List<Object> get props => [message];
}