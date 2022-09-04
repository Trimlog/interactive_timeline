import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../interactive_timeline.dart';
import 'canvas.dart';

class InteractiveTimeline extends StatefulWidget {
  double width;
  double height;
  InteractiveTimelineCubit cubit;
  TimelineRenderOptions renderOptions;
  EdgeInsets padding;
  Color color;
  InteractiveTimeline({
    Key? key,
    required this.width,
    required this.height,
    required this.cubit,
    this.renderOptions = const TimelineRenderOptions(),
    this.padding = const EdgeInsets.all(0),
    this.color = Colors.transparent,
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
        onHorizontalDragEnd: (_) => widget.cubit.setInteraction(false),
        onHorizontalDragCancel: () => widget.cubit.setInteraction(false),
        onScaleStart: widget.cubit.zoomStart,
        onScaleUpdate: widget.cubit.zoomUpdate,
        onScaleEnd: widget.cubit.zoomEnd,
        onTap: () => widget.cubit.toggleTimer(),
        child: BlocBuilder<InteractiveTimelineCubit, InteractiveTimelineState>(
          bloc: widget.cubit,
          builder: (context, state) => Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            color: widget.color,
            child: CustomPaint(
              painter: TimelinePainter(
                state: state,
                renderOptions: widget.renderOptions,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
