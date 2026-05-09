import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'lib_item_tile.dart';
import 'package:music_player/presentation/lib_page/pages/favoritesong_page.dart';

class LibRecentGrid extends StatelessWidget {
  final List<SongEntity> items;
  const LibRecentGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteSongsDetailPage(),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 105,
                  width: 105,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(72, 17, 240, 1),
                        Color.fromRGBO(173, 207, 206, 1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bài hát đã thích',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }
        return LibItemTile(item: items[index]);
      },
    );
  }
}
