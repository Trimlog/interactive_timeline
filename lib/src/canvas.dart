import 'package:flutter/material.dart';
import 'package:interactive_timeline/interactive_timeline.dart';

class TimelinePainter extends CustomPainter {
  InteractiveTimelineState state;
  TimelineRenderOptions renderOptions;

  TimelinePainter({
    required this.state,
    required this.renderOptions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()
      ..color = renderOptions.candleColor
      ..strokeWidth = renderOptions.candleWidth
      ..strokeCap = StrokeCap.round;

    List<Duration> candleIntervals = getOptimalCandleIntervals();

    paintCandles(canvas, size, candleIntervals[0], blackPaint, renderOptions.smallCandleSizeFactor, renderOptions.candleAlignment);
    paintCandles(canvas, size, candleIntervals[1], blackPaint, 1, renderOptions.candleAlignment);
  }

  List<Duration> getOptimalCandleIntervals() {
    for (final candleGroup in renderOptions.candleGroups) {
      final candleGap = caluclateCandleGap(candleGroup.first);
      if (candleGap > renderOptions.minCandleGap) {
        // minimum candle gap
        return candleGroup;
      }
    }

    return renderOptions.candleGroups.last;
  }

  double caluclateCandleGap(Duration candleInterval) {
    return (candleInterval.inMilliseconds / 1000) / state.secondsPerPixel;
  }

  void paintCandle(Canvas canvas, Size size, double x, Paint paint, double heightRatio, CandleAlignment candleAlignment) {
    double candleLength = heightRatio * (size.height);
    double candleLineLength = candleLength - renderOptions.candleWidth;
    double halfCandleWidth = renderOptions.candleWidth / 2;
    double halfHeight = size.height / 2;

    switch (candleAlignment) {
      case CandleAlignment.top:
        canvas.drawLine(
          Offset(x, -halfCandleWidth),
          Offset(x, candleLineLength - halfCandleWidth),
          paint,
        );
        break;
      case CandleAlignment.center:
        canvas.drawLine(
          Offset(x, halfHeight - (candleLineLength / 2)),
          Offset(x, halfHeight + (candleLineLength / 2)),
          paint,
        );
        break;
      case CandleAlignment.bottom:
        canvas.drawLine(
          Offset(x, size.height - halfCandleWidth),
          Offset(x, size.height - candleLineLength - halfCandleWidth),
          paint,
        );
        break;
    }
  }

  void paintCandles(Canvas canvas, Size size, Duration interval, Paint paint, double heightRatio, CandleAlignment candleAlignment) {
    getCandlesInFrame(interval).forEach((x) => paintCandle(canvas, size, x, paint, heightRatio, candleAlignment));
  }

  List<double> getCandlesInFrame(Duration interval) {
    // last full minute before cursorLeft
    Duration offset = Duration(milliseconds: state.leftCursor.millisecondsSinceEpoch % interval.inMilliseconds);
    DateTime startTime = state.leftCursor.subtract(offset);
    List<double> minuteCandles = [];
    while (startTime.isBefore(state.rightCursor.add(interval))) {
      minuteCandles.add(timeToPixel(startTime));
      startTime = startTime.add(interval);
    }
    return minuteCandles;
  }

  double timeToPixel(DateTime time) {
    return time.difference(state.leftCursor).inMilliseconds / 1000 / state.secondsPerPixel;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
