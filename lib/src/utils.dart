import 'package:flutter/material.dart';

enum CandleAlignment {
  top,
  center,
  bottom,
}

const defaultCandleGroups = [
  [Duration(milliseconds: 250), Duration(seconds: 1)],
  [Duration(seconds: 1), Duration(seconds: 5)],
  [Duration(seconds: 2), Duration(seconds: 10)],
  [Duration(seconds: 4), Duration(seconds: 20)],
  [Duration(seconds: 5), Duration(seconds: 30)],
  [Duration(seconds: 10), Duration(seconds: 60)],
  [Duration(seconds: 20), Duration(seconds: 120)],
  [Duration(seconds: 30), Duration(seconds: 180)],
  [Duration(seconds: 40), Duration(seconds: 240)],
  [Duration(minutes: 1), Duration(minutes: 5)],
  [Duration(minutes: 2), Duration(minutes: 10)],
  [Duration(minutes: 4), Duration(minutes: 20)],
  [Duration(minutes: 5), Duration(minutes: 30)],
  [Duration(minutes: 10), Duration(minutes: 60)],
  [Duration(minutes: 20), Duration(minutes: 120)],
  [Duration(minutes: 30), Duration(minutes: 180)],
  [Duration(minutes: 40), Duration(minutes: 240)],
];

class TimelineRenderOptions {
  final CandleAlignment candleAlignment;
  final double candleWidth;
  final Color candleColor;
  final double smallCandleSizeFactor;
  final double minCandleGap;
  final List<List<Duration>> candleGroups;
  const TimelineRenderOptions({
    this.candleAlignment = CandleAlignment.center,
    this.candleWidth = 10, // Pixels
    this.candleColor = Colors.black, // Color
    this.smallCandleSizeFactor = 2 / 3, // 66% off height
    this.minCandleGap = 20, // Pixels
    this.candleGroups = defaultCandleGroups,
  });
}

bool insideMinMaxCursor(DateTime time, DateTime? minCursor, DateTime? maxCursor) {
  if (minCursor != null) if (time.isBefore(minCursor)) return false;
  if (maxCursor != null) if (time.isAfter(maxCursor)) return false;
  return true;
}

DateTime cropMinMaxCursor(DateTime cursor, DateTime? minCursor, DateTime? maxCursor) {
  if (minCursor != null) if (cursor.isBefore(minCursor)) return minCursor;
  if (maxCursor != null) if (cursor.isAfter(maxCursor)) return maxCursor;
  return cursor;
}
