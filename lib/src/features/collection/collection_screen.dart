// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:pose_selfie_app/src/common_widgets/gradient_border.dart';
import 'package:pose_selfie_app/src/common_widgets/icon_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int selectedIndex = 0;
  List<File> videos = [];
  List<File> images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMediaFiles();
  }

  Future<void> loadMediaFiles() async {
    setState(() => isLoading = true);
    try {
      final appDir = await getApplicationDocumentsDirectory();

      // Load videos
      final videoDir = Directory('${appDir.path}/videos');
      if (await videoDir.exists()) {
        videos = await videoDir
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.mp4'))
            .map((e) => File(e.path))
            .toList();
      }

      // Load images
      final photoDir = Directory('${appDir.path}/photos');
      if (await photoDir.exists()) {
        images = await photoDir
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.jpg'))
            .map((e) => File(e.path))
            .toList();
      }

      // Sort files by creation date, newest first
      videos
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      images
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    } catch (e) {
      print('Error loading media files: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      await loadMediaFiles(); // Reload the list
      Get.snackbar(
        'Success',
        'File deleted successfully',
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white
        
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete file: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteDialog(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(file);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMediaPreview(File file, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPreviewScreen(file: file, isVideo: isVideo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A), // Pure black
            Color(0xFF1A1A1A), // Soft black
            Color(0xFF1A1A24), // Very dark purple tint
            Color(0xFF1E1B2B), // Dark purple transition
            Color(0xFF251D39), // Deep purple
            Color(0xFF2C1F47), // Darker deep purple
          ],
          stops: [0.0, 0.3, 0.5, 0.7, 0.85, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconWidget(icon: Icons.arrow_back_ios),
                    SizedBox(width: 8),
                    Text(
                      'My Collection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,                ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => selectedIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? Colors.yellow
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Video',
                          style: TextStyle(
                            color:
                                selectedIndex == 0 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => selectedIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedIndex == 1
                              ? Colors.yellow
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Image',
                          style: TextStyle(
                            color:
                                selectedIndex == 1 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : IndexedStack(
                        index: selectedIndex,
                        children: [
                          // Video Grid
                          videos.isEmpty
                              ? _buildEmptyState('No videos yet')
                              : GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: videos.length,
                                  itemBuilder: (context, index) {
                                    final video = videos[index];
                                    return _buildMediaItem(video, true);
                                  },
                                ),
                          // Image Grid
                          images.isEmpty
                              ? _buildEmptyState('No images yet')
                              : GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    final image = images[index];
                                    return _buildMediaItem(image, false);
                                  },
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selectedIndex == 0 ? Icons.videocam_off : Icons.image_not_supported,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(File file, bool isVideo) {
    return GestureDetector(
      onTap: () => _showMediaPreview(file, isVideo),
      child: GradientBorderContainer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isVideo
                  ? _VideoThumbnail(file)
                  : Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
              if (isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              Positioned(
                  top: 8,
                  right: 8,
                  child: IconWidget(
                      icon: Icons.more_horiz,
                      paddingLeft: 0,
                      onPressed: () {
                        _showDeleteDialog(file);
                      })),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final File videoFile;

  const _VideoThumbnail(this.videoFile);

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final controller = VideoPlayerController.file(widget.videoFile);
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
        // Seek to first frame
        await controller.seekTo(Duration.zero);
      }
    } catch (e) {
      print('Error initializing video controller: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return VideoPlayer(_controller!);
  }
}

class MediaPreviewScreen extends StatefulWidget {
  final File file;
  final bool isVideo;

  const MediaPreviewScreen({
    Key? key,
    required this.file,
    required this.isVideo,
  }) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  int _countdown = -1;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideoController();
    }
  }

  Future<void> _initializeVideoController() async {
    final controller = VideoPlayerController.file(widget.file);
    await controller.initialize();
    setState(() {
      _controller = controller;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const IconWidget(icon: Icons.arrow_back_ios),
      ),
      body: Center(
        child: widget.isVideo
            ? _buildVideoPreview()
            : Image.file(
                widget.file,
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        // Countdown Overlay
        if (_countdown > 0)
          Center(
            child: SvgPicture.asset(
              'assets/images/${_getCountdownImage(_countdown)}',
              width: 100,
              height: 100,
            ),
          ),
        if (_countdown <= 0)
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
            onPressed: () async {
              if (!_isPlaying) {
                // Start playing immediately
                setState(() {
                  _isPlaying = true;
                  _countdown = 3;
                });
                _controller!.play();

                // Countdown animation while video is playing
                for (int i = 3; i >= 1; i--) {
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    setState(() => _countdown = i - 1);
                  }
                }
              } else {
                setState(() => _isPlaying = false);
                _controller!.pause();
              }
            },
          ),
      ],
    );
  }

  String _getCountdownImage(int count) {
    switch (count) {
      case 3:
        return 'three.svg';
      case 2:
        return 'two.svg';
      case 1:
        return 'one.svg';
      default:
        return '';
    }
  }
}
