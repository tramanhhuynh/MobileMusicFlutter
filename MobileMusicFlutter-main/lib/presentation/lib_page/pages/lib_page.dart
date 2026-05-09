import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/entities/album/album.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import '../bloc/lib_cubit.dart';
import '../bloc/lib_state.dart';
import '../widgets/lib_header.dart';
import '../widgets/lib_tab_bar.dart';
import '../widgets/lib_recent_grid.dart';
import '../widgets/create_playlist_tile.dart';
import '../widgets/playlist_tile.dart';
import '../pages/create_playlist_page.dart';
import '../pages/playlist_detail_page.dart';
import 'package:music_player/service_locator.dart';
import 'package:music_player/domain/usecases/song/get_news_songs.dart';
import 'package:music_player/domain/usecases/album/get_albums.dart';
import '../widgets/lib_item_tile.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/common/widgets/music_cd_spinner/music_cd_spinner.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LibCubit(sl<GetNewsSongsUseCase>())..loadLibrary(),
        ),
        BlocProvider(
          create:
              (_) =>
                  AlbumCubit(sl<GetAlbumsUseCase>())
                    ..fetchAlbums(limit: 6), // Giới hạn hiển thị 6 album
        ),
      ],
      child: const LibraryPageBody(),
    );
  }
}

class LibraryPageBody extends StatefulWidget {
  const LibraryPageBody({super.key});

  @override
  State<LibraryPageBody> createState() => _LibraryPageBodyState();
}

class _LibraryPageBodyState extends State<LibraryPageBody> {
  bool isGrid = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibCubit, LibState>(
      builder: (context, state) {
        print('=== BLOC BUILDER DEBUG ===');
        print('State type: ${state.runtimeType}');
        if (state is LibraryLoaded) {
          print('Library loaded with ${state.playlists.length} playlists');
          for (var playlist in state.playlists) {
            print('- ${playlist.name} (${playlist.songs.length} songs)');
          }
        }
        print('==========================');
        
        if (state is LibraryLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thư Viện',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: LibTabBar(
                      filter: state.filter,
                      onFilterChanged:
                          (filter) =>
                              context.read<LibCubit>().changeFilter(filter),
                    ),
                  ),
                  IconButton(
                    icon: Icon(isGrid ? Icons.grid_view : Icons.list),
                    onPressed: () {
                      setState(() {
                        isGrid = !isGrid;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<AlbumCubit, AlbumState>(
                builder: (context, albumState) {
                  List<dynamic> items = [];
                  
                  // Thêm tile tạo playlist
                  items.add(
                    CreatePlaylistTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<LibCubit>(),
                              child: const CreatePlaylistPage(),
                            ),
                          ),
                        ).then((result) {
                          print('=== LIBRARY RELOAD DEBUG ===');
                          print('Result type: ${result.runtimeType}');
                          print('Result value: $result');
                          if (result == true || result is PlaylistEntity) {
                            print('Triggering library reload...');
                            // Force rebuild UI bằng cách setState
                            setState(() {});
                            // Delay một chút để đảm bảo state đã được cập nhật
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (mounted) {
                                context.read<LibCubit>().loadLibrary();
                              }
                            });
                          } else {
                            print('No reload triggered');
                          }
                          print('============================');
                        });
                      },
                    ),
                  );

                  // Thêm playlist của user
                  for (PlaylistEntity playlist in state.playlists) {
                    items.add(playlist);
                  }

                  // Thêm favorite tile
                  items.add(FavoriteTilePlaceholder());

                  // Thêm albums và songs
                  if (albumState is AlbumLoaded) {
                    items.addAll(albumState.albums);
                  }
                  items.addAll(state.recentItems.cast<SongEntity>());

                  // LỌC THEO FILTER
                  if (state.filter == LibraryFilter.music) {
                    items = items.where((item) =>
                        item is SongEntity ||
                        item is FavoriteTilePlaceholder ||
                        item is CreatePlaylistTile ||
                        item is PlaylistEntity).toList();
                  }
                  if (state.filter == LibraryFilter.album) {
                    items = items.where((item) =>
                        item is AlbumEntity ||
                        item is CreatePlaylistTile ||
                        item is PlaylistEntity).toList();
                  }

                  if (isGrid) {
                    return Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item is PlaylistEntity) {
                            return PlaylistTile(
                              playlist: item,
                              onPlaylistDeleted: (deleted) {
                                if (deleted) {
                                  setState(() {});
                                  context.read<LibCubit>().loadLibrary();
                                }
                              },
                            );
                          }
                          return LibItemTile(item: item);
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item is PlaylistEntity) {
                            return _buildPlaylistListItem(item);
                          }
                          return LibListItemTile(item: item);
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          );
        }
        return const Center(child: MusicCDSpinner());
      },
    );
  }

  Widget _buildPlaylistListItem(PlaylistEntity playlist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (playlist.songs.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistDetailPage(playlist: playlist),
                ),
              ).then((result) {
                // Reload library khi quay lại từ playlist detail page
                // để cập nhật thông tin playlist sau khi xóa bài hát
                print('=== RETURNING FROM PLAYLIST DETAIL - RELOADING LIBRARY ===');
                setState(() {});
                context.read<LibCubit>().loadLibrary();
              });
            }
          },
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
                                                   Color.fromARGB(255, 143, 201, 249),
                            Colors.blueAccent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.playlist_play,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        playlist.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${playlist.songs.length} bài hát',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
