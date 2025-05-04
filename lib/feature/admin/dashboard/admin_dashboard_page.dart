import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Metrics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Metrics Cards
            GridView(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 550,
                childAspectRatio: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                MetricCard(
                    title: 'Total Users', value: '12,345', icon: Icons.people),
                MetricCard(
                    title: 'Total Merchants', value: '567', icon: Icons.store),
                MetricCard(
                    title: 'Total Videos',
                    value: '8,901',
                    icon: Icons.video_library),
                MetricCard(
                    title: 'Total Orders',
                    value: '4,321',
                    icon: Icons.shopping_cart),
              ],
            ),
            VideoLineChart(),
            MetricsOverview(),
          ],
        ),
      ),
    );
  }
}

class VideoLineChart extends StatelessWidget {
  const VideoLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Videos Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles()),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            const months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun'
                            ];
                            return Text(months[value.toInt() % 6]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 40),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 1000),
                          FlSpot(1, 1200),
                          FlSpot(2, 1100),
                          FlSpot(3, 1500),
                          FlSpot(4, 1400),
                          FlSpot(5, 1600),
                        ],
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                        showingIndicators: [0, 1, 2, 3, 4, 5],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetricsOverview extends StatelessWidget {
  const MetricsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Metrics Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const statuses = [
                              'Pending',
                              'Completed',
                              'Cancelled'
                            ];
                            return Text(statuses[value.toInt()]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 500, color: Colors.orange)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 1200, color: Colors.green)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 300, color: Colors.red)
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan', 'Feb', 'Mar'];
                            return Text(months[value.toInt()]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 5000, color: Colors.blue)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 7000, color: Colors.blue)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 6000, color: Colors.blue)
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const activities = [
                              'Logins',
                              'Uploads',
                              'Purchases'
                            ];
                            return Text(activities[value.toInt()]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 2000, color: Colors.purple)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 1500, color: Colors.purple)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 1000, color: Colors.purple)
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
