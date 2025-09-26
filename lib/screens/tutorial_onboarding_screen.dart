import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'onboarding_screen.dart';

class TutorialOnboardingScreen extends StatefulWidget {
  final String userEmail;

  const TutorialOnboardingScreen({super.key, required this.userEmail});

  @override
  State<TutorialOnboardingScreen> createState() =>
      _TutorialOnboardingScreenState();
}

class _TutorialOnboardingScreenState extends State<TutorialOnboardingScreen> {
  VideoPlayerController? _videoController;
  VideoPlayerController? _nextVideoController;
  int _currentVideoIndex = 0;
  bool _isTransitioning = false;

  // Video file paths
  final List<String> _videoPaths = [
    'lib/assets/videos/know.mp4',
    'lib/assets/videos/grow.mp4',
    'lib/assets/videos/show.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _playCurrentVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _nextVideoController?.dispose();
    super.dispose();
  }

  Future<void> _playCurrentVideo() async {
    // Check if we have more videos to play
    if (_currentVideoIndex >= _videoPaths.length) {
      // Wait 1.5 seconds then navigate to next screen
      Future.delayed(const Duration(milliseconds: 500), () {
        _completeAllVideos();
      });
      return;
    }

    // Dispose previous controller
    _videoController?.dispose();

    // Use pre-loaded controller if available
    if (_nextVideoController != null) {
      _videoController = _nextVideoController;
      _nextVideoController = null;
    } else {
      _videoController = VideoPlayerController.asset(
        _videoPaths[_currentVideoIndex],
      );
      await _videoController!.initialize();
    }

    try {
      await _videoController!.play();

      // Preload next video
      _preloadNextVideo();

      // Listen for video completion
      _videoController!.addListener(_videoListener);

      setState(() {}); // Refresh to show video
    } catch (e) {
      print('Error playing video: $e');
      _playNextVideo(); // Skip to next video on error
    }
  }

  Future<void> _preloadNextVideo() async {
    final nextIndex = _currentVideoIndex + 1;
    if (nextIndex < _videoPaths.length) {
      try {
        _nextVideoController = VideoPlayerController.asset(
          _videoPaths[nextIndex],
        );
        await _nextVideoController!.initialize();
      } catch (e) {
        print('Error preloading next video: $e');
      }
    }
  }

  void _videoListener() {
    if (_videoController!.value.position >= _videoController!.value.duration) {
      // Remove listener to prevent multiple calls
      _videoController!.removeListener(_videoListener);
      _playNextVideo();
    }
  }

  void _playNextVideo() {
    if (!_isTransitioning) {
      _isTransitioning = true;
      _currentVideoIndex++;
      _playCurrentVideo().then((_) {
        _isTransitioning = false;
      });
    }
  }

  void _skipVideo() {
    _playNextVideo();
  }

  void _completeAllVideos() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(userEmail: widget.userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen video
          if (_videoController != null && _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: _skipVideo,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Video progress indicator
          if (_videoController != null && _videoController!.value.isInitialized)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Video counter
                  Text(
                    '${_currentVideoIndex + 1} / ${_videoPaths.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: StreamBuilder(
                      stream: Stream.periodic(
                        const Duration(milliseconds: 100),
                      ),
                      builder: (context, snapshot) {
                        if (_videoController == null ||
                            !_videoController!.value.isInitialized) {
                          return Container();
                        }
                        final progress =
                            _videoController!.value.position.inMilliseconds /
                            _videoController!.value.duration.inMilliseconds;
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
