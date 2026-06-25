import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'invoice.dart';

class MonthlyExpense {
  final String monthLabel; 
  final String monthShort; 
  final int monthNumber; 
  final int year;
  final double totalAmount;

  MonthlyExpense({
    required this.monthLabel,
    required this.monthShort,
    required this.monthNumber,
    required this.year,
    required this.totalAmount,
  });

  
  static Stream<List<MonthlyExpense>> fetchMonthlyTotals() {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance
        .collection('invoices')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final Map<String, double> monthlyTotals = {};

      for (var doc in snapshot.docs) {
        final invoice = Invoice.fromDocument(doc);
        final DateTime dueDate = invoice.dueDate;

       
        final String yearMonthKey = DateFormat('yyyy-MM').format(dueDate);

        monthlyTotals[yearMonthKey] =
            (monthlyTotals[yearMonthKey] ?? 0) + invoice.amount;
      }

      final List<MonthlyExpense> list = monthlyTotals.entries.map((entry) {
        final DateTime date = DateFormat('yyyy-MM').parse(entry.key);
        final String monthShort = DateFormat.MMM('tr_TR').format(date); 
        final String label = "$monthShort ${date.year}"; 

        return MonthlyExpense(
          monthLabel: label,
          monthShort: monthShort,
          monthNumber: date.month,
          year: date.year,
          totalAmount: entry.value,
        );
      }).toList();

     
      list.sort((a, b) => DateTime(a.year, a.monthNumber)
          .compareTo(DateTime(b.year, b.monthNumber)));

      return list;
    });
  }
}
