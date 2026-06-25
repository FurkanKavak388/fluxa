import 'package:flutter/material.dart';
import '/models/campaign.dart';

class CampaignViewer extends StatelessWidget {
  final Campaign campaign;

  const CampaignViewer({Key? key, required this.campaign}) : super(key: key);

  String _getRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) return 'Süre doldu';
    if (difference.inDays > 0) return '${difference.inDays} gün kaldı';
    if (difference.inHours > 0) return '${difference.inHours} saat kaldı';
    if (difference.inMinutes > 0) return '${difference.inMinutes} dakika kaldı';

    return 'Az kaldı';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                campaign.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                _getRemainingTime(campaign.endDate),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: campaign.endDate.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),

           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                campaign.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
