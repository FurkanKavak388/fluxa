import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final String imagePath;
  final double? size; 
  final Duration duration;

  const AnimatedLogo({
    super.key,
    this.imagePath = 'assets/images/fluxa.png',
    this.size,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = size ?? screenWidth * 0.35; 

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: value.clamp(0.0, 1.0),
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Padding(
                padding: EdgeInsets.all(logoSize * 0.05), 
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
