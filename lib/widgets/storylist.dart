import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/story.dart';
import '/models/storyviewer.dart';

class StoryList extends StatefulWidget {
  const StoryList({Key? key}) : super(key: key);

  @override
  State<StoryList> createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  late Future<List<Story>> _futureStories;

  @override
  void initState() {
    super.initState();
    _futureStories = fetchStories();
  }

  Future<List<Story>> fetchStories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('stories')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Story.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Story>>(
      future: _futureStories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Story yok'));
        }

        final stories = snapshot.data!;
        stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoryViewer(
                        stories: stories,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber, 
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: story.imageUrl.isNotEmpty
                              ? Image.network(
                                  story.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image),
                                )
                              : const Icon(Icons.image, size: 40),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 70,
                        child: Text(
                          story.title,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
