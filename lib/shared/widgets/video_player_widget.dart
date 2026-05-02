import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:video_player/video_player.dart';

/// Reusable video player widget for previewing video files.
/// Provides playback controls including play/pause, seek bar, and duration display.
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, this.videoFile, this.videoUrl});

  final File? videoFile;
  final String? videoUrl;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.videoUrl != null) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl!),
        );
      } else if (widget.videoFile != null) {
        _controller = VideoPlayerController.file(widget.videoFile!);
      } else {
        throw Exception('No video source provided');
      }

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColor.kFailedRed, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Error loading video',
              style: TextStyle(
                color: AppColor.kFailedRed,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColor.kSlateGrey,
                    fontSize: 12,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Video display
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),
              // Play/Pause overlay button
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Video controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Progress bar
              ValueListenableBuilder(
                valueListenable: _controller!,
                builder: (context, VideoPlayerValue value, child) {
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12.0,
                          ),
                        ),
                        child: Slider(
                          value: value.position.inMilliseconds.toDouble(),
                          min: 0.0,
                          max: value.duration.inMilliseconds.toDouble(),
                          onChanged: (newValue) {
                            _controller!.seekTo(
                              Duration(milliseconds: newValue.toInt()),
                            );
                          },
                        ),
                      ),
                      // Time display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(value.position),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColor.kSlateGrey,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                            Text(
                              _formatDuration(value.duration),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColor.kSlateGrey,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
