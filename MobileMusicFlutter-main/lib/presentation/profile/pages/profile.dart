import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/common/helpers/is_dark_mode.dart';
import 'package:music_player/common/widgets/appbar/app_bar.dart';
import 'package:music_player/common/widgets/favorite_button/favorite_button.dart';
import 'package:music_player/common/widgets/music_cd_spinner/music_cd_spinner.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:music_player/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:music_player/presentation/profile/bloc/profile_info_state.dart';
import 'package:music_player/presentation/profile/bloc/user_stats_cubit.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/presentation/youtube_shorts/widgets/youtube_shorts_player.dart';
import 'package:music_player/presentation/youtube_shorts/bloc/youtube_shorts_cubit.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_player/service_locator.dart';
import 'package:music_player/domain/repository/auth/auth.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: BasicAppbar(
        backgroundColor: Colors.black,
        title: Text('Hồ sơ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        hideBack: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileInfo(context),
            SizedBox(height: 20),
            _statisticsSection(),
            SizedBox(height: 20),
            _favoriteSongsSection(),
            SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _profileInfo(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileInfoCubit()..getUser(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Container(
          height: MediaQuery.of(context).size.height / 5 + 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: BlocConsumer<ProfileInfoCubit, ProfileInfoState>(
            listener: (context, state) {
              if (state is ProfileInfoFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Có lỗi xảy ra!')),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileInfoLoading) {
                return Container(
                  alignment: Alignment.center,
                  child: const MusicCDSpinner(),
                );
              }
              if (state is ProfileInfoLoaded) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(state.userEntity.imageURL!),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(45),
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (picked != null) {
                              context.read<ProfileInfoCubit>().updateImage(picked.path);
                            }
                          },
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      state.userEntity.email!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.userEntity.fullName!,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final newName = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                final controller = TextEditingController(text: state.userEntity.fullName);
                                return AlertDialog(
                                  title: Text('Chỉnh sửa tên'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(hintText: 'Nhập tên mới'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, controller.text.trim()),
                                      child: Text('Lưu'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (newName != null && newName.isNotEmpty && newName != state.userEntity.fullName) {
                              context.read<ProfileInfoCubit>().updateName(newName);
                            }
                          },
                          child: Icon(Icons.edit, size: 22, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => YouTubeShortsCubit(),
                                  child: const YouTubeShortsPlayer(),
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.play_circle_outline, color: Colors.white, size: 20),
                          label: Text('Music Shorts', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onPressed: () async {
                            // Sign out first
                            await sl<AuthRepository>().signOut();
                            
                            // Navigate to splash page and close all Cubits
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                          },
                          icon: Icon(Icons.logout, color: Colors.white, size: 20),
                          label: Text('Đăng xuất', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                );
              }
              if (state is ProfileInfoFailure) {
                return Center(child: Text('Có lỗi xảy ra', style: TextStyle(color: Colors.white)));
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget _statisticsSection() {
    return BlocProvider(
      create: (context) => UserStatsCubit()..loadUserStats(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            BlocBuilder<UserStatsCubit, UserStatsState>(
              builder: (context, state) {
                if (state is UserStatsLoading) {
                  return Container(
                    height: 120,
                    child: Center(child: MusicCDSpinner()),
                  );
                }
                if (state is UserStatsLoaded) {
                  return Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.favorite,
                          title: 'Bài hát yêu thích',
                          value: state.favoriteSongsCount.toString(),
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          icon: Icons.playlist_play,
                          title: 'Playlist',
                          value: state.playlistsCount.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          icon: Icons.history,
                          title: 'Đã nghe',
                          value: state.listenedSongsCount.toString(),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  );
                }
                if (state is UserStatsFailure) {
                  return Container(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Không thể tải thống kê',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _favoriteSongsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bài hát yêu thích',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full favorites list
                },
                child: Text('Xem tất cả', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          SizedBox(height: 15),
          BlocProvider(
            create: (context) => FavoriteSongsCubit()..getFavoriteSongs(),
            child: BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
              builder: (context, state) {
                if (state is FavoriteSongsLoading) {
                  return Container(
                    height: 100,
                    child: Center(child: MusicCDSpinner()),
                  );
                }
                if (state is FavoriteSongsLoaded) {
                  if (state.favoriteSongs.isEmpty) {
                    return Container(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Chưa có bài hát yêu thích',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Container(
                    height: 300,
                    child: ListView.builder(
                      itemCount: state.favoriteSongs.length,
                      itemBuilder: (context, index) {
                        final song = state.favoriteSongs[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.darkGrey,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.play_circle_outline,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SongPlayerPage(
                                          songList: [song],
                                          currentIndex: 0,
                                          isAlbum: false,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                FavoriteButton(songEntity: song),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SongPlayerPage(
                                    songList: [song],
                                    currentIndex: 0,
                                    isAlbum: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

}
