import 'package:flutter/material.dart';
import 'package:fluxa/subspages/activesubspage.dart';
import '/subspages/allsubsplans.dart';
import '/subspages/subhistory.dart';
import '/subspages/deletesubspage.dart';
import '/models/animation.dart';

class Subspage extends StatelessWidget {
  const Subspage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    Color iconColor = isDarkMode ? Colors.grey[300]! : Colors.grey.shade600;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color buttonColor = isDarkMode ? Colors.grey[850]! : Colors.grey.shade100;

    Widget buildButton({
      required String title,
      required IconData icon,
      required Widget page,
    }) {
      return InkWell(
        onTap: () => Navigator.of(context).push(PageAnimations.slideFromRight(page)),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey[600] : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 24, bottom: 40),
          children: [
            buildButton(
              title: 'Abonelik Planlarını Görüntüle',
              icon: Icons.list_alt_outlined,
              page: const AllSubscriptionPlansPage(),
            ),
            buildButton(
              title: 'Aktif Aboneliklerim',
              icon: Icons.check_circle_outline,
              page: const ActiveSubsPage(),
            ),
            buildButton(
              title: 'Geçmiş Aboneliklerim',
              icon: Icons.history_outlined,
              page: const SubHistoryPage(),
            ),
            buildButton(
              title: 'Abonelik İptal',
              icon: Icons.cancel_outlined,
              page: const DeleteSubsPage(),
            ),
          ],
        ),
      ),
    );
  }
}
