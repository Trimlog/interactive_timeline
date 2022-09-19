import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interactive_timeline/src/utils.dart' as utils;

// timeline cubit
class InteractiveTimelineCubit extends Cubit<InteractiveTimelineState> {
  double minSecondsPerScreenWidth; // Min seconds per screen width
  double maxSecondsPerScreenWidth; // Max seconds per screen width
  Duration timerUpdateInterval; // Milliseconds
  double initialZoomLevel; // Seconds per screen width
  DateTime? initialTime;
  DateTime? minCursor;
  DateTime? maxCursor;
  InteractiveTimelineCubit({
    this.minSecondsPerScreenWidth = 10,
    this.maxSecondsPerScreenWidth = 10000,
    this.timerUpdateInterval = const Duration(milliseconds: 25),
    this.initialZoomLevel = 500,
    this.initialTime,
    minCursor,
    maxCursor,
  }) : super(
          InteractiveTimelineState.initializeAtTime(initialTime ?? DateTime.now()),
        );

  double _restrictZoomLevel(double secondsPerScreenWidth) {
    return max(
      min(
        secondsPerScreenWidth,
        maxSecondsPerScreenWidth,
      ),
      minSecondsPerScreenWidth,
    );
  }

  void setInteraction(bool isInteracting) {
    emit(state.overwrite(isInteracting: isInteracting));
  }

  void dragHorizontally(DragUpdateDetails update) {
    num offsetSeconds = update.primaryDelta! * state.secondsPerPixel;
    DateTime newCursor = state.middleCursor.subtract(Duration(milliseconds: (offsetSeconds * 1000).toInt()));
    state.insideMinMaxCursor(newCursor)
        ? emit(state.overwrite(
            middleCursor: newCursor,
            isInteracting: true,
          ))
        : {};
  }

  void zoomStart(ScaleStartDetails details) {
    emit(state.overwrite(
      secondsPerScreenWidthBeforeZoom: state.secondsPerScreenWidth,
    ));
  }

  void zoomUpdate(ScaleUpdateDetails update) {
    emit(state.overwrite(
      isInteracting: true,
      secondsPerScreenWidth: _restrictZoomLevel(state.secondsPerScreenWidthBeforeZoom / update.scale),
    ));
  }

  void zoomEnd(ScaleEndDetails details) {
    emit(state.overwrite(
      isInteracting: false,
    ));
  }

  void startTimer() {
    if (state.isPlaying == false) {
      emit(state.overwrite(
        playTimer: Timer.periodic(
          timerUpdateInterval,
          (Timer t) => _tickTimer(timerUpdateInterval),
        ),
        isPlaying: true,
      ));
    }
  }

  void stopTimer() {
    if (state.isPlaying == true) {
      state.playTimer!.cancel();
      emit(state.overwrite(
        playTimer: null,
        isPlaying: false,
      ));
    }
  }

  void toggleTimer() {
    if (state.isPlaying == true) {
      stopTimer();
    } else {
      startTimer();
    }
  }

  void setMinMax({DateTime? minCursor, DateTime? maxCursor, DateTime? middleCursor}) {
    var newState = state.setMinMaxCursor(minCursor: minCursor, maxCursor: maxCursor);
    newState = newState.overwrite(
      // middleCursor is optional to use custom middleCursor to crop
      middleCursor: newState.cropMinMaxCursor(middleCursor ?? newState.middleCursor),
    );
    emit(newState);
  }

  void setCursor(DateTime cursor) {
    emit(
      state.overwrite(
        middleCursor: state.cropMinMaxCursor(cursor),
      ),
    );
  }

  void _tickTimer(Duration duration) {
    if (!state.isInteracting) {
      double timerMilliesecondsPerScreenWidth = 10 * 1000; // timer scroll speed
      double deltaScreenWidth = duration.inMilliseconds / timerMilliesecondsPerScreenWidth;
      Duration deltaCursor = Duration(milliseconds: (deltaScreenWidth * state.secondsPerScreenWidth * 1000).toInt());
      DateTime newCursor = state.middleCursor.add(deltaCursor);
      state.insideMinMaxCursor(newCursor)
          ? emit(
              state.overwrite(
                middleCursor: newCursor,
              ),
            )
          : stopTimer();
    }
  }

  void initialize(double width, double height, [DateTime? minCursor, DateTime? maxCursor]) {
    emit(state.overwrite(
      secondsPerScreenWidth: initialZoomLevel, // default zoom level
      middleCursor: initialTime,
      width: width,
      height: height,
      minCursor: minCursor,
      maxCursor: maxCursor,
    ));
  }
}

class InteractiveTimelineState extends Equatable {
  const InteractiveTimelineState({
    required this.width,
    required this.height,
    required this.secondsPerPixel,
    required this.secondsPerScreenWidth,
    required this.secondsPerScreenWidthBeforeZoom,
    required this.middleCursor,
    required this.leftCursor,
    required this.rightCursor,
    required this.minCursor,
    required this.maxCursor,
    required this.playTimer,
    required this.isPlaying,
    required this.isInteracting,
  }) : super();

