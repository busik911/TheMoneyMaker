import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';


MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

final List<MediaItem> _queue = [];

Future<List<MediaItem>> queue1() async {

  await Firestore.instance
      .collection("podcast")
      .orderBy("art", descending: true)
      .getDocuments()
      .then((value) {
    for (int i = 0; i < value.documents.length; i++) {
      var a = value.documents[i];
        _queue.add(MediaItem(
            title: '${a['title']}',
            id: '${a['id']}',
            album: '${a['album']}',
            artist: '${a['artist']}',
            artUri: 'https://storage.googleapis.com/business_news/audioBook.jpeg',
            duration: a['duration']));
    }
  });
  return _queue;
}

class PodcastScreen extends StatefulWidget {
  @override
  _PodcastScreenState createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen>
    with TickerProviderStateMixin {

  AnimationController paneController;
  AnimationController playPauseController;
  Animation<double> paneAnimation;
  Animation<double> albumImageAnimation;
  Animation<double> albumImageBlurAnimation;
  Animation<Color> songContainerColorAnimation;
  Animation<Color> textColorAnimation;

  bool isAnimCompleted = false;

  void initState() {
    super.initState();
//      queue1();
    paneController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    paneAnimation = Tween<double>(begin: -300, end: 0.0)
        .animate(CurvedAnimation(parent: paneController, curve: Curves.easeIn));
    albumImageAnimation = Tween<double>(begin: 1.0, end: 0.5)
        .animate(CurvedAnimation(parent: paneController, curve: Curves.easeIn));
    albumImageBlurAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .animate(CurvedAnimation(parent: paneController, curve: Curves.easeIn));
    songContainerColorAnimation =
        ColorTween(begin: Colors.white30, end: Colors.white.withOpacity(0.6))
            .animate(paneController);
    textColorAnimation = ColorTween(begin: Colors.white, end: Colors.black87)
        .animate(paneController);
    playPauseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
  }

  animationInit() {
    if (isAnimCompleted) {
      paneController.reverse();
    } else {
      paneController.forward();
    }
    isAnimCompleted = !isAnimCompleted;
  }


  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);



  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: Center(
            child: Text(
              'PODCAST',
              style: GoogleFonts.abrilFatface(
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),
          ),
        ),
        body: AnimatedBuilder(
          animation: paneController,
          builder: (BuildContext context, widget) {
            return stackBody(context);
          },
        ));
  }

  Widget songContainer(BuildContext context) {
    return Positioned(
      bottom: paneAnimation.value,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          var drag = details.primaryDelta / MediaQuery.of(context).size.height;
          paneController.value = paneController.value - 3 * drag;
          if (paneController.value >= 0.5) {
            paneController.fling(velocity: 1);
          } else {
            paneController.fling(velocity: -1);
          }
        },
        onTap: () {
          animationInit();
        },
        child: Container(
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.5)),
              color: songContainerColorAnimation.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<ScreenState>(
                  stream: _screenStateStream,
                  builder: (context, snapshot) {
                    try {
                      final screenState = snapshot.data;
                      final queue = screenState.queue;
                      var mediaItem = screenState?.mediaItem;
                      final state = screenState?.playbackState;
                      final basicState =
                          state?.basicState ?? BasicPlaybackState.none;
                      return Container(
                        height: 550,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      if (queue != null &&
                                          queue.isNotEmpty &&
                                          mediaItem.title != null)
                                        Text(
                                          mediaItem.title,
                                          maxLines: 2,
                                          style: TextStyle(
                                             color: textColorAnimation.value,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      if (queue != null &&
                                          queue.isNotEmpty &&
                                          mediaItem.title != null)
                                        Text(
                                          mediaItem.artist,
                                          style: TextStyle(
                                            color: textColorAnimation.value,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: isAnimCompleted
                                        ? Icon(
                                            Icons.keyboard_arrow_down,
                                            size: 50.0,
                                            color: textColorAnimation.value,
                                          )
                                        : Icon(
                                            Icons.keyboard_arrow_up,
                                            size: 50.0,
                                            color: textColorAnimation.value,
                                          )),
                              ],
                            ),
                            if(basicState==BasicPlaybackState.none) ...[
                              Text("Listen and Grow /Press below",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white),),
                              SizedBox(height: 20.0,),
                              audioPlayerButton(),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 85.0,
                                      child: basicState !=
                                                  BasicPlaybackState.none &&
                                              basicState !=
                                                  BasicPlaybackState.stopped
                                          ? positionIndicator(mediaItem, state)
                                          : null),
                                )
                              ],
                            ),
                            if (basicState == BasicPlaybackState.none) ...[

                            ] else if (basicState ==
                                    BasicPlaybackState.connecting ||
                                basicState == BasicPlaybackState.buffering) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 64.0,
                                  height: 64.0,
                                  child: CircularProgressIndicator(
                                      backgroundColor:
                                          textColorAnimation.value),
                                ),
                              ),
                            ] else
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  FloatingActionButton(
                                    child: Icon(
                                      Icons.skip_previous,
                                      size: 40.0,
                                      color: textColorAnimation.value,
                                    ),
                                    heroTag: 'skip_previous',
                                    backgroundColor: Colors.white30,
                                    onPressed: mediaItem == queue.first
                                        ? null
                                        : AudioService.skipToPrevious,
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        if (basicState ==
                                            BasicPlaybackState.playing) {
                                          playPauseController.forward();
                                          AudioService.pause();
                                        } else if (basicState ==
                                            BasicPlaybackState.paused) {
                                          playPauseController.reverse();
                                          AudioService.play();
                                        }
                                      },
                                      child: AnimatedIcon(
                                        icon: AnimatedIcons.pause_play,
                                        progress: playPauseController,
                                        color: textColorAnimation.value,
                                        size: 40.0,
                                      ),
                                      heroTag: 'play_pause',
                                      backgroundColor: Colors.white30,
                                    ),
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
                                      playPauseController.reverse();
                                      AudioService.stop();
                                    },
                                    child: Icon(
                                      Icons.stop,
                                      size: 40.0,
                                      color: textColorAnimation.value,
                                    ),
                                    heroTag: 'stop',
                                    backgroundColor: Colors.white30,
                                  ),
                                  FloatingActionButton(
                                    child: Icon(
                                      Icons.skip_next,
                                      size: 40.0,
                                      color: textColorAnimation.value,
                                    ),
                                    heroTag: 'skip_next',
                                    backgroundColor: Colors.white30,
                                    onPressed: mediaItem == queue.last
                                        ? null
                                        : AudioService.skipToNext,
                                  ),
                                ],
                              ),
                            if (basicState == BasicPlaybackState.none) ...[
                              Text(''),
                            ] else
                              Expanded(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: _queue.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            AudioService.playMediaItem(
                                                _queue[index]);
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            'images/community.jpg'),
                                                        fit: BoxFit.cover),
                                                  ),
                                                  height: 60.0,
                                                  width: 60.0,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${_queue[index].title}',
                                                      style: TextStyle(
                                                        color:
                                                            textColorAnimation
                                                                .value,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      '${_queue[index].artist}',
                                                      style: TextStyle(
                                                        color:
                                                            textColorAnimation
                                                                .value,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ),
                          ],
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                    return Text('');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stackBody(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: albumImageAnimation.value,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/community.jpg"),
                    fit: BoxFit.cover)),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: albumImageBlurAnimation.value,
                  sigmaY: albumImageBlurAnimation.value),
              child: Container(
                color: Colors.white.withOpacity(0.0),
              ),
            ),
          ),
        ),
        songContainer(context)
      ],
    );
  }

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position = snapshot.data ?? state.currentPosition.toDouble();
        double duration = mediaItem?.duration?.toDouble();
        final d1=Duration(milliseconds:mediaItem.duration ).toString();
        var fullDuration=d1.split('.');
        final d2=Duration(milliseconds: state.currentPosition).toString();
        var startDuration=d2.split('.');
        return Column(
          children: [
            if (duration != null)
              Slider(
                min: 0.0,
                max: duration,
                activeColor: textColorAnimation.value,
                inactiveColor: Colors.brown.shade600,
                value: seekPos ?? max(0.0, min(position, duration)),
                onChanged: (value) {
                  _dragPositionSubject.add(value);
                },
                onChangeEnd: (value) {
                  AudioService.seekTo(value.toInt());
                  seekPos = value;
                  _dragPositionSubject.add(null);
                },
              ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    startDuration[0],
                    style: TextStyle(color: textColorAnimation.value),
                  ),
                  Text(
                    fullDuration[0],
                    style: TextStyle(color: textColorAnimation.value),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Stream<ScreenState> get _screenStateStream =>
    Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) =>
            ScreenState(queue, mediaItem, playbackState));

RaisedButton audioPlayerButton() => startButton(
      () {
        AudioService.start(
          backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
          androidNotificationChannelName: 'Audio Service Demo',
          notificationColor: 0xFF2196f3,
          androidNotificationIcon: 'mipmap/ic_launcher',
          enableQueue: true,
        );
      },
    );
RaisedButton startButton( VoidCallback onPressed) => RaisedButton(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.transparent),
      ),
      child: Icon(FontAwesomeIcons.solidPlayCircle,size: 60.0,color: Colors.black87,),
      onPressed: onPressed,
    );

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  BasicPlaybackState _eventToBasicState(AudioPlaybackEvent event) {
    if (event.buffering) {
      return BasicPlaybackState.buffering;
    } else {
      switch (event.state) {
        case AudioPlaybackState.none:
          return BasicPlaybackState.none;
        case AudioPlaybackState.stopped:
          return BasicPlaybackState.stopped;
        case AudioPlaybackState.paused:
          return BasicPlaybackState.paused;
        case AudioPlaybackState.playing:
          return BasicPlaybackState.playing;
        case AudioPlaybackState.connecting:
          return _skipState ?? BasicPlaybackState.connecting;
        case AudioPlaybackState.completed:
          return BasicPlaybackState.stopped;
        default:
          throw Exception("Illegal state");
      }
    }
  }

  @override
  Future<void> onStart() async {
    await queue1();
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    AudioServiceBackground.setQueue(_queue);

    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() async {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() async {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    final newMediaItem = mediaItem;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    AudioServiceBackground.setMediaItem(mediaItem);
    await _audioPlayer.setUrl(newMediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  Future<void> _skip(int offset) async {
//    await queue1();
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  void onPlay() async {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
      AudioServiceBackground.sendCustomEvent('just played');
    }
  }

  @override
  void onPause() async {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
      AudioServiceBackground.sendCustomEvent('just paused');
    }
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) async {
    playPause();
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  void _setState({@required BasicPlaybackState state, int position}) async {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }
}
