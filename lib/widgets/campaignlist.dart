import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/campaign.dart';
import '/models/campaignviewer.dart'; 

class CampaignList extends StatelessWidget {
  const CampaignList({Key? key}) : super(key: key);

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
    return Container(
      color: Colors.transparent,
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('campaigns')
            .orderBy('endDate', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Veri alınırken bir hata oluştu.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          final campaigns = docs
              .map((doc) => Campaign.fromFirestore(doc))
              .toList();

          if (campaigns.isEmpty) {
            return const Center(child: Text('Aktif kampanya bulunamadı.'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CampaignViewer(campaign: campaign),
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            campaign.imageUrl,
                            height: 90,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 90,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 36),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                campaign.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getRemainingTime(campaign.endDate),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: campaign.endDate.isBefore(DateTime.now())
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
