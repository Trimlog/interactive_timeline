import 'package:flutter/material.dart';
import 'package:interactive_timeline/interactive_timeline.dart';

class StateVisualizer extends StatelessWidget {
  InteractiveTimelineCubit cubit;
  StateVisualizer({
    Key? key,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InteractiveTimelineBlocBuilder(
      bloc: cubit,
      builder: ((context, state) {
        return Container(
          child: Column(
            children: [
              Text("width: ${state.width}"),
              Text("height: ${state.height}"),
              Text("secondsPerPixel: ${state.secondsPerPixel}"),
              Text("secondsPerScreenWidth: ${state.secondsPerScreenWidth}"),
              Text("secondsPerScreenWidthBeforeZoom: ${state.secondsPerScreenWidthBeforeZoom}"),
              Text("middleCursor: ${state.middleCursor}"),
              Text("leftCursor: ${state.leftCursor}"),
              Text("rightCursor: ${state.rightCursor}"),
              Text("playTimer: ${state.playTimer}"),
              Text("isPlaying: ${state.isPlaying}"),
              Text("isInteracting: ${state.isInteracting}"),
            ],
          ),
        );
      }),
    );
  }
}
