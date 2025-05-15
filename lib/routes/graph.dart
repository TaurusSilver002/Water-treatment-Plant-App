import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/bloc/graph_bloc.dart';
import 'package:watershooters/bloc/graph_event.dart' as graph_event;
import 'package:watershooters/bloc/graph_state.dart' as graph_state;
import 'package:watershooters/models/graph_repository.dart';
import 'package:watershooters/config.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  late final GraphBloc _graphBloc;
  int _selectedTab = 0; // 0=Equipment, 1=Chemical, 2=Flow, 3=Parameter
  int _chemicalSubTab = 0; // 0=Used, 1=Remaining (for Chemical tab)
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _graphBloc = GraphBloc(repository: GraphRepository());
    _dateRange = null;
  }

  void _fetchGraph() {
    final logTypes = ['equipment', 'chemical', 'flow', 'parameter'];
    if (_dateRange != null) {
      if (_selectedTab == 3) {
        _graphBloc.add(graph_event.FetchParamGraphData(
          startDate: _dateRange!.start,
          endDate: _dateRange!.end,
        ));
      } else if (_selectedTab == 2) {
        _graphBloc.add(graph_event.FetchFlowGraphData(
          startDate: _dateRange!.start,
          endDate: _dateRange!.end,
        ));
      } else if (_selectedTab == 1) {
        if (_chemicalSubTab == 0) {
          _graphBloc.add(graph_event.FetchChemUsedGraphData(
            startDate: _dateRange!.start,
            endDate: _dateRange!.end,
          ));
        } else {
          _graphBloc.add(graph_event.FetchChemRemGraphData(
            startDate: _dateRange!.start,
            endDate: _dateRange!.end,
          ));
        }
      } else {
        _graphBloc.add(graph_event.FetchGraphData(
          startDate: _dateRange!.start,
          endDate: _dateRange!.end,
          logType: logTypes[_selectedTab],
        ));
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkblue,
              onPrimary: AppColors.cream,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.darkblue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _fetchGraph();
    }
  }

  @override
  void dispose() {
    _graphBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _graphBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Graph Data', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.darkblue,
          foregroundColor: AppColors.cream,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabButton(0, 'Equipment'),
                    _buildTabButton(1, 'Chemical'),
                    _buildTabButton(2, 'Flow'),
                    _buildTabButton(3, 'Parameter'),
                  ],
                ),
              ),
              if (_selectedTab == 1) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSubTabButton(0, 'Used'),
                      _buildSubTabButton(1, 'Remaining'),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _dateRange == null
                              ? 'Select date range'
                              : 'From: ${_dateRange!.start.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_dateRange != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'To: ${_dateRange!.end.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _pickDateRange,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkblue,
                        foregroundColor: AppColors.cream,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(_dateRange == null ? 'Pick Date' : 'Change Date', style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
              _dateRange == null
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Please select a date range to view the graph.', style: TextStyle(fontSize: 16))),
                    )
                  : BlocBuilder<GraphBloc, graph_state.GraphState>(
                      builder: (context, state) {
                        if (state is graph_state.GraphLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (state is graph_state.GraphError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: Text('Error: ${state.message}', style: const TextStyle(fontSize: 16))),
                          );
                        } else if (state is graph_state.GraphLoaded) {
                          final series = state.graphData['series'] as List<dynamic>?;
                          if (series == null || series.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: Text('No data available', style: TextStyle(fontSize: 16))),
                            );
                          }
                          if (_selectedTab == 0) {
                            return _buildEquipmentDigitalChart(series);
                          } else if (_selectedTab == 1) {
                            return _buildChemicalLineChart(series);
                          } else if (_selectedTab == 2) {
                            return _buildFlowLineChart(series);
                          } else if (_selectedTab == 3) {
                            return _buildParameterLineChart(series);
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: series.length,
                            itemBuilder: (context, idx) {
                              final s = series[idx];
                              final data = s['data'] as List<dynamic>? ?? [];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ExpansionTile(
                                  title: Text(s['series_name'] ?? 'Series', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  children: [
                                    ...data.map((d) => ListTile(
                                          title: Text('Value: ${d['value']}', style: const TextStyle(fontSize: 14)),
                                          subtitle: Text(
                                            'Time: ${d['timestamp']}\nParameter: ${d['parameter_name'] ?? ''}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        )),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Select a date range and tab to view data.', style: TextStyle(fontSize: 16))),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentDigitalChart(List<dynamic> series) {
    final Map<String, List<Map<String, dynamic>>> paramData = {};
    final List<DateTime> allTimestamps = [];
    final DateTime? toDate = _dateRange?.end;
    for (final s in series) {
      final data = s['data'] as List<dynamic>? ?? [];
      for (final d in data) {
        final param = d['parameter_name'] ?? 'Unknown';
        final ts = DateTime.tryParse(d['timestamp'] ?? '') ?? DateTime.now();
        if (toDate != null && ts.isAfter(DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59))) continue;
        final val = (d['value'] is num) ? d['value'].toDouble() : double.tryParse(d['value'].toString()) ?? 0.0;
        paramData.putIfAbsent(param, () => []).add({'ts': ts, 'val': val});
        allTimestamps.add(ts);
      }
    }
    if (paramData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No data for chart', style: TextStyle(fontSize: 16))),
      );
    }
    allTimestamps.sort();
    final uniqueTimestamps = allTimestamps.toSet().toList()..sort();
    final Map<DateTime, double> xMap = {
      for (int i = 0; i < uniqueTimestamps.length; i++) uniqueTimestamps[i]: i.toDouble()
    };
    final List<LineChartBarData> lines = [];
    int colorIdx = 0;
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.brown, Colors.cyan, Colors.pink];
    paramData.forEach((param, points) {
      points.sort((a, b) => a['ts'].compareTo(b['ts']));
      final spots = <FlSpot>[];
      for (int i = 0; i < points.length; i++) {
        final e = points[i];
        final x = xMap[e['ts']]!;
        final y = e['val'];
        if (i > 0) {
          spots.add(FlSpot(x, points[i - 1]['val']));
        }
        spots.add(FlSpot(x, y));
      }
      lines.add(LineChartBarData(
        spots: spots,
        isStepLineChart: true,
        color: colors[colorIdx % colors.length],
        barWidth: 3,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ));
      colorIdx++;
    });
    final minX = uniqueTimestamps.isNotEmpty ? 0.0 : 0.0;
    final maxX = uniqueTimestamps.isNotEmpty ? (uniqueTimestamps.length - 1).toDouble() : 1.0;
    int labelInterval = 1;
    if (uniqueTimestamps.length > 8) {
      labelInterval = (uniqueTimestamps.length / 8).ceil();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: ((uniqueTimestamps.length * 60).clamp(300, 2000)).toDouble(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: ((uniqueTimestamps.length * 60).clamp(300, 2000)).toDouble(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: lines,
                          minX: minX,
                          maxX: maxX,
                          minY: 0,
                          maxY: 1,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const Text('0', style: TextStyle(fontSize: 12));
                                  if (value == 1) return const Text('1', style: TextStyle(fontSize: 12));
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: labelInterval.toDouble(),
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 || idx >= uniqueTimestamps.length) return const SizedBox.shrink();
                                  if (idx % labelInterval != 0) return const SizedBox.shrink();
                                  final dt = uniqueTimestamps[idx];
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: Text(
                                      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => Colors.black.withOpacity(0.8),
                              tooltipPadding: const EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final param = paramData.keys.elementAt(spot.barIndex);
                                  return LineTooltipItem(
                                    '$param: ${spot.y.toStringAsFixed(2)}\n${uniqueTimestamps[spot.x.toInt()].toString().split(' ')[0]}',
                                    const TextStyle(color: Colors.white, fontSize: 12),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                            horizontalInterval: 0.5,
                            verticalInterval: labelInterval.toDouble(),
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: paramData.keys.map((param) {
              final idx = paramData.keys.toList().indexOf(param);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 16, height: 4, color: colors[idx % colors.length]),
                  const SizedBox(width: 4),
                  Text(param, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChemicalLineChart(List<dynamic> series) {
    final Map<String, List<Map<String, dynamic>>> paramData = {};
    final List<DateTime> allTimestamps = [];
    final DateTime? toDate = _dateRange?.end;
    for (final s in series) {
      final data = s['data'] as List<dynamic>? ?? [];
      for (final d in data) {
        final param = d['parameter_name'] ?? 'Unknown';
        final ts = DateTime.tryParse(d['timestamp'] ?? '') ?? DateTime.now();
        if (toDate != null && ts.isAfter(DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59))) continue;
        final val = (d['value'] is num) ? d['value'].toDouble() : double.tryParse(d['value'].toString()) ?? 0.0;
        paramData.putIfAbsent(param, () => []).add({'ts': ts, 'val': val});
        allTimestamps.add(ts);
      }
    }
    if (paramData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No data for chart', style: TextStyle(fontSize: 16))),
      );
    }
    allTimestamps.sort();
    final uniqueDates = <DateTime>[];
    final startDate = _dateRange!.start;
    final endDate = _dateRange!.end;
    for (DateTime date = DateTime(startDate.year, startDate.month, startDate.day);
        date.isBefore(DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      uniqueDates.add(date);
    }
    final List<LineChartBarData> lines = [];
    int colorIdx = 0;
    final colors = [
      Colors.blue.shade700,
      Colors.red.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.cyan.shade700,
      Colors.pink.shade700,
      Colors.teal.shade700,
    ];
    double minY = double.infinity;
    double maxY = -double.infinity;
    paramData.forEach((param, points) {
      points.sort((a, b) => a['ts'].compareTo(b['ts']));
      final Map<DateTime, double> dateToVal = {};
      for (final p in points) {
        final date = DateTime(p['ts'].year, p['ts'].month, p['ts'].day);
        dateToVal[date] = p['val'];
        minY = minY < p['val'] ? minY : p['val'];
        maxY = maxY > p['val'] ? maxY : p['val'];
      }
      final spots = <FlSpot>[];
      for (int i = 0; i < uniqueDates.length; i++) {
        final currentDate = uniqueDates[i];
        double? interpolatedVal;
        if (dateToVal.containsKey(currentDate)) {
          interpolatedVal = dateToVal[currentDate];
        } else {
          DateTime? prevDate;
          double? prevVal;
          DateTime? nextDate;
          double? nextVal;
          for (final entry in dateToVal.entries) {
            final entryDate = entry.key;
            if (entryDate.isBefore(currentDate) &&
                (prevDate == null || entryDate.isAfter(prevDate))) {
              prevDate = entryDate;
              prevVal = entry.value;
            }
            if (entryDate.isAfter(currentDate) &&
                (nextDate == null || entryDate.isBefore(nextDate))) {
              nextDate = entryDate;
              nextVal = entry.value;
            }
          }
          if (prevVal != null && nextVal != null && prevDate != null && nextDate != null) {
            final totalDuration = nextDate.difference(prevDate).inDays;
            final currentDuration = currentDate.difference(prevDate).inDays;
            final fraction = currentDuration / totalDuration;
            interpolatedVal = prevVal + (nextVal - prevVal) * fraction;
          } else if (prevVal != null) {
            interpolatedVal = prevVal;
          } else if (nextVal != null) {
            interpolatedVal = nextVal;
          }
        }
        if (interpolatedVal != null) {
          spots.add(FlSpot(i.toDouble(), interpolatedVal));
          minY = minY < interpolatedVal ? minY : interpolatedVal;
          maxY = maxY > interpolatedVal ? maxY : interpolatedVal;
        }
      }
      if (spots.isNotEmpty) {
        lines.add(LineChartBarData(
          spots: spots,
          isStepLineChart: false,
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          color: colors[colorIdx % colors.length],
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: colors[colorIdx % colors.length],
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colors[colorIdx % colors.length].withOpacity(0.3),
                colors[colorIdx % colors.length].withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ));
        colorIdx++;
      }
    });
    final minX = uniqueDates.isNotEmpty ? 0.0 : 0.0;
    final maxX = uniqueDates.isNotEmpty ? (uniqueDates.length - 1).toDouble() : 1.0;
    minY = minY.isFinite ? minY - (maxY - minY) * 0.1 : 0.0;
    maxY = maxY.isFinite ? maxY + (maxY - minY) * 0.1 : 1.0;
    int labelInterval = 1;
    if (uniqueDates.length > 8) {
      labelInterval = (uniqueDates.length / 8).ceil();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ((uniqueDates.length * 60).clamp(300, 2000)).toDouble(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: ((uniqueDates.length * 60).clamp(300, 2000)).toDouble(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: lines,
                            minX: minX,
                            maxX: maxX,
                            minY: minY,
                            maxY: maxY,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: (maxY - minY) / 5,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: labelInterval.toDouble(),
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= uniqueDates.length) return const SizedBox.shrink();
                                    if (idx % labelInterval != 0) return const SizedBox.shrink();
                                    final dt = uniqueDates[idx];
                                    return Transform.rotate(
                                      angle: -0.5,
                                      child: Text(
                                        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipColor: (_) => Colors.black.withOpacity(0.8),
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                tooltipMargin: 12,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final param = paramData.keys.elementAt(spot.barIndex);
                                    return LineTooltipItem(
                                      '$param: ${spot.y.toStringAsFixed(2)}\n${uniqueDates[spot.x.toInt()].toString().split(' ')[0]}',
                                      const TextStyle(color: Colors.white, fontSize: 12),
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              horizontalInterval: (maxY - minY) / 5,
                              verticalInterval: labelInterval.toDouble(),
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.withOpacity(0.5)),
                            ),
                            backgroundColor: Colors.white,
                            extraLinesData: ExtraLinesData(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: paramData.keys.map((param) {
              final idx = paramData.keys.toList().indexOf(param);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    param,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterLineChart(List<dynamic> series) {
    final Map<String, List<Map<String, dynamic>>> paramData = {};
    final List<DateTime> allTimestamps = [];
    final DateTime? toDate = _dateRange?.end;
    for (final s in series) {
      final data = s['data'] as List<dynamic>? ?? [];
      for (final d in data) {
        final param = d['parameter_name'] ?? 'Unknown';
        final ts = DateTime.tryParse(d['timestamp'] ?? '') ?? DateTime.now();
        if (toDate != null && ts.isAfter(DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59))) continue;
        final val = (d['value'] is num) ? d['value'].toDouble() : double.tryParse(d['value'].toString()) ?? 0.0;
        paramData.putIfAbsent(param, () => []).add({'ts': ts, 'val': val});
        allTimestamps.add(ts);
      }
    }
    if (paramData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No data for chart', style: TextStyle(fontSize: 16))),
      );
    }
    allTimestamps.sort();
    final uniqueDates = <DateTime>[];
    final startDate = _dateRange!.start;
    final endDate = _dateRange!.end;
    for (DateTime date = DateTime(startDate.year, startDate.month, startDate.day);
        date.isBefore(DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      uniqueDates.add(date);
    }
    final List<LineChartBarData> lines = [];
    int colorIdx = 0;
    final colors = [
      Colors.blue.shade700,
      Colors.red.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.cyan.shade700,
      Colors.pink.shade700,
      Colors.teal.shade700,
    ];
    double minY = double.infinity;
    double maxY = -double.infinity;
    paramData.forEach((param, points) {
      points.sort((a, b) => a['ts'].compareTo(b['ts']));
      final Map<DateTime, double> dateToVal = {};
      for (final p in points) {
        final date = DateTime(p['ts'].year, p['ts'].month, p['ts'].day);
        dateToVal[date] = p['val'];
        minY = minY < p['val'] ? minY : p['val'];
        maxY = maxY > p['val'] ? maxY : p['val'];
      }
      final spots = <FlSpot>[];
      for (int i = 0; i < uniqueDates.length; i++) {
        final currentDate = uniqueDates[i];
        double? interpolatedVal;
        if (dateToVal.containsKey(currentDate)) {
          interpolatedVal = dateToVal[currentDate];
        } else {
          DateTime? prevDate;
          double? prevVal;
          DateTime? nextDate;
          double? nextVal;
          for (final entry in dateToVal.entries) {
            final entryDate = entry.key;
            if (entryDate.isBefore(currentDate) &&
                (prevDate == null || entryDate.isAfter(prevDate))) {
              prevDate = entryDate;
              prevVal = entry.value;
            }
            if (entryDate.isAfter(currentDate) &&
                (nextDate == null || entryDate.isBefore(nextDate))) {
              nextDate = entryDate;
              nextVal = entry.value;
            }
          }
          if (prevVal != null && nextVal != null && prevDate != null && nextDate != null) {
            final totalDuration = nextDate.difference(prevDate).inDays;
            final currentDuration = currentDate.difference(prevDate).inDays;
            final fraction = currentDuration / totalDuration;
            interpolatedVal = prevVal + (nextVal - prevVal) * fraction;
          } else if (prevVal != null) {
            interpolatedVal = prevVal;
          } else if (nextVal != null) {
            interpolatedVal = nextVal;
          }
        }
        if (interpolatedVal != null) {
          if (param.toLowerCase().contains('ph') && (interpolatedVal < 0 || interpolatedVal > 14)) {
            interpolatedVal = interpolatedVal.clamp(0, 14);
          }
          spots.add(FlSpot(i.toDouble(), interpolatedVal));
          minY = minY < interpolatedVal ? minY : interpolatedVal;
          maxY = maxY > interpolatedVal ? maxY : interpolatedVal;
        }
      }
      if (spots.isNotEmpty) {
        lines.add(LineChartBarData(
          spots: spots,
          isStepLineChart: false,
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          color: colors[colorIdx % colors.length],
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: colors[colorIdx % colors.length],
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colors[colorIdx % colors.length].withOpacity(0.3),
                colors[colorIdx % colors.length].withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ));
        colorIdx++;
      }
    });
    final minX = uniqueDates.isNotEmpty ? 0.0 : 0.0;
    final maxX = uniqueDates.isNotEmpty ? (uniqueDates.length - 1).toDouble() : 1.0;
    minY = minY.isFinite ? minY - (maxY - minY) * 0.1 : 0.0;
    maxY = maxY.isFinite ? maxY + (maxY - minY) * 0.1 : 1.0;
    int labelInterval = 1;
    if (uniqueDates.length > 8) {
      labelInterval = (uniqueDates.length / 8).ceil();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ((uniqueDates.length * 60).clamp(300, 2000)).toDouble(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: ((uniqueDates.length * 60).clamp(300, 2000)).toDouble(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: lines,
                            minX: minX,
                            maxX: maxX,
                            minY: minY,
                            maxY: maxY,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: (maxY - minY) / 5,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: labelInterval.toDouble(),
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= uniqueDates.length) return const SizedBox.shrink();
                                    if (idx % labelInterval != 0) return const SizedBox.shrink();
                                    final dt = uniqueDates[idx];
                                    return Transform.rotate(
                                      angle: -0.5,
                                      child: Text(
                                        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipColor: (_) => Colors.black.withOpacity(0.8),
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                tooltipMargin: 12,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final param = paramData.keys.elementAt(spot.barIndex);
                                    return LineTooltipItem(
                                      '$param: ${spot.y.toStringAsFixed(2)}\n${uniqueDates[spot.x.toInt()].toString().split(' ')[0]}',
                                      const TextStyle(color: Colors.white, fontSize: 12),
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              horizontalInterval: (maxY - minY) / 5,
                              verticalInterval: labelInterval.toDouble(),
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.withOpacity(0.5)),
                            ),
                            backgroundColor: Colors.white,
                            extraLinesData: ExtraLinesData(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: paramData.keys.map((param) {
              final idx = paramData.keys.toList().indexOf(param);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    param,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowLineChart(List<dynamic> series) {
    final Map<String, List<Map<String, dynamic>>> paramData = {};
    final List<DateTime> allTimestamps = [];
    final DateTime? toDate = _dateRange?.end;
    for (final s in series) {
      final data = s['data'] as List<dynamic>? ?? [];
      for (final d in data) {
        final param = d['parameter_name'] ?? 'Unknown';
        final ts = DateTime.tryParse(d['timestamp'] ?? '') ?? DateTime.now();
        if (toDate != null && ts.isAfter(DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59))) continue;
        final val = (d['value'] is num) ? d['value'].toDouble() : double.tryParse(d['value'].toString()) ?? 0.0;
        paramData.putIfAbsent(param, () => []).add({'ts': ts, 'val': val});
        allTimestamps.add(ts);
      }
    }
    if (paramData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No data for chart', style: TextStyle(fontSize: 16))),
      );
    }
    allTimestamps.sort();
    final uniqueDates = <DateTime>[];
    final startDate = _dateRange!.start;
    final endDate = _dateRange!.end;
    for (DateTime date = DateTime(startDate.year, startDate.month, startDate.day);
        date.isBefore(DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      uniqueDates.add(date);
    }
    final List<LineChartBarData> lines = [];
    int colorIdx = 0;
    final colors = [
      const Color.fromARGB(255, 2, 44, 86),
      Colors.red.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.cyan.shade700,
      Colors.pink.shade700,
      const Color.fromARGB(255, 224, 243, 20),
    ];
    double minY = double.infinity;
    double maxY = -double.infinity;
    paramData.forEach((param, points) {
      points.sort((a, b) => a['ts'].compareTo(b['ts']));
      final Map<DateTime, double> dateToVal = {};
      for (final p in points) {
        final date = DateTime(p['ts'].year, p['ts'].month, p['ts'].day);
        dateToVal[date] = p['val'];
        minY = minY < p['val'] ? minY : p['val'];
        maxY = maxY > p['val'] ? maxY : p['val'];
      }
      final spots = <FlSpot>[];
      for (int i = 0; i < uniqueDates.length; i++) {
        final currentDate = uniqueDates[i];
        double? interpolatedVal;
        if (dateToVal.containsKey(currentDate)) {
          interpolatedVal = dateToVal[currentDate];
        } else {
          DateTime? prevDate;
          double? prevVal;
          DateTime? nextDate;
          double? nextVal;
          for (final entry in dateToVal.entries) {
            final entryDate = entry.key;
            if (entryDate.isBefore(currentDate) &&
                (prevDate == null || entryDate.isAfter(prevDate))) {
              prevDate = entryDate;
              prevVal = entry.value;
            }
            if (entryDate.isAfter(currentDate) &&
                (nextDate == null || entryDate.isBefore(nextDate))) {
              nextDate = entryDate;
              nextVal = entry.value;
            }
          }
          if (prevVal != null && nextVal != null && prevDate != null && nextDate != null) {
            final totalDuration = nextDate.difference(prevDate).inDays;
            final currentDuration = currentDate.difference(prevDate).inDays;
            final fraction = currentDuration / totalDuration;
            interpolatedVal = prevVal + (nextVal - prevVal) * fraction;
          } else if (prevVal != null) {
            interpolatedVal = prevVal;
          } else if (nextVal != null) {
            interpolatedVal = nextVal;
          }
        }
        if (interpolatedVal != null) {
          spots.add(FlSpot(i.toDouble(), interpolatedVal));
          minY = minY < interpolatedVal ? minY : interpolatedVal;
          maxY = maxY > interpolatedVal ? maxY : interpolatedVal;
        }
      }
      if (spots.isNotEmpty) {
        lines.add(LineChartBarData(
          spots: spots,
          isStepLineChart: false,
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          color: colors[colorIdx % colors.length],
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: colors[colorIdx % colors.length],
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colors[colorIdx % colors.length].withOpacity(0.3),
                colors[colorIdx % colors.length].withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ));
        colorIdx++;
      }
    });
    final minX = uniqueDates.isNotEmpty ? 0.0 : 0.0;
    final maxX = uniqueDates.isNotEmpty ? (uniqueDates.length - 1).toDouble() : 1.0;
    minY = minY.isFinite ? minY - (maxY - minY) * 0.1 : 0.0;
    maxY = maxY.isFinite ? maxY + (maxY - minY) * 0.1 : 1.0;
    int labelInterval = 1;
    if (uniqueDates.length > 8) {
      labelInterval = (uniqueDates.length / 8).ceil();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ((uniqueDates.length * 60).clamp(300, 2000)).toDouble(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: ((uniqueDates.length * 60).clamp(300, 2000)).toDouble(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 350,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: lines,
                            minX: minX,
                            maxX: maxX,
                            minY: minY,
                            maxY: maxY,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: (maxY - minY) / 5,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: labelInterval.toDouble(),
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= uniqueDates.length) return const SizedBox.shrink();
                                    if (idx % labelInterval != 0) return const SizedBox.shrink();
                                    final dt = uniqueDates[idx];
                                    return Transform.rotate(
                                      angle: -0.5,
                                      child: Text(
                                        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipColor: (_) => Colors.black.withOpacity(0.8),
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                tooltipMargin: 12,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final param = paramData.keys.elementAt(spot.barIndex);
                                    return LineTooltipItem(
                                      '$param: ${spot.y.toStringAsFixed(2)}\n${uniqueDates[spot.x.toInt()].toString().split(' ')[0]}',
                                      const TextStyle(color: Colors.white, fontSize: 12),
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: true,
                              horizontalInterval: (maxY - minY) / 5,
                              verticalInterval: labelInterval.toDouble(),
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.withOpacity(0.5)),
                            ),
                            backgroundColor: Colors.white,
                            extraLinesData: ExtraLinesData(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: paramData.keys.map((param) {
              final idx = paramData.keys.toList().indexOf(param);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    param,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTab = index;
          if (_selectedTab != 1) _chemicalSubTab = 0; // Reset sub-tab when switching away from Chemical
          _fetchGraph();
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: _selectedTab == index ? AppColors.darkblue : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _selectedTab == index ? AppColors.cream : AppColors.darkblue,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSubTabButton(int index, String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          _chemicalSubTab = index;
          _fetchGraph();
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: _chemicalSubTab == index ? AppColors.darkblue : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _chemicalSubTab == index ? AppColors.cream : AppColors.darkblue,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}