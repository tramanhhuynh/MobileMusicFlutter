import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:music_player/data/sources/youtube/youtube_shorts_service.dart';
import 'package:music_player/presentation/youtube_shorts/bloc/youtube_shorts_cubit.dart';
import 'package:music_player/presentation/youtube_shorts/bloc/youtube_shorts_state.dart';

class YouTubeShortsPlayer extends StatefulWidget {
  const YouTubeShortsPlayer({Key? key}) : super(key: key);

  @override
  State<YouTubeShortsPlayer> createState() => _YouTubeShortsPlayerState();
}

class _YouTubeShortsPlayerState extends State<YouTubeShortsPlayer> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<YouTubeShortsCubit>().loadMusicShorts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<YouTubeShortsCubit, YouTubeShortsState>(
        listener: (context, state) {
          if (state is YouTubeShortsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is YouTubeShortsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (state is YouTubeShortsLoaded) {
            if (state.videos.isEmpty) {
              return const Center(
                child: Text(
                  'Không tìm thấy video nào',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Stack(
              children: [
                // PageView cho vertical scrolling
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: state.videos.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    
                    // Load thêm video khi gần cuối
                    final cubit = context.read<YouTubeShortsCubit>();
                    if (cubit.shouldLoadMore(index)) {
                      cubit.loadMoreShorts();
                    }
                  },
                  itemBuilder: (context, index) {
                    final video = state.videos[index];
                    return _ShortVideoCard(
                      video: video,
                      isActive: index == _currentIndex,
                    );
                  },
                ),
                
                // Header với nút back và search
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Music Shorts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showSearchDialog(context),
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'Đã xảy ra lỗi',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Tìm kiếm Shorts',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                context.read<YouTubeShortsCubit>().searchShorts(searchController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Tìm kiếm'),
          ),
        ],
      ),
    );
  }
}

class _ShortVideoCard extends StatelessWidget {
  final YouTubeShortsVideo video;
  final bool isActive;

  const _ShortVideoCard({
    required this.video,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Thumbnail với play button overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _openVideo(context),
              child: Stack(
                children: [
                  // Thumbnail
                  Positioned.fill(
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 100,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          
          // Video info
          Positioned(
            bottom: 100,
            left: 16,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  video.channelTitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(video.publishedAt),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: 'Like',
                  onTap: () {
                    // TODO: Implement like functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thích video!')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.comment,
                  label: 'Comment',
                  onTap: () {
                    // TODO: Implement comment functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mở bình luận')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () => _shareVideo(context),
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.play_arrow,
                  label: 'Watch',
                  onTap: () => _openVideo(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inMinutes} phút trước';
    }
  }

  void _openVideo(BuildContext context) async {
    final url = video.shortsUrl;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở video')),
      );
    }
  }

  void _shareVideo(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chia sẻ: ${video.shortsUrl}')),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 