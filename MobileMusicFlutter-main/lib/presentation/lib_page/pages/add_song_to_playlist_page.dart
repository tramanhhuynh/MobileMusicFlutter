import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/search_page/bloc/search_cubit.dart';
import 'package:music_player/domain/usecases/playlist/add_song_to_playlist.dart';
import 'package:music_player/service_locator.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';

class AddSongToPlaylistPage extends StatefulWidget {
  final PlaylistEntity playlist;
  const AddSongToPlaylistPage({super.key, required this.playlist});

  @override
  State<AddSongToPlaylistPage> createState() => _AddSongToPlaylistPageState();
}

class _AddSongToPlaylistPageState extends State<AddSongToPlaylistPage> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedSongIds = {};
  late PlaylistEntity _currentPlaylist;

  @override
  void initState() {
    super.initState();
    _currentPlaylist = widget.playlist;
    _selectedSongIds = _currentPlaylist.songIds.toSet();
    context.read<SearchCubit>().searchSongs('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addSongToPlaylist(String songId) async {
    final result = await sl<AddSongToPlaylistUseCase>().call(
      params: {
        'playlistId': _currentPlaylist.id,
        'songId': songId,
      },
    );
    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $error')),
        );
      },
      (updatedPlaylist) {
        setState(() {
          _currentPlaylist = updatedPlaylist;
          _selectedSongIds = _currentPlaylist.songIds.toSet();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm bài hát vào playlist')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Thêm bài hát vào playlist',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('=== ADD SONG TO PLAYLIST DEBUG ===');
              print('Widget playlist songs: ${widget.playlist.songs.length}');
              print('Current playlist songs: ${_currentPlaylist.songs.length}');
              print('Widget playlist ID: ${widget.playlist.id}');
              print('Current playlist ID: ${_currentPlaylist.id}');
              
              // Nếu đây là playlist mới được tạo (từ CreatePlaylistPage), pop về Library
              // Nếu đây là playlist đã có (từ PlaylistDetailPage), pop về với playlist đã cập nhật
              if (widget.playlist.songs.isEmpty && _currentPlaylist.songs.isNotEmpty) {
                // Playlist mới được tạo và có bài hát
                print('Case 1: Playlist mới có bài hát -> pop(true)');
                Navigator.pop(context, true);
              } else if (widget.playlist.songs.isEmpty && _currentPlaylist.songs.isEmpty) {
                // Playlist mới được tạo nhưng không có bài hát
                print('Case 2: Playlist mới không có bài hát -> pop(true)');
                Navigator.pop(context, true);
              } else {
                // Playlist đã có, trả về playlist đã cập nhật
                print('Case 3: Playlist đã có -> pop(playlist)');
                Navigator.pop(context, _currentPlaylist);
              }
              print('====================================');
            },
            child: const Text(
              'Xong',
              style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập tên bài hát, nghệ sĩ...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                context.read<SearchCubit>().searchSongs(value);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Kết quả tìm kiếm',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<SearchCubit, List<SongEntity>>(
                builder: (context, songs) {
                  if (songs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có kết quả',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: songs.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Colors.white12,
                      thickness: 0.5,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final isSelected = _selectedSongIds.contains(song.songId);
                      final imageUrl = '${AppUrls.coverfirestorage}${song.artist} - ${song.title}.jpg?${AppUrls.mediaAlt}';
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[700],
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white54,
                                size: 24,
                              ),
                            ),
                          ),
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
                        trailing: IconButton(
                          icon: Icon(
                            isSelected ? Icons.check_circle : Icons.add_circle_outline,
                            color: isSelected ? Colors.blueAccent : Colors.white54,
                            size: 28,
                          ),
                          onPressed: () {
                            if (!isSelected) {
                              _addSongToPlaylist(song.songId);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 