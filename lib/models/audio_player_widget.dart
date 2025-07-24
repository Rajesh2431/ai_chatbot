import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;

  const AudioPlayerWidget({super.key, required this.audioPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isSeeking = false;
  late StreamSubscription<Duration> _positionSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _player = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    await _player.setFilePath(widget.audioPath);
    _duration = _player.duration ?? Duration.zero;

    _positionSub = _player.positionStream.listen((position) {
      if (!_isSeeking) {
        setState(() => _position = position);
      }
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _position = Duration.zero;
        });
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
                  onPressed: () => _player.playing ? _player.pause() : _player.play(),
                ),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: _duration.inMilliseconds.toDouble(),
                    value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue[100],
                    onChangeStart: (_) => _isSeeking = true,
                    onChanged: (value) {
                      setState(() {
                        _position = Duration(milliseconds: value.toInt());
                      });
                    },
                    onChangeEnd: (value) async {
                      _isSeeking = false;
                      await _player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_format(_position)),
                Text(_format(_duration)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
