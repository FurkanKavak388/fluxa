import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '/settingspages/aboutpage.dart';
import '/settingspages/passchange.dart';
import '/settingspages/themepage.dart';
import '/settingspages/deleteprofile.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.red.shade600;
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    Widget buildMenuItem({
      required String title,
      required VoidCallback onTap,
      Color? textColor,
      IconData? icon,
      Color? iconColor,
      bool isLogout = false,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: isLogout
                ? primaryColor.withOpacity(0.15)
                : (isDarkMode ? Colors.grey[850] : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon ?? Icons.arrow_forward_ios,
                size: 20,
                color: iconColor ?? (isDarkMode ? Colors.grey[300] : Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? (isDarkMode ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              if (!isLogout)
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
            buildMenuItem(
              title: 'Hakkında',
              icon: Icons.info_outline,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
              },
            ),
            buildMenuItem(
              title: 'Tema Ayarları',
              icon: Icons.brightness_6,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemePage()));
              },
            ),
            buildMenuItem(
              title: 'Şifre Değiştir',
              icon: Icons.lock_outline,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PassChangePage()));
              },
            ),

            

            
            buildMenuItem(
              title: 'Hesabı Kalıcı Olarak Sil',
              icon: Icons.delete_forever,
              iconColor: Colors.red,
              textColor: Colors.red,
              isLogout: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeleteProfilePage()),
                );
              },
            ),

            buildMenuItem(
              title: 'Hesaptan Çıkış Yap',
              icon: Icons.logout,
              iconColor: primaryColor,
              textColor: primaryColor,
              isLogout: true,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
