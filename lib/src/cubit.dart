import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// timeline cubit
class TimelineCubit extends Cubit<TimelineState> {
  double minSecondsPerScreenWidth; // Min seconds per screen width
  double maxSecondsPerScreenWidth; // Max seconds per screen width
  Duration timerUpdateInterval; // Milliseconds
  double initialZoomLevel; // Seconds per screen width
  DateTime? initialTime;
  TimelineCubit({
    this.minSecondsPerScreenWidth = 10,
    this.maxSecondsPerScreenWidth = 10000,
    this.timerUpdateInterval = const Duration(milliseconds: 25),
    this.initialZoomLevel = 500,
    this.initialTime,
  }) : super(
          TimelineState.initializeAtTime(
            initialTime ?? DateTime.now(),
          ),
        );

  void updateZoomLevel(num delta) {
    double secondsPerScreenWidth = max(
      min(
        state.secondsPerScreenWidth + delta * state.secondsPerPixel,
        maxSecondsPerScreenWidth,
      ),
      minSecondsPerScreenWidth,
    );
    emit(state.overwrite(secondsPerScreenWidth: secondsPerScreenWidth));
  }

  void dragHorizontally(DragUpdateDetails update) {
    num offsetSeconds = update.primaryDelta! * state.secondsPerPixel;
    emit(state.overwrite(
      middleCursor: state.middleCursor.subtract(
        Duration(milliseconds: (offsetSeconds * 1000).toInt()),
      ),
    ));
  }

  void dragVertically(DragUpdateDetails update) {
    updateZoomLevel(update.primaryDelta! * 1);
  }

  void startTimer() {
    if (state.isPlaying == false) {
      emit(state.overwrite(
          playTimer: Timer.periodic(
            timerUpdateInterval,
            (Timer t) => tickTimer(timerUpdateInterval),
          ),
          isPlaying: true));
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

  void tickTimer(Duration duration) {
    double timerMilliesecondsPerScreenWidth = 10 * 1000; // timer scroll speed
    double deltaScreenWidth = duration.inMilliseconds / timerMilliesecondsPerScreenWidth;
    Duration deltaCursor = Duration(milliseconds: (deltaScreenWidth * state.secondsPerScreenWidth * 1000).toInt());
    emit(state.overwrite(
      middleCursor: state.middleCursor.add(deltaCursor),
    ));
  }

  void initialize(double width, double height) {
    emit(state.overwrite(
      secondsPerScreenWidth: initialZoomLevel, // default zoom level
      middleCursor: initialTime,
      width: width,
      height: height,
    ));
  }
}

class TimelineState extends Equatable {
  const TimelineState(
      {required this.width,
      required this.height,
      required this.secondsPerPixel,
      required this.secondsPerScreenWidth,
      required this.middleCursor,
      required this.leftCursor,
      required this.rightCursor,
      required this.playTimer,
      required this.isPlaying})
      : super();

  final double width;
  final double height;
  final double secondsPerPixel;
  final double secondsPerScreenWidth;
  final DateTime middleCursor;
  final DateTime leftCursor;
  final DateTime rightCursor;
  final Timer? playTimer;
  final bool isPlaying;

  @override
  List<Object> get props => [width, height, secondsPerPixel, secondsPerScreenWidth, middleCursor, leftCursor, rightCursor, isPlaying];

  static TimelineState initializeAtTime(DateTime time) {
    return TimelineState(
      width: 0,
      height: 0,
      secondsPerPixel: 0,
      secondsPerScreenWidth: 0,
      middleCursor: time,
      leftCursor: time,
      rightCursor: time,
      playTimer: null,
      isPlaying: false,
    );
  }

  DateTime getLeftCursor(double width, double secondsPerPixel) {
    return middleCursor.subtract(
      Duration(milliseconds: ((width / 2) * secondsPerPixel * 1000).toInt()),
    );
  }

  DateTime getRightCursor(double width, double secondsPerPixel) {
    return middleCursor.add(
      Duration(milliseconds: ((width / 2) * secondsPerPixel * 1000).toInt()),
    );
  }

  TimelineState overwrite({
    double? width,
    double? height,
    double? secondsPerScreenWidth,
    DateTime? middleCursor,
    Timer? playTimer,
    bool? isPlaying,
  }) {
    double newSecondsPerScreenWidth = secondsPerScreenWidth ?? this.secondsPerScreenWidth;
    double newWidth = width ?? this.width;
    double newSecondsPerPixel = newSecondsPerScreenWidth / newWidth;
    return TimelineState(
      width: newWidth,
      height: height ?? this.height,
      secondsPerPixel: newSecondsPerPixel,
      secondsPerScreenWidth: newSecondsPerScreenWidth,
      middleCursor: middleCursor ?? this.middleCursor,
      leftCursor: getLeftCursor(width ?? this.width, newSecondsPerPixel),
      rightCursor: getRightCursor(width ?? this.width, newSecondsPerPixel),
      playTimer: playTimer ?? this.playTimer,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
