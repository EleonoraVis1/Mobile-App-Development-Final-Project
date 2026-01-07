import 'package:csc322_starter_app/theme/colors.dart'; 
import 'package:csc322_starter_app/widgets/general/activity.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class ActivityBarData {
  final double value;
  final Color color;
  final IconData icon;

  const ActivityBarData({
    required this.value,
    required this.color,
    required this.icon,
  });
}

class AllActivitiesChart extends StatefulWidget {
  AllActivitiesChart({super.key, required this.activities});

  final List<Map<String, dynamic>> activities;

  @override
  State<AllActivitiesChart> createState() => _AllActivitiesChartState();
}

class _AllActivitiesChartState extends State<AllActivitiesChart> {
  int touchedIndex = -1;
  double run = 0;
  double walk = 0;
  double ride = 0;
  double swim = 0;
  double elliptical = 0;
  List<ActivityBarData> data = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {
    run = walk = ride = swim = elliptical = 0;

    for (var act in widget.activities) {
      final category = (act['category'] as String?)?.toLowerCase() ?? '';
      final mileage = (act['mileage'] as num?)?.toDouble() ?? 0.0;

      switch (category) {
        case 'run':
          run += mileage;
          break;
        case 'walk':
          walk += mileage;
          break;
        case 'ride':
          ride += mileage;
          break;
        case 'swim':
          swim += mileage;
          break;
        case 'elliptical':
          elliptical += mileage;
          break;
        default:
          break;
      }
    }
    data = [
      ActivityBarData(value: run, color: CustomColors.statusInfo, icon: Icons.directions_run),
      ActivityBarData(value: walk, color: CustomColors.statusInfo, icon: FontAwesomeIcons.shoePrints),
      ActivityBarData(value: ride, color: CustomColors.statusInfo, icon: Icons.pedal_bike),
      ActivityBarData(value: swim, color: CustomColors.statusInfo, icon: Icons.pool),
      ActivityBarData(value: elliptical, color: CustomColors.statusInfo, icon: Icons.sports_gymnastics),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic maxY with 20% padding
    final double maxY = data.isEmpty
        ? 20
        : data.map((d) => d.value).reduce(math.max) * 1.2;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Activities Overview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 1.4,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    top: BorderSide(color: Colors.black12),
                    bottom: BorderSide(color: Colors.black12),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        final item = data[index];
                        return AnimatedIconWidget(
                          icon: item.icon,
                          color: item.color,
                          isSelected: touchedIndex == index,
                        );
                      },
                    ),
                  ),
                ),
                barGroups: data.asMap().entries.map((entry) {
                  int index = entry.key;
                  ActivityBarData item = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: item.value,
                        width: 18,
                        color: item.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                    showingTooltipIndicators: touchedIndex == index ? [0] : [],
                  );
                }).toList(),
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 0,
                    getTooltipColor: (_) => Colors.transparent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "${rod.toY}",
                        TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: rod.color,
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.spot == null) {
                      setState(() => touchedIndex = -1);
                      return;
                    }
                    setState(() {
                      touchedIndex = response.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedIconWidget extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;

  const AnimatedIconWidget({
    super.key,
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  @override
  State<AnimatedIconWidget> createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        double t = _controller.value;
        double scale = 1 + t * 0.15;
        double shake = math.sin(t * math.pi * 5) * 3;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Icon(
        widget.icon,
        color: widget.color,
        size: 26,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
