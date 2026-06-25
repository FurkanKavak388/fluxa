import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';
import 'settingspage.dart';
import 'profilepage.dart';
import 'invoicepage.dart';
import 'chancepage.dart';
import 'subspage.dart';
import 'storepage.dart';
import '/widgets/chatbot.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final Color primaryColor = const Color(0xFFE53935);
  final Color glowColor = Colors.amber;

  final List<IconData> icons = [
    Icons.home,
    Icons.receipt_long,
    Icons.casino,
    Icons.shopping_bag_outlined,
    Icons.subscriptions,
    Icons.settings,
  ];

  final List<String> pageTitles = [
    "Fluxa",
    "Fatura",
    "Avantajlar",
    "Mağaza",
    "Abonelik",
    "Ayarlar",
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final List<Widget> _pages = [
      HomePage(user: user),
      const InvoicePage(),
      const ChancePage(),
      const StorePage(),
      const Subspage(),
      const SettingsPage(),
    ];

    final media = MediaQuery.of(context);
    final double safeBottom = media.padding.bottom;

    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Üst kısım
              Container(
                padding: EdgeInsets.only(
                  top: media.padding.top + 12,
                  left: 24,
                  right: 16,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      pageTitles[_currentIndex],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.red,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfilePage()),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sayfa içeriği
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final offsetAnim = Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                      position: offsetAnim,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _pages[_currentIndex],
                ),
              ),
            ],
          ),

          // Alt menü bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(icons.length, (index) {
                      final bool isSelected = _currentIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                                begin: isSelected ? 1.0 : 0.0,
                                end: isSelected ? 1.0 : 0.0),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) {
                              return AnimatedScale(
                                scale: isSelected ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isSelected ? 1.0 : 0.7,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : [],
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      icons[index],
                                      size: isSelected ? 30 : 24,
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                Container(
                  height: safeBottom,
                  color: primaryColor,
                ),
              ],
            ),
          ),

          // Chatbot button
          Positioned(
            bottom: safeBottom + 90,
            right: 30,
            child: const ChatbotButtonWidget(),
          ),
        ],
      ),
    );
  }
}
