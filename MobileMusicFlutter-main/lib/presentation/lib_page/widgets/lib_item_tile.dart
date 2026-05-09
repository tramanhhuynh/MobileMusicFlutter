import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/entities/album/album.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/presentation/lib_page/pages/favoritesong_page.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/presentation/lib_page/pages/album_detail_page.dart';
import 'package:music_player/presentation/lib_page/widgets/create_playlist_tile.dart';

class FavoriteTilePlaceholder {}

class LibItemTile extends StatelessWidget {
  final dynamic
  item; // SongEntity, AlbumEntity, FavoriteTilePlaceholder, hoặc CreatePlaylistTile
  const LibItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item is CreatePlaylistTile) {
      return item as CreatePlaylistTile;
    }

    if (item is FavoriteTilePlaceholder) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoriteSongsDetailPage()),
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
              child: const Icon(Icons.favorite, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 2),
            const Text(
              'Bài hát đã thích',
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    if (item is SongEntity) {
      final song = item as SongEntity;
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => SongPlayerPage(
                    songList: [song],
                    currentIndex: 0,
                    isAlbum: false,
                  ),
            ),
          );
        },
        child: _buildTile(
          image: Image.network(
            AppUrls.coverfirestorage +
                Uri.encodeComponent('${song.artist} - ${song.title}') +
                '.jpg?' +
                AppUrls.mediaAlt,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note, size: 50),
                ),
          ),
          title: song.title,
          subtitle: song.artist,
        ),
      );
    }

    if (item is AlbumEntity) {
      final album = item as AlbumEntity;
      final isArtist = album.type == 'artist';
      final imageUrl =
          '${AppUrls.albumCoverfirestorage}${Uri.encodeComponent(album.albumName)}.jpg?${AppUrls.mediaAlt}';

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AlbumDetailPage(
                    albumId: album.id,
                    albumName: album.albumName,
                    artist: album.artist,
                    coverUrl: '',
                    releaseDate: album.releaseDate.toString(),
                  ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isArtist
                ? ClipOval(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 105,
                    width: 105,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: 105,
                          width: 105,
                          child: const Icon(Icons.person, size: 50),
                        ),
                  ),
                )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 105,
                    width: 105,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: 105,
                          width: 105,
                          child: const Icon(Icons.album, size: 50),
                        ),
                  ),
                ),
            const SizedBox(height: 2),
            Text(
              album.albumName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album.artist,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTile({
    required Widget image,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.grey[300],
            height: 105,
            width: 105,
            child: image,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class LibListItemTile extends StatelessWidget {
  final dynamic item;
  const LibListItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    String title = '';
    String subtitle = '';
    VoidCallback? onTap;

    if (item is CreatePlaylistTile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: (item as CreatePlaylistTile).onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.blueAccent,
                          Color.fromARGB(255, 173, 203, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 50),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Tạo danh sách của bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (item is FavoriteTilePlaceholder) {
      leading = Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(72, 17, 240, 1),
              Color.fromRGBO(173, 207, 206, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 36),
      );
      title = 'Bài hát đã thích';
      subtitle = '';
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FavoriteSongsDetailPage()),
        );
      };
    } else if (item is SongEntity) {
      final song = item as SongEntity;
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          AppUrls.coverfirestorage +
              song.artist +
              ' - ' +
              song.title +
              '.jpg?' +
              AppUrls.mediaAlt,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.music_note),
              ),
        ),
      );
      title = song.title;
      subtitle = song.artist;
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => SongPlayerPage(
                  songList: [song],
                  currentIndex: 0,
                  isAlbum: false,
                ),
          ),
        );
      };
    } else if (item is AlbumEntity) {
      final album = item as AlbumEntity;
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          AppUrls.albumCoverfirestorage +
              album.albumName +
              '.jpg?' +
              AppUrls.mediaAlt,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.album),
              ),
        ),
      );
      title = album.albumName;
      subtitle = album.artist;
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => AlbumDetailPage(
                  albumId: album.id,
                  albumName: album.albumName,
                  artist: album.artist,
                  coverUrl: '',
                  releaseDate: album.releaseDate.toString(),
                ),
          ),
        );
      };
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Nếu muốn thêm icon more hoặc play, thêm tại đây
                // const Icon(Icons.chevron_right, color: Colors.white30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
