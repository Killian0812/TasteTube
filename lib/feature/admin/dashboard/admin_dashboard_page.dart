import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:animate_do/animate_do.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _fetchAnalyticsData();
  }

  Future<Map<String, dynamic>> _fetchAnalyticsData() async {
    try {
      final dio = getIt<Dio>();
      final response = await dio.get('/analytic/system?days=7');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch analytics data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Metrics'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final totalUsers = data['totalUsers'].toString();
          final totalMerchants = data['totalMerchants'].toString();
          final totalVideos = data['totalVideos'].toString();
          final totalOrders = data['totalOrders'].toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Metrics Cards
                GridView(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 550,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 100),
                      child: MetricCard(
                          title: 'Total Users',
                          value: totalUsers,
                          icon: Icons.people),
                    ),
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                      child: MetricCard(
                          title: 'Total Merchants',
                          value: totalMerchants,
                          icon: Icons.store),
                    ),
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 300),
                      child: MetricCard(
                          title: 'Total Videos',
                          value: totalVideos,
                          icon: Icons.video_library),
                    ),
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 400),
                      child: MetricCard(
                          title: 'Total Orders',
                          value: totalOrders,
                          icon: Icons.shopping_cart),
                    ),
                  ],
                ),
                SlideInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child:
                      OrderLineChart(ordersLineChart: data['ordersLineChart']),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: MetricsOverview(
                    topProducts: data['topProducts'],
                    topShops: data['topShops'],
                    topVideos: data['topVideos'],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OrderLineChart extends StatelessWidget {
  final List<dynamic> ordersLineChart;

  const OrderLineChart({super.key, required this.ordersLineChart});

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
              const Text('Orders Over Last 7 Days',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= ordersLineChart.length) {
                              return const Text('');
                            }
                            final date = DateTime.parse(
                                ordersLineChart[value.toInt()]['date']);
                            return Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text(DateFormat('MMM d').format(date),
                                  style: const TextStyle(fontSize: 12)),
                            );
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
                        spots: List.generate(
                          ordersLineChart.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            ordersLineChart[index]['count'].toDouble(),
                          ),
                        ),
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                        showingIndicators: List.generate(
                            ordersLineChart.length, (index) => index),
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
  final List<dynamic> topProducts;
  final List<dynamic> topShops;
  final List<dynamic> topVideos;

  const MetricsOverview({
    super.key,
    required this.topProducts,
    required this.topShops,
    required this.topVideos,
  });

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
              // Top Products Bar Chart
              ZoomIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Top Products",
                            overflow: TextOverflow.visible,
                          ),
                          sideTitles: SideTitles(
                            reservedSize: 60,
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topProducts.length) {
                                return const Text('');
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '${topProducts[value.toInt()]['count']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topProducts.length) {
                                return const Text('');
                              }
                              return Text(
                                topProducts[value.toInt()]['name'],
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          axisNameWidget: Text(
                            "By orders count",
                            overflow: TextOverflow.visible,
                          ),
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        topProducts.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: topProducts[index]['count'].toDouble(),
                              color: Colors.orange,
                              width: 30,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 30,
                thickness: 2,
              ),
              // Top Shops Bar Chart
              ZoomIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          axisNameWidget: Text(
                            "Top Shops",
                            overflow: TextOverflow.visible,
                          ),
                          sideTitles: SideTitles(
                            reservedSize: 60,
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topShops.length) {
                                return const Text('');
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '${topShops[value.toInt()]['orders']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topShops.length) {
                                return const Text('');
                              }
                              return Text(
                                topShops[value.toInt()]['name'],
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          axisNameWidget: Text(
                            "By orders count",
                            overflow: TextOverflow.visible,
                          ),
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        topShops.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: topShops[index]['orders'].toDouble(),
                              color: Colors.blue,
                              width: 30,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 30,
                thickness: 2,
              ),
              // Top Videos Bar Chart
              ZoomIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          axisNameWidget: Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              "Top Videos",
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          sideTitles: SideTitles(
                            reservedSize: 60,
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topVideos.length) {
                                return const Text('');
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '${topVideos[value.toInt()]['views']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topVideos.length) {
                                return const Text('');
                              }
                              return Text(
                                topVideos[value.toInt()]['title'],
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          axisNameWidget: Text(
                            "By views count",
                            overflow: TextOverflow.visible,
                          ),
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        topVideos.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: topVideos[index]['views'].toDouble(),
                              color: Colors.purple,
                              width: 30,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ),
                    ),
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
