import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/models/monthlyexpense.dart';

class MonthlyExpenseWidget extends StatefulWidget {
  const MonthlyExpenseWidget({super.key});

  @override
  State<MonthlyExpenseWidget> createState() => _MonthlyExpenseWidgetState();
}

class _MonthlyExpenseWidgetState extends State<MonthlyExpenseWidget> {
  int? selectedYear;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MonthlyExpense>>(
      stream: MonthlyExpense.fetchMonthlyTotals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final expenses = snapshot.data ?? [];
        if (expenses.isEmpty) {
          return const Center(child: Text(''));
        }

        // Yıllar
        final years = expenses.map((e) => e.year).toSet().toList()..sort();
        if (selectedYear == null && years.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => selectedYear = years.last);
          });
        }
        final currentYear = selectedYear ?? (years.isNotEmpty ? years.last : null);

        // Filtrelenmiş veriler
        final filteredExpenses = currentYear == null
            ? <MonthlyExpense>[]
            : expenses.where((e) => e.year == currentYear).toList()
              ..sort((a, b) => a.monthNumber.compareTo(b.monthNumber));

        // Maksimum değer
        final maxAmount = filteredExpenses.isNotEmpty
            ? filteredExpenses.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b)
            : 0.0;
        final chartMaxY = maxAmount > 0 ? maxAmount * 1.2 : 1.0;

        // Yıllık toplam
        final totalForYear =
            filteredExpenses.fold<double>(0, (sum, e) => sum + e.totalAmount);

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Başlık ve yıl seçici
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Aylık Faturalar",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (years.isNotEmpty)
                      DropdownButton<int>(
                        value: currentYear,
                        items: years
                            .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                            .toList(),
                        onChanged: (val) => setState(() => selectedYear = val),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Toplam ($currentYear): ₺${totalForYear.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollbar + Bar chart
                SizedBox(
                  height: 180,
                  child: filteredExpenses.isEmpty
                      ? const Center(child: Text("Bu yıl için veri yok."))
                      : Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true, // her zaman göster
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: filteredExpenses.length * 60,
                              child: BarChart(
                                BarChartData(
                                  maxY: chartMaxY,
                                  alignment: BarChartAlignment.spaceAround,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    leftTitles:
                                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles:
                                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles:
                                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 50,
                                        getTitlesWidget: (value, meta) {
                                          final i = value.toInt();
                                          if (i < 0 || i >= filteredExpenses.length) {
                                            return const SizedBox();
                                          }
                                          final m = filteredExpenses[i];
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                m.monthShort,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              const SizedBox(height: 4),
                                             Text(
                                             '₺${m.totalAmount.toStringAsFixed(0)}',
                                             style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              ),
                                             ),

                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: filteredExpenses.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final expense = entry.value;
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: expense.totalAmount,
                                          color: Colors.red,
                                          width: 24,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
