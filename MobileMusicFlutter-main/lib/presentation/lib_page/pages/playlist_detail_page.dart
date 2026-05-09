import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/domain/usecases/playlist/remove_song_from_playlist.dart';
import 'package:music_player/domain/usecases/playlist/delete_playlist.dart';
import 'package:music_player/service_locator.dart';
import 'package:music_player/presentation/lib_page/pages/add_song_to_playlist_page.dart';
import 'package:music_player/presentation/comon/widgets/mini_player_bar/mini_player_bar.dart';

class PlaylistDetailPage extends StatefulWidget {
  final PlaylistEntity playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late PlaylistEntity _playlist;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
  }

  Future<void> _removeSongFromPlaylist(String songId) async {
    final result = await sl<RemoveSongFromPlaylistUseCase>().call(
      params: {'playlistId': _playlist.id, 'songId': songId},
    );

    result.fold(
      (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $error')));
      },
      (updatedPlaylist) {
        setState(() {
          _playlist = updatedPlaylist;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bài hát khỏi playlist')),
        );
        // Đánh dấu rằng có thay đổi trong playlist
        _hasChanges = true;
      },
    );
  }

  Future<void> _deletePlaylist() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa playlist'),
            content: const Text('Bạn có chắc chắn muốn xóa playlist này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final result = await sl<DeletePlaylistUseCase>().call(
        params: _playlist.id,
      );
      result.fold(
        (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $error')));
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa playlist thành công!')),
          );
          if (mounted) {
            // Đánh dấu có thay đổi khi xóa playlist
            _hasChanges = true;
            Navigator.pop(context, true);
          }
        },
      );
    }
  }

  String _formatDuration(num duration) {
    double durationDouble = duration.toDouble();
    int minutes = durationDouble.floor();
    int seconds = ((durationDouble - minutes) * 100).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Playlist: ' + _playlist.name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _hasChanges),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Thêm bài hát',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSongToPlaylistPage(playlist: _playlist),
                ),
              ).then((result) {
                if (result != null && result is PlaylistEntity) {
                  // Cập nhật playlist với dữ liệu mới
                  setState(() {
                    _playlist = result;
                  });
                  // Đánh dấu rằng có thay đổi trong playlist
                  _hasChanges = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Xóa playlist',
            onPressed: _deletePlaylist,
          ),
          
        ],
      ),
      body: Column(
        children: [
          // Header với thông tin playlist
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Hình ảnh playlist
                Container(
                  width: 120,
                  height: 120,
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
                  child: const Icon(
                    Icons.playlist_play,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _playlist.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_playlist.songs.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SongPlayerPage(
                                      songList: _playlist.songs,
                                      currentIndex: 0,
                                      isAlbum: false,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_playlist.songs.length} bài hát',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tạo ngày ${_playlist.createdAt.day}/${_playlist.createdAt.month}/${_playlist.createdAt.year}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách bài hát
          Expanded(
            child:
                _playlist.songs.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có bài hát nào',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Thêm bài hát vào playlist này',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _playlist.songs.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            color: Colors.white12,
                            thickness: 0.5,
                            height: 1,
                          ),
                      itemBuilder: (context, index) {
                        final song = _playlist.songs[index];
                        final imageUrl =
                            '${AppUrls.coverfirestorage}${song.artist} - ${song.title}.jpg?${AppUrls.mediaAlt}';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: 
                            // Image.network(
                            //   imageUrl,
                            //   width: 50,
                            //   height: 50,
                            //   fit: BoxFit.cover,
                            //   errorBuilder:
                            //       (_, __, ___) => Container(
                            //         width: 50,
                            //         height: 50,
                            //         color: Colors.grey[700],
                            //         child: const Icon(
                            //           Icons.music_note,
                            //           color: Colors.white54,
                            //           size: 24,
                            //         ),
                            //       ),
                            // ),
                            Text('${index + 1}',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                            
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDuration(song.duration),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                onPressed:
                                    () => _removeSongFromPlaylist(song.songId),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SongPlayerPage(
                                      songList: _playlist.songs,
                                      currentIndex: index,
                                      isAlbum: false,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayerBar(),
    );
  }
}
