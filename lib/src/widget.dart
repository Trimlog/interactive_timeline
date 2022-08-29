import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../interactive_timeline.dart';
import 'canvas.dart';

class InteractiveTimeline extends StatefulWidget {
  double width;
  double height;
  TimelineCubit cubit;
  TimelineRenderOptions renderOptions;
  InteractiveTimeline({
    Key? key,
    required this.width,
    required this.height,
    required this.cubit,
    this.renderOptions = const TimelineRenderOptions(),
  }) : super(key: key);

  @override
  State<InteractiveTimeline> createState() => _InteractiveTimelineState();
}

class _InteractiveTimelineState extends State<InteractiveTimeline> {
  @override
  void initState() {
    widget.cubit.initialize(widget.width, widget.height);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: GestureDetector(
        onHorizontalDragUpdate: widget.cubit.dragHorizontally,
        onVerticalDragUpdate: widget.cubit.dragVertically,
        child: BlocBuilder<TimelineCubit, TimelineState>(
          bloc: widget.cubit,
          builder: (context, state) {
            return Column(children: [
              Container(
                width: widget.width,
                height: widget.height,
                padding: EdgeInsets.symmetric(vertical: widget.renderOptions.candleWidth / 2),
                child: CustomPaint(
                  painter: TimelinePainter(
                    state: state,
                    renderOptions: widget.renderOptions,
                  ),
                  size: Size.infinite,
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
