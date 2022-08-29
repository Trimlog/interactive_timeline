import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interactive_timeline/interactive_timeline.dart';

class PlayButton extends StatelessWidget {
  TimelineCubit timelineCubit;
  PlayButton({
    Key? key,
    required this.timelineCubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineCubit, TimelineState>(
      bloc: timelineCubit,
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () => state.isPlaying ? timelineCubit.stopTimer() : timelineCubit.startTimer(),
          child: Text(
            state.isPlaying ? 'Pause' : 'Play',
          ),
        );
      },
    );
  }
}
