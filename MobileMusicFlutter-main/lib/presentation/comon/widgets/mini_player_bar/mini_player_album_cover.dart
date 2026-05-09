import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';

class MiniPlayerAlbumCover extends StatelessWidget {
  final SongEntity song;
  final bool isPlaying;
  const MiniPlayerAlbumCover({
    super.key,
    required this.song,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'album_cover_${song.songId}',
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            '${AppUrls.coverfirestorage}${song.artist} - ${song.title}.jpg?${AppUrls.mediaAlt}',
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey[700],
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
