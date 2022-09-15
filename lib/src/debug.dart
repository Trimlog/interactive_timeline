import 'package:flutter/material.dart';
import 'package:interactive_timeline/interactive_timeline.dart';

class InteractiveTimelineDebug extends StatelessWidget {
  const InteractiveTimelineDebug({
    Key? key,
    required this.cubit,
  }) : super(key: key);
  final InteractiveTimelineCubit cubit;

  @override
  Widget build(BuildContext context) {
    return InteractiveTimelineBlocBuilder(
      bloc: cubit,
      builder: (context, state) {
        return Column(
          children: [
            Text('width: ${state.width}'),
            Text('height: ${state.height}'),
            Text('secondsPerPixel: ${state.secondsPerPixel}'),
            Text('secondsPerScreenWidth: ${state.secondsPerScreenWidth}'),
            Text('secondsPerScreenWidthBeforeZoom: ${state.secondsPerScreenWidthBeforeZoom}'),
            Text('middleCursor: ${state.middleCursor}'),
            Text('leftCursor: ${state.leftCursor}'),
            Text('rightCursor: ${state.rightCursor}'),
            Text('minCursor: ${state.minCursor}'),
            Text('maxCursor: ${state.maxCursor}'),
            Text('playTimer: ${state.playTimer}'),
            Text('isPlaying: ${state.isPlaying}'),
            Text('isInteracting: ${state.isInteracting}'),
          ],
        );
      },
    );
  }
}
