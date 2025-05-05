import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:taste_tube/feature/store/data/shop_analytics.dart';
import 'package:taste_tube/feature/store/view/tabs/analytic/shop_analytic_cubit.dart';
import 'package:taste_tube/utils/currency.util.dart';

class ShopAnalyticTab extends StatelessWidget {
  const ShopAnalyticTab({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<ShopAnalyticCubit, ShopAnalyticState>(
      builder: (context, state) {
        if (state is ShopAnalyticLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ShopAnalyticLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<ShopAnalyticCubit>().fetchAnalytics(),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCard(
                        title: 'Total Revenue',
                        value: CurrencyUtil.amountWithCurrency(
                            state.analytics.totalRevenue,
                            state.analytics.currency),
                        icon: Icons.attach_money,
                        width: screenWidth * 0.29,
                      ),
                      _buildMetricCard(
                        title: 'Orders',
                        value: '${state.analytics.orderCount}',
                        icon: Icons.shopping_cart,
                        width: screenWidth * 0.29,
                      ),
                      _buildMetricCard(
                        title: 'Conversion',
                        value:
                            '${state.analytics.conversionRate.toStringAsFixed(2)}%',
                        icon: Icons.trending_up,
                        width: screenWidth * 0.29,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Customer Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCard(
                        title: 'New Customers',
                        value: '${state.analytics.newCustomers}',
                        icon: Icons.person_add,
                        width: screenWidth * 0.45,
                      ),
                      _buildMetricCard(
                        title: 'Returning',
                        value: '${state.analytics.returningCustomers}',
                        icon: Icons.repeat,
                        width: screenWidth * 0.45,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Daily Sales Chart
                  _buildSectionTitle('Daily Sales'),
                  _buildChartContainer(
                    height: screenHeight * 0.25,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: _buildLineChartTitles(state.analytics),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: state.analytics.dailySales.entries
                                .mapIndexed((index, e) =>
                                    FlSpot(index.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: Colors.blue,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Category Sales Bar Chart with Growth
                  _buildSectionTitle('Top Categories by Revenue'),
                  _buildChartContainer(
                    height: screenHeight * 0.3,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: state.analytics.topCategories
                            .asMap()
                            .entries
                            .map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value.revenue,
                                      color: Colors.primaries[
                                          e.key % Colors.primaries.length],
                                      width: 16,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                      rodStackItems: [
                                        BarChartRodStackItem(
                                          0,
                                          e.value.revenue *
                                              (e.value.growth / 100),
                                          Colors.green.withValues(alpha: 0.3),
                                        ),
                                      ],
                                    ),
                                  ],
                                ))
                            .toList(),
                        titlesData:
                            _buildBarChartTitles(state.analytics.topCategories),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Review Sentiment Pie Chart with Satisfaction Score
                  if (state.analytics.positiveReviews +
                          state.analytics.neutralReviews +
                          state.analytics.negativeReviews >
                      0) ...[
                    _buildSectionTitle('Review Sentiment & Satisfaction'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChartContainer(
                            height: screenHeight * 0.25,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: state.analytics.positiveReviews
                                        .toDouble(),
                                    color: Colors.green,
                                    title:
                                        'Positive\n${state.analytics.positiveReviews}',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    value: state.analytics.neutralReviews
                                        .toDouble(),
                                    color: Colors.yellow,
                                    title:
                                        'Neutral\n${state.analytics.neutralReviews}',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                  ),
                                  PieChartSectionData(
                                    value: state.analytics.negativeReviews
                                        .toDouble(),
                                    color: Colors.red,
                                    title:
                                        'Negative\n${state.analytics.negativeReviews}',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],

                  // Top Products Table with Ratings
                  _buildSectionTitle('Top Selling Products'),
                  _buildTableContainer(
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label: Text('Product',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Sales',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Revenue',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Rating',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: state.analytics.topProducts
                          .map(
                            (product) => DataRow(
                              cells: [
                                DataCell(Text(product.name)),
                                DataCell(Text(product.sales.toString())),
                                DataCell(Text(CurrencyUtil.amountWithCurrency(
                                    product.revenue,
                                    state.analytics.currency))),
                                DataCell(Text('${product.rating}/5')),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Payment Methods Pie Chart
                  _buildSectionTitle('Payment Methods'),
                  _buildChartContainer(
                    height: screenHeight * 0.25,
                    child: PieChart(
                      PieChartData(
                        sections: state.analytics.paymentMethods
                            .map(
                              (method) => PieChartSectionData(
                                value: method.count.toDouble(),
                                color: Colors.primaries[state
                                        .analytics.paymentMethods
                                        .indexOf(method) %
                                    Colors.primaries.length],
                                title:
                                    '${method.name}\n${method.percentage.toStringAsFixed(0)}%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            )
                            .toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          );
        } else if (state is ShopAnalyticError) {
          return RefreshIndicator(
              onRefresh: () =>
                  context.read<ShopAnalyticCubit>().fetchAnalytics(),
              child: ListView(
                children: [
                  const SizedBox(height: 50),
                  Center(child: Text('Error: ${state.message}')),
                ],
              ));
        }
        return RefreshIndicator(
            onRefresh: () => context.read<ShopAnalyticCubit>().fetchAnalytics(),
            child: ListView(
              children: [
                const SizedBox(height: 50),
                Center(child: Text('No data available')),
              ],
            ));
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontSize: 14)),
          subtitle: Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          leading: Icon(icon, size: 24, color: Colors.blue),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          dense: true,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChartContainer({required double height, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: height,
          child: child,
        ),
      ),
    );
  }

  Widget _buildTableContainer({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  FlTitlesData _buildLineChartTitles(ShopAnalytics analytics) {
    final daysOfWeek = analytics.dailySales.keys.toList();
    return FlTitlesData(
      leftTitles: const AxisTitles(
        axisNameWidget: Text('Sales'),
        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final dayIndex = value.toInt();
            if (dayIndex >= 0 && dayIndex < daysOfWeek.length) {
              return Text(
                daysOfWeek[dayIndex],
                style: const TextStyle(fontSize: 12),
              );
            }
            return const SizedBox.shrink();
          },
          interval: 1,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlTitlesData _buildBarChartTitles(List<CategorySales> categories) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              categories[value.toInt()].name,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      leftTitles: const AxisTitles(
        axisNameWidget: Text('Revenue'),
        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
