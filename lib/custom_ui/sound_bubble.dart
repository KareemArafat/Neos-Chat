import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:neos_chat/custom_ui/time_widget.dart';
import 'package:neos_chat/models/message_model.dart';
import 'package:neos_chat/services/message_service.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:path_provider/path_provider.dart';

class SoundBubble extends StatefulWidget {
  const SoundBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isVoice,
    required this.color,
  });
  final MessageModel message;
  final bool isMe;
  final bool isVoice;
  final Color color;

  @override
  AudioPlayerState createState() => AudioPlayerState();
}

class AudioPlayerState extends State<SoundBubble> {
  final audioPlayer = ap.AudioPlayer();
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _playerStateChangedSubscription = audioPlayer.onPlayerComplete.listen((
      _,
    ) async {
      await stop();
      setState(() {});
    });
    _positionChangedSubscription = audioPlayer.onPositionChanged.listen(
      (position) => setState(() => _position = position),
    );
    _durationChangedSubscription = audioPlayer.onDurationChanged.listen(
      (duration) => setState(() => _duration = duration),
    );
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool initial = widget.message.file!.dataSend != null ? true : false;
    return Align(
      alignment: widget.isMe ? Alignment.bottomLeft : Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            height: 60,
            width: 230,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: <Widget>[
                      initial
                          ? playIcon()
                          : GestureDetector(
                            onTap: () async {
                              try {
                                widget.message.file!.dataSend =
                                    await MessageService().downloadFiles(
                                      path: widget.message.file!.path!,
                                    );
                                setState(() {});
                              } catch (e) {
                                log('error .. ${e.toString()}');
                              }
                            },
                            child: const Icon(
                              Icons.download_sharp,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                      sliderLine(),
                      widget.isVoice
                          ? const Icon(Icons.mic, color: Colors.white)
                          : const Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                          ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: TimeWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget playIcon() {
    return GestureDetector(
      onTap: () {
        if (audioPlayer.state == ap.PlayerState.playing) {
          pause();
        } else {
          play();
        }
      },
      child: Icon(
        audioPlayer.state == ap.PlayerState.playing
            ? Icons.pause
            : Icons.play_arrow,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget sliderLine() {
    final duration = _duration;
    final position = _position;
    bool canSetValue =
        duration != null &&
        position != null &&
        position.inMilliseconds > 0 &&
        position.inMilliseconds < duration.inMilliseconds;
    return SizedBox(
      width: 140,
      child: Slider(
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        onChanged: (v) {
          if (duration != null) {
            final position = v * duration.inMilliseconds;
            audioPlayer.seek(Duration(milliseconds: position.round()));
          }
        },
        value:
            canSetValue
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0,
      ),
    );
  }

  Future<void> play() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_audio.mp3');
    await file.writeAsBytes(
      widget.message.file!.dataSend! as List<int>,
      flush: true,
    );
    await audioPlayer.setSource(ap.DeviceFileSource(file.path));
    await audioPlayer.resume();
  }

  Future<void> pause() => audioPlayer.pause();

  Future<void> stop() => audioPlayer.stop();
}
