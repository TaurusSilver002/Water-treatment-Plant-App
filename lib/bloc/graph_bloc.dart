import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/bloc/graph_event.dart' as graph_event;
import 'package:watershooters/bloc/graph_state.dart' as graph_state;
import 'package:watershooters/models/graph_repository.dart';

class GraphBloc extends Bloc<graph_event.GraphEvent, graph_state.GraphState> {
  final GraphRepository repository;
  GraphBloc({required this.repository}) : super(graph_state.GraphInitial()) {
    on<graph_event.FetchGraphData>(_onFetchGraphData);
    on<graph_event.FetchParamGraphData>(_onFetchParamGraphData);
    on<graph_event.FetchFlowGraphData>(_onFetchFlowGraphData);
    on<graph_event.FetchChemUsedGraphData>(_onFetchChemUsedGraphData);
    on<graph_event.FetchChemRemGraphData>(_onFetchChemRemGraphData);
  }

  Future<void> _onFetchGraphData(graph_event.FetchGraphData event, Emitter<graph_state.GraphState> emit) async {
    emit(graph_state.GraphLoading());
    try {
      final data = await repository.fetchEquipGraphData(
        startDate: event.startDate,
        endDate: event.endDate,
        logType: event.logType,
      );
      emit(graph_state.GraphLoaded(data));
    } catch (e) {
      emit(graph_state.GraphError(e.toString()));
    }
  }

  Future<void> _onFetchParamGraphData(graph_event.FetchParamGraphData event, Emitter<graph_state.GraphState> emit) async {
    emit(graph_state.GraphLoading());
    try {
      final data = await repository.fetchParamGraphData(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(graph_state.GraphLoaded(data));
    } catch (e) {
      emit(graph_state.GraphError(e.toString()));
    }
  }

  Future<void> _onFetchFlowGraphData(graph_event.FetchFlowGraphData event, Emitter<graph_state.GraphState> emit) async {
    emit(graph_state.GraphLoading());
    try {
      final data = await repository.fetchFlowGraphData(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(graph_state.GraphLoaded(data));
    } catch (e) {
      emit(graph_state.GraphError(e.toString()));
    }
  }

  Future<void> _onFetchChemUsedGraphData(graph_event.FetchChemUsedGraphData event, Emitter<graph_state.GraphState> emit) async {
    emit(graph_state.GraphLoading());
    try {
      final data = await repository.fetchChemUsedGraphData(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(graph_state.GraphLoaded(data));
    } catch (e) {
      emit(graph_state.GraphError(e.toString()));
    }
  }

  Future<void> _onFetchChemRemGraphData(graph_event.FetchChemRemGraphData event, Emitter<graph_state.GraphState> emit) async {
    emit(graph_state.GraphLoading());
    try {
      final data = await repository.fetchChemRemGraphData(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(graph_state.GraphLoaded(data));
    } catch (e) {
      emit(graph_state.GraphError(e.toString()));
    }
  }
}
