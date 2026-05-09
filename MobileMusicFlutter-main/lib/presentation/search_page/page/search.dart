import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/presentation/search_page/bloc/search_cubit.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
// import 'package:music_player/presentation/comon/widgets/mini_player_bar/mini_player_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gọi tìm kiếm rỗng khi trang vừa khởi tạo
    context.read<SearchCubit>().searchSongs('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tìm kiếm',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên bài hát, nghệ sĩ...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      context.read<SearchCubit>().searchSongs(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Kết quả tìm kiếm',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: BlocBuilder<SearchCubit, List<SongEntity>>(
                      builder: (context, songs) {
                        if (songs.isEmpty) {
                          return const Center(
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
                                  'Không có kết quả',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: songs.length,
                          separatorBuilder:
                              (_, __) => const Divider(
                                color: Colors.white12,
                                thickness: 0.5,
                                height: 10,
                              ),
                          itemBuilder: (context, index) {
                            final song = songs[index];
                            final imageUrl =
                                '${AppUrls.coverfirestorage}${song.artist} - ${song.title}.jpg?${AppUrls.mediaAlt}';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.music_note,
                                        color: Colors.white54,
                                        size: 36,
                                      ),
                                ),
                              ),
                              title: Text(
                                song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Text(
                                song.artist,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white30,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => SongPlayerPage(
                                          songList: songs,
                                          currentIndex: index,
                                          isAlbum: false,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Mini player bar ở dưới cùng
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: const MiniPlayerBar(),
          // ),
        ],
      ),
    );
  }
}