  final double width;
  final double height;
  final double secondsPerPixel;
  final double secondsPerScreenWidth;
  final double secondsPerScreenWidthBeforeZoom;
  final DateTime middleCursor;
  final DateTime leftCursor;
  final DateTime rightCursor;
  final DateTime? minCursor;
  final DateTime? maxCursor;
  final Timer? playTimer;
  final bool isPlaying;
  final bool isInteracting;

  @override
  List<Object> get props => [width, height, secondsPerPixel, secondsPerScreenWidth, secondsPerScreenWidthBeforeZoom, middleCursor, leftCursor, rightCursor, isPlaying, isInteracting];

  static InteractiveTimelineState initializeAtTime(DateTime time) {
    return InteractiveTimelineState(
      width: 1,
      height: 1,
      secondsPerPixel: 1,
      secondsPerScreenWidth: 1,
      secondsPerScreenWidthBeforeZoom: 1,
      middleCursor: time,
      leftCursor: time,
      rightCursor: time,
      minCursor: null,
      maxCursor: null,
      playTimer: null,
      isPlaying: false,
      isInteracting: false,
    );
  }

  bool insideMinMaxCursor(DateTime cursor, [DateTime? minCursor, DateTime? maxCursor]) => utils.insideMinMaxCursor(
        cursor,
        minCursor ?? this.minCursor,
        maxCursor ?? this.maxCursor,
      );

  DateTime cropMinMaxCursor(DateTime cursor, [DateTime? minCursor, DateTime? maxCursor]) => utils.cropMinMaxCursor(
        cursor,
        minCursor ?? this.minCursor,
        maxCursor ?? this.maxCursor,
      );

  DateTime _calculateLeftCursor(double width, double secondsPerPixel, DateTime middleCursor) {
    return middleCursor.subtract(
      Duration(milliseconds: ((width / 2) * secondsPerPixel * 1000).toInt()),
    );
  }

  DateTime _calculateRightCursor(double width, double secondsPerPixel, DateTime middleCursor) {
    return middleCursor.add(
      Duration(milliseconds: ((width / 2) * secondsPerPixel * 1000).toInt()),
    );
  }

  // minCursor and maxCursor should be changable to null (.overwrite would fall back when passed null)
  InteractiveTimelineState setMinMaxCursor({DateTime? minCursor, DateTime? maxCursor}) {
    return InteractiveTimelineState(
      width: width,
      height: height,
      secondsPerPixel: secondsPerPixel,
      secondsPerScreenWidth: secondsPerScreenWidth,
      secondsPerScreenWidthBeforeZoom: secondsPerScreenWidthBeforeZoom,
      middleCursor: middleCursor,
      leftCursor: leftCursor,
      rightCursor: rightCursor,
      minCursor: minCursor,
      maxCursor: maxCursor,
      playTimer: playTimer,
      isPlaying: isPlaying,
      isInteracting: isInteracting,
    );
  }

  InteractiveTimelineState overwrite({
    double? width,
    double? height,
    double? secondsPerScreenWidth,
    double? secondsPerScreenWidthBeforeZoom,
    DateTime? middleCursor,
    DateTime? minCursor,
    DateTime? maxCursor,
    Timer? playTimer,
    bool? isPlaying,
    bool? isInteracting,
  }) {
    double newSecondsPerScreenWidth = secondsPerScreenWidth ?? this.secondsPerScreenWidth;
    double newWidth = width ?? this.width;
    double newSecondsPerPixel = newSecondsPerScreenWidth / newWidth;
    DateTime newMiddleCursor = middleCursor ?? this.middleCursor;
    return InteractiveTimelineState(
      width: newWidth,
      height: height ?? this.height,
      secondsPerPixel: newSecondsPerPixel,
      secondsPerScreenWidth: newSecondsPerScreenWidth,
      secondsPerScreenWidthBeforeZoom: secondsPerScreenWidthBeforeZoom ?? this.secondsPerScreenWidthBeforeZoom,
      middleCursor: middleCursor ?? this.middleCursor,
      leftCursor: _calculateLeftCursor(newWidth, newSecondsPerPixel, newMiddleCursor),
      rightCursor: _calculateRightCursor(newWidth, newSecondsPerPixel, newMiddleCursor),
      minCursor: minCursor ?? this.minCursor,
      maxCursor: maxCursor ?? this.maxCursor,
      playTimer: playTimer ?? this.playTimer,
      isPlaying: isPlaying ?? this.isPlaying,
      isInteracting: isInteracting ?? this.isInteracting,
    );
  }
}

class InteractiveTimelineBlocBuilder extends StatelessWidget {
  final InteractiveTimelineCubit bloc;
  final Widget Function(BuildContext, InteractiveTimelineState) builder;
  const InteractiveTimelineBlocBuilder({
    Key? key,
    required this.bloc,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractiveTimelineCubit, InteractiveTimelineState>(
      bloc: bloc,
      builder: builder,
    );
  }
}
