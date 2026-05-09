import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_state.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'mini_player_album_cover.dart';
import 'mini_player_song_info.dart';
import 'mini_player_controls.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'dart:async'; // Added for Timer

class MiniPlayerBar extends StatefulWidget {
  const MiniPlayerBar({super.key});

  @override
  State<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends State<MiniPlayerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isDragging = false;
  double _dragOffset = 0.0;
  static const double _dragThreshold = 100.0;

  // Thêm biến để lưu trạng thái hiển thị trước đó
  bool _wasVisible = false;
  
  // Thêm timer để lưu trạng thái định kỳ
  Timer? _saveStateTimer;
  SongPlayerCubit? _songPlayerCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu reference đến cubit để sử dụng trong timer
    _songPlayerCubit = context.read<SongPlayerCubit>();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Tăng thời gian để mượt hơn
      vsync: this,
    );
    
    // Animation trượt từ dưới lên với curve mượt mà hơn
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOutCubic, // Sử dụng curve mượt mà hơn
        reverseCurve: Curves.easeInCubic,
      ),
    );
    
    // Animation mờ dần với timing khác
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut), // Mờ dần nhanh hơn
        reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    
    // Thêm animation scale để tạo hiệu ứng bounce nhẹ
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.elasticOut, // Hiệu ứng bounce nhẹ
        reverseCurve: Curves.easeIn,
      ),
    );
    
    // Bắt đầu timer để lưu trạng thái định kỳ
    _startSaveStateTimer();
  }

  void _startSaveStateTimer() {
    _saveStateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _songPlayerCubit != null) {
        _songPlayerCubit!.savePlaybackState();
      }
    });
  }

  @override
  void dispose() {
    _saveStateTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        final isVisible = state is SongPlayerLoaded;
        
        // Cải thiện logic animation
        if (isVisible && !_wasVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _animationController.forward();
          });
        } else if (!isVisible && _wasVisible) {
          _animationController.reverse();
        }
        _wasVisible = isVisible;
        
        if (!isVisible) {
          return const SizedBox.shrink();
        }
        
        final songPlayerCubit = context.read<SongPlayerCubit>();
        final song =
            songPlayerCubit.currentSongEntity ??
            SongEntity(
              title: 'No Song',
              artist: '',
              duration: 0,
              releaseDate: Timestamp.now(),
              isFavorite: false,
              songId: '',
            );
            
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 80 * _slideAnimation.value), // Tăng khoảng cách trượt
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildMiniPlayer(context, state as SongPlayerLoaded, song, songPlayerCubit),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniPlayer(
    BuildContext context,
    SongPlayerLoaded state,
    SongEntity song,
    SongPlayerCubit songPlayerCubit,
  ) {
    final progress =
        state.songDuration.inMilliseconds > 0
            ? state.songPosition.inMilliseconds /
                state.songDuration.inMilliseconds
            : 0.0;
            
    return GestureDetector(
      onVerticalDragStart: (details) {
        setState(() {
          _isDragging = true;
          _dragOffset = 0.0;
        });
      },
      onVerticalDragUpdate: (details) {
        if (_isDragging) {
          setState(() {
            _dragOffset = -details.delta.dy;
          });
        }
      },
      onVerticalDragEnd: (details) {
        setState(() {
          _isDragging = false;
        });
        if (_dragOffset > _dragThreshold) {
          _openPlayerPage(context, song);
        }
        setState(() {
          _dragOffset = 0.0;
        });
      },
      onTap: () {
        _openPlayerPage(context, song);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), // Giảm thời gian để responsive hơn
        curve: Curves.easeOutCubic, // Thêm curve cho drag animation
        transform: Matrix4.translationValues(0, -_dragOffset * 0.3, 0), // Giảm độ nhạy drag
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[900]!, Colors.grey[850]!],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4), // Tăng độ đậm shadow
                blurRadius: 15, // Tăng blur
                offset: const Offset(0, -3), // Tăng offset
                spreadRadius: 2, // Thêm spread radius
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress bar với animation mượt mà hơn
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3, // Tăng độ dày
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      MiniPlayerAlbumCover(
                        song: song,
                        isPlaying: state.isPlaying,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: MiniPlayerSongInfo(song: song)),
                      MiniPlayerControls(
                        context: context,
                        state: state,
                        songPlayerCubit: songPlayerCubit,
                        song: song,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPlayerPage(BuildContext context, SongEntity song) {
    // Lưu trạng thái phát nhạc trước khi mở trang player
    _songPlayerCubit?.savePlaybackState();
    
    // Lấy danh sách bài hát hiện tại đang sử dụng
    final currentSongList = _songPlayerCubit?.currentSongList ?? [song];
    final currentIndex = _songPlayerCubit?.currentSongIndex ?? 0;
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                SongPlayerPage(
                  songList: currentSongList,
                  currentIndex: currentIndex,
                  isAlbum: false,
                ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic; // Sử dụng curve mượt mà hơn
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          // Thêm fade animation cho transition
          var fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ));
          
          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 600), // Tăng thời gian transition
      ),
    );
  }
}
