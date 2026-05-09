import 'package:flutter/material.dart';
import 'package:music_player/common/helpers/is_dark_mode.dart';
import 'package:music_player/common/widgets/appbar/app_bar.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/data/sources/song/song_firebase_service.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/home/widgets/news_songs.dart';
import 'package:music_player/presentation/home/widgets/play_list.dart';
import 'package:music_player/presentation/profile/pages/profile.dart';
import 'package:music_player/common/widgets/cus_nav_bar/cus_nav_bar.dart';
import 'package:music_player/presentation/lib_page/pages/lib_page.dart';
import 'package:music_player/presentation/search_page/page/search.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/presentation/comon/widgets/mini_player_bar/mini_player_bar.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomIndex = 0;
  SongEntity? bannerSong;
  bool isLoadingBanner = true;
  SongPlayerCubit? _songPlayerCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu reference đến cubit để sử dụng an toàn
    _songPlayerCubit = context.read<SongPlayerCubit>();
  }

  @override
  void initState() {
    super.initState();
    _loadBannerSong();
  }

  void _loadBannerSong() async {
    final result = await SongFirebaseServiceImpl().getBannerSong();
    result.fold(
      (error) {
        setState(() {
          isLoadingBanner = false;
        });
      },
      (song) {
        setState(() {
          bannerSong = song;
          isLoadingBanner = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeTab(bannerSong: bannerSong, isLoadingBanner: isLoadingBanner),
      const SearchPage(),
      const LibraryPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          _bottomIndex == 0
              ? BasicAppbar(
                hideBack: true,
                title: Image.asset(
                  'assets/vectors/logoMelofyText.png',
                  width: 125,
                ),
              )
              : null,
      body: Column(
        children: [Expanded(child: pages[_bottomIndex]), const MiniPlayerBar()],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomIndex,
        onTap: (index) {
          // Lưu trạng thái phát nhạc khi chuyển tab
          _songPlayerCubit?.savePlaybackState();
          setState(() => _bottomIndex = index);
        },
      ),
    );
  }

  // Widget riêng cho tab Home để giữ code gọn gàng
}

class _HomeTab extends StatelessWidget {
  final SongEntity? bannerSong;
  final bool isLoadingBanner;
  const _HomeTab({this.bannerSong, this.isLoadingBanner = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hometopCard(context),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Nhạc mới nhất',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 280, child: NewsSongs()),
          const PlayList(),
        ],
      ),
    );
  }

  Widget _hometopCard(BuildContext context) {
    if (isLoadingBanner) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (bannerSong == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Không có bài hát banner',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    final bgColor = Color(int.parse('0xFF333333'));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => SongPlayerPage(
                    songList: [bannerSong!],
                    currentIndex: 0,
                    isAlbum: false,
                  ),
            ),
          );
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    AppUrls.coverfirestorage +
                        bannerSong!.artist +
                        ' - ' +
                        bannerSong!.title +
                        '.jpg?' +
                        AppUrls.mediaAlt,
                    width: 140,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chúng tôi đề xuất',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    Text(
                      bannerSong!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      bannerSong!.artist,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
