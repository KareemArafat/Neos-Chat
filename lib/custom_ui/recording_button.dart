import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingButton extends StatefulWidget {
  const RecordingButton({
    super.key,
    required this.onRecord,
    required this.buttonColor,
    required this.iconColor,
  });

  final void Function(RecordService recordObj) onRecord;
  final Color buttonColor;
  final Color iconColor;

  @override
  // ignore: library_private_types_in_public_api
  _RecordingButtonState createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton> {
  Duration _recordingDuration = Duration.zero;
  RecordService recordObj = RecordService();

  @override
  void initState() {
    super.initState();
    recordObj = RecordService(
      onDurationUpdate: (duration) {
        setState(() {
          _recordingDuration = duration;
        });
      },
    );
  }

  @override
  void dispose() {
    recordObj.dispose();
    super.dispose();
  }

  void _startRecording() async {
    await recordObj.startRecording();
    setState(() {});
  }

  Future<void> _stopRecording() async {
    await recordObj.stopRecording();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return recordObj.isRecording
        ? RecordingControls(
          iconColor: widget.iconColor,
          duration: _recordingDuration,
          onStop: () async {
            await _stopRecording();
            widget.onRecord(recordObj);
          },
          onCancel: () async {
            await _stopRecording();
            setState(() {});
          },
        )
        : Container(
          decoration: BoxDecoration(
            color: widget.buttonColor,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: widget.iconColor, width: 2),
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.mic, color: widget.iconColor),
            onPressed: _startRecording,
          ),
        );
  }
}

class RecordingControls extends StatelessWidget {
  final Duration duration;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final Color iconColor;

  const RecordingControls({
    super.key,
    required this.duration,
    required this.onStop,
    required this.onCancel,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 30),
          onPressed: onCancel,
        ),
        const SizedBox(width: 20),
        Text(
          "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: onStop,
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor),
            padding: const EdgeInsets.all(15),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class RecordService {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  Function(Duration)? onDurationUpdate;
  bool _isRecorderInitialized = false;

  RecordService({this.onDurationUpdate}) {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> _initializeRecorder() async {
    _recorder ??= FlutterSoundRecorder();

    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception("Microphone permission not granted");
    }

    if (!_isRecorderInitialized) {
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    }

    await _recorder!.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  Future<void> startRecording() async {
    try {
      await _initializeRecorder();

      final directory = await getApplicationDocumentsDirectory();
      _audioPath = '${directory.path}/recorded_audio.wav';

      await _recorder!.startRecorder(toFile: _audioPath, codec: Codec.pcm16WAV);

      _recordingDuration = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(
          seconds: _recordingDuration.inSeconds + 1,
        );
        onDurationUpdate?.call(_recordingDuration);
      });

      _isRecording = true;
    } catch (e) {
      log("Error starting recorder: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      if (_recorder == null || !_isRecording) {
        log("Recorder is not recording");
        return;
      }

      await _recorder!.stopRecorder();
      _timer?.cancel();
      _isRecording = false;
    } catch (e) {
      log("Error stopping recorder: $e");
    }
  }

  void dispose() async {
    try {
      if (_recorder != null && _isRecorderInitialized) {
        await _recorder!.closeRecorder();
        _isRecorderInitialized = false;
      }
      _timer?.cancel();
    } catch (e) {
      log("Error disposing recorder: $e");
    }
  }

  bool get isRecording => _isRecording;
  String? get audioPath => _audioPath;
}
