import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/themenotifier.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tema Ayarları'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            _buildThemeOption(
              context,
              title: 'Gündüz (Açık Tema)',
              selected: !isDark,
              onTap: () => themeNotifier.toggleTheme(false),
              icon: Icons.wb_sunny_outlined,
              activeColor: Colors.orange.shade400,
            ),
            const SizedBox(height: 20),
            _buildThemeOption(
              context,
              title: 'Gece (Koyu Tema)',
              selected: isDark,
              onTap: () => themeNotifier.toggleTheme(true),
              icon: Icons.nights_stay_outlined,
              activeColor: Colors.blueGrey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
    required Color activeColor,
  }) {
    final textColor = selected
        ? activeColor
        : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? activeColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? activeColor : Colors.grey.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: activeColor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
