import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/story.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewer({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  late int currentIndex;
  double progress = 0.0;
  Timer? timer;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    startProgress();
  }

  void startProgress() {
    timer?.cancel();
    progress = 0.0;
    timer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!isPaused) {
        setState(() {
          progress += 0.01;
          if (progress >= 1.0) {
            t.cancel();
            goToNextStory();
          }
        });
      }
    });
  }

  void pauseProgress() => setState(() => isPaused = true);
  void resumeProgress() => setState(() => isPaused = false);

  void goToNextStory() {
    if (currentIndex < widget.stories.length - 1) {
      setState(() {
        currentIndex++;
        startProgress();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void goToPreviousStory() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        startProgress();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void exitViewer() {
    timer?.cancel();
    Navigator.of(context).pop();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamıyor')),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final dx = details.globalPosition.dx;
          if (dx > screenWidth * 2 / 3) {
            goToNextStory();
          } else if (dx < screenWidth / 3) {
            goToPreviousStory();
          }
        },
        onLongPressStart: (_) => pauseProgress(),
        onLongPressEnd: (_) => resumeProgress(),
        child: Stack(
          children: [
            // Görsel
            Center(
              child: story.imageUrl.isNotEmpty
                  ? Image.network(
                      story.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 100,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: exitViewer,
                        child: const CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 14,
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            
            if (story.buttonUrl.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 30,
                right: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    backgroundColor: Colors.amberAccent.shade700,
                    foregroundColor: Colors.black,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.amberAccent.shade100,
                  ),
                  onPressed: () => _launchUrl(story.buttonUrl),
                  child: Text(
                    story.buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
