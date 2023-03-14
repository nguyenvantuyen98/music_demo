import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_example/common.dart';
import 'package:rxdart/rxdart.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static int _nextMediaId = 0;
  late AudioPlayer _player;
  final _playlist = [
    SoundCloudSource(
      Uri.parse(
          "https://api-v2.soundcloud.com/media/soundcloud:tracks:250711755/ee0fc8b3-9e49-4433-8ba4-b34462f592ba/stream/hls?client_id=SDvic69dtCia3c4tYqKIhC6j7UfTPHLC"),
      tag: MediaItem(
        id: 'medioas1',
        album: "Science Friday",
        title: "The Chainsmokers - Don't Let Me Down (Illenium Remix)",
        artUri: Uri.parse("https://i1.sndcdn.com/artworks-000150027827-4exjil-large.jpg"),
      ),
    ),
    SoundCloudSource(
      Uri.parse(
          "https://api-v2.soundcloud.com/media/soundcloud:tracks:110460584/92abedff-cc58-4956-9dbf-727265842e31/stream/hls?client_id=SDvic69dtCia3c4tYqKIhC6j7UfTPHLC"),
      tag: MediaItem(
        id: '43140',
        album: "Science Friday",
        title: "Black Butler Opening Monochrome No Kiss",
        artUri: Uri.parse("https://i1.sndcdn.com/artworks-000057789697-pgn548-large.jpg"),
      ),
    ),
    SoundCloudSource(
      Uri.parse(
          "https://api-v2.soundcloud.com/media/soundcloud:tracks:188792247/1ac589c8-9719-4ee3-bb46-c654193dd27e/stream/hls?client_id=SDvic69dtCia3c4tYqKIhC6j7UfTPHLC"),
      tag: MediaItem(
        id: '43075',
        album: "Science Friday",
        title: "JONI AGUNG ILUH MADE RAI KORAN (medley)",
        artUri: Uri.parse("https://i1.sndcdn.com/artworks-000105167387-jw1pmo-large.jpg"),
      ),
    ),
    SoundCloudSource(
      Uri.parse(
          "https://api-v2.soundcloud.com/media/soundcloud:tracks:196243992/0a3a7084-b7cf-420b-b319-8a9615e392ee/stream/hls?client_id=SDvic69dtCia3c4tYqKIhC6j7UfTPHLC"),
      tag: MediaItem(
        id: '840',
        album: "Science Friday",
        title: "Parasyte - Opening - Let Me Hear by \"Fear, and Loathing in Las Vegas\"",
        artUri: Uri.parse("https://i1.sndcdn.com/artworks-000110274896-tj987l-large.jpg"),
      ),
    ),
  ];
  // ConcatenatingAudioSource(children: [
  //   ClippingAudioSource(
  //     start: const Duration(seconds: 60),
  //     end: const Duration(seconds: 90),
  //     child: AudioSource.uri(Uri.parse(
  //         "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")),
  //     tag: MediaItem(
  //       id: '${_nextMediaId++}',
  //       album: "Science Friday",
  //       title: "A Salute To Head-Scratching Science (30 seconds)",
  //       artUri: Uri.parse(
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  //     ),
  //   ),
  //   SoundCloudSource(
  //     Uri.parse(
  //         "https://api-v2.soundcloud.com/media/soundcloud:tracks:250711755/ee0fc8b3-9e49-4433-8ba4-b34462f592ba/stream/hls?client_id=SDvic69dtCia3c4tYqKIhC6j7UfTPHLC"),
  //     tag: MediaItem(
  //       id: 'medioas1',
  //       album: "Science Friday",
  //       title: "A Salute To Head-Scratching Science",
  //       artUri: Uri.parse(
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  //     ),
  //   ),
  //   AudioSource.uri(
  //     Uri.parse("https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3"),
  //     tag: MediaItem(
  //       id: '${_nextMediaId++}',
  //       album: "Science Friday",
  //       title: "From Cat Rheology To Operatic Incompetence",
  //       artUri: Uri.parse(
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  //     ),
  //   ),
  //   AudioSource.uri(
  //     Uri.parse("asset:///audio/nature.mp3"),
  //     tag: MediaItem(
  //       id: '${_nextMediaId++}',
  //       album: "Public Domain",
  //       title: "Nature Sounds",
  //       artUri: Uri.parse(
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  //     ),
  //   ),
  // ]);
  int _addedCount = 0;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playerStateStream.listen((event) async {
      if (event.processingState == ProcessingState.completed) {
        index++;
        if (index >= _playlist.length) index = 0;
        skipToNext();
      }
    }, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAudioSource(_playlist[index]);
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
      print(stackTrace);
    }
  }

  Future<void> skipToNext() async {
    await _player.setAudioSource(_playlist[index]);
    _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _player.positionStream,
      _player.bufferedPositionStream,
      _player.durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.sequence.isEmpty ?? true) {
                      return const SizedBox();
                    }
                    final metadata = state!.currentSource!.tag as MediaItem;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Image.network(metadata.artUri.toString())),
                          ),
                        ),
                        Text(metadata.album!, style: Theme.of(context).textTheme.headline6),
                        Text(metadata.title),
                      ],
                    );
                  },
                ),
              ),
              ControlButtons(_player),
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: (newPosition) {
                      _player.seek(newPosition);
                    },
                  );
                },
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  StreamBuilder<LoopMode>(
                    stream: _player.loopModeStream,
                    builder: (context, snapshot) {
                      final loopMode = snapshot.data ?? LoopMode.off;
                      const icons = [
                        Icon(Icons.repeat, color: Colors.grey),
                        Icon(Icons.repeat, color: Colors.orange),
                        Icon(Icons.repeat_one, color: Colors.orange),
                      ];
                      const cycleModes = [
                        LoopMode.off,
                        LoopMode.all,
                        LoopMode.one,
                      ];
                      final index = cycleModes.indexOf(loopMode);
                      return IconButton(
                        icon: icons[index],
                        onPressed: () {
                          _player.setLoopMode(cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Playlist",
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: _player.shuffleModeEnabledStream,
                    builder: (context, snapshot) {
                      final shuffleModeEnabled = snapshot.data ?? false;
                      return IconButton(
                        icon: shuffleModeEnabled
                            ? const Icon(Icons.shuffle, color: Colors.orange)
                            : const Icon(Icons.shuffle, color: Colors.grey),
                        onPressed: () async {
                          final enable = !shuffleModeEnabled;
                          if (enable) {
                            await _player.shuffle();
                          }
                          await _player.setShuffleModeEnabled(enable);
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 240.0,
                child: StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final sequence = state?.sequence ?? [];
                    return ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) newIndex--;
                        // _playlist.move(oldIndex, newIndex);
                      },
                      children: [
                        for (var i = 0; i < sequence.length; i++)
                          Dismissible(
                            key: ValueKey(sequence[i]),
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                            onDismissed: (dismissDirection) {
                              // _playlist.removeAt(i);
                            },
                            child: Material(
                              color: i == state!.currentIndex ? Colors.grey.shade300 : null,
                              child: ListTile(
                                title: Text(sequence[i].tag.title as String),
                                onTap: () {
                                  _player.seek(Duration.zero, index: i);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            // _playlist.add(AudioSource.uri(
            //   Uri.parse("asset:///audio/nature.mp3"),
            //   tag: MediaItem(
            //     id: '${_nextMediaId++}',
            //     album: "Public Domain",
            //     title: "Nature Sounds ${++_addedCount}",
            //     artUri: Uri.parse(
            //         "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
            //   ),
            // ));
          },
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: () async {
                  player.play();
                },
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero, index: player.effectiveIndices!.first),
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x", style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
