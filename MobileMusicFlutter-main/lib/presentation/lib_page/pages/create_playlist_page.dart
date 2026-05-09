import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/usecases/playlist/create_playlist.dart';
import 'package:music_player/service_locator.dart';
import 'add_song_to_playlist_page.dart';

class CreatePlaylistPage extends StatefulWidget {
  const CreatePlaylistPage({super.key});

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createPlaylist() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên playlist')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final result = await sl<CreatePlaylistUseCase>().call(
      params: _nameController.text.trim(),
    );

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $error')),
        );
        setState(() {
          _isCreating = false;
        });
      },
      (playlist) {
        setState(() {
          _isCreating = false;
        });
        print('=== CREATE PLAYLIST DEBUG ===');
        print('Created playlist: ${playlist.name}');
        print('Playlist ID: ${playlist.id}');
        print('Songs count: ${playlist.songs.length}');
        print('Navigating to AddSongToPlaylistPage...');
        print('=============================');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddSongToPlaylistPage(playlist: playlist),
          ),
        ).then((result) {
          print('=== CREATE PLAYLIST RECEIVED RESULT ===');
          print('Result type: ${result.runtimeType}');
          print('Result value: $result');
          if (result == true) {
            print('Playlist created successfully, popping to Library');
            Navigator.pop(context, true);
          }
          print('==========================================');
        });
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
          'Tạo danh sách mới',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập tên danh sách',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createPlaylist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Tạo danh sách',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 