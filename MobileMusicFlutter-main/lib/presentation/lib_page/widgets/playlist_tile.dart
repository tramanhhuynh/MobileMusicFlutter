import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/presentation/lib_page/pages/playlist_detail_page.dart';

class PlaylistTile extends StatelessWidget {
  final PlaylistEntity playlist;
  final VoidCallback? onTap;
  final Function(bool)? onPlaylistDeleted;
  final VoidCallback? onPlaylistChanged;

  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
    this.onPlaylistDeleted,
    this.onPlaylistChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistDetailPage(playlist: playlist),
              ),
            ).then((result) {
              if (result == true) {
                if (onPlaylistDeleted != null) {
                  print(
                    '=== PLAYLIST DELETED FROM TILE - RELOADING LIBRARY ===',
                  );
                  onPlaylistDeleted!(true);
                } else if (onPlaylistChanged != null) {
                  print(
                    '=== PLAYLIST CHANGED FROM TILE - RELOADING LIBRARY ===',
                  );
                  onPlaylistChanged!();
                }
              }
            });
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 105,
            width: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Color.fromARGB(255, 173, 203, 255)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Hiển thị ảnh cover của bài hát đầu tiên nếu có
                if (playlist.songs.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 105,
                      height: 105, // Kích thước bằng với các card khác
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 143, 201, 249),
                            Colors.blueAccent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.playlist_play,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${playlist.songs.length} bài hát',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
