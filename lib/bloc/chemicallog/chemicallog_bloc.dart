import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watershooters/models/chemicallog.dart';

part 'chemicallog_event.dart';
part 'chemicallog_state.dart';

class ChemicallogBloc extends Bloc<ChemicallogEvent, ChemicallogState> {
  final ChemicalLogRepository repository;

  ChemicallogBloc({required this.repository}) : super(ChemicallogInitial()) {
    on<FetchChemicallog>(_onFetchChemicallog);
    on<AddChemicallog>(_onAddChemicallog);
  }

  Future<void> _onFetchChemicallog(
      FetchChemicallog event, Emitter<ChemicallogState> emit) async {
    emit(ChemicallogLoading());
    try {
      final chemicallogData = await repository.fetchChemicalLogData( 
        createdAt: event.createdAt,
);
      emit(ChemicallogLoaded(chemicallogData));
    } catch (e) {
      emit(ChemicallogError(e.toString()));
    }
  }

  Future<void> _onAddChemicallog(
      AddChemicallog event, Emitter<ChemicallogState> emit) async {
    try {
      final currentState = state;
      final Map<String, String> convertedLog = event.log.map((key, value) => 
          MapEntry(key, value.toString()));
      final newLog = await repository.addChemicalLog(convertedLog);
      if (currentState is ChemicallogLoaded) {
        final updatedLogs = List<dynamic>.from(currentState.chemicallogData['logs'] ?? [])
          ..add(newLog);
        emit(ChemicallogLoaded({
          'logs': updatedLogs,
        }));
      } else {
        emit(ChemicallogLoaded({'logs': [newLog]}));
      }
      // Emit success message
      emit(ChemicallogSuccess('Chemical log added successfully'));
      // Emit loaded state again to maintain the correct state
      if (currentState is ChemicallogLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(ChemicallogError('Failed to add chemical log: $e'));
    }
  }

  @override
  Future<void> close() {
    repository.dio.close();
    return super.close();
  }
}
