import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ui_project_pratices/bottomSheet/song.dart';
import 'package:ui_project_pratices/bottomSheet/songContainer.dart';

class BottomSheetTransition extends StatefulWidget {
  const BottomSheetTransition({super.key});

  @override
  State<BottomSheetTransition> createState() => _BottomSheetTransitionState();
}

class _BottomSheetTransitionState extends State<BottomSheetTransition>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  double get maxHeight => MediaQuery.of(context).size.height - 40;
  double songImgStartSize = 45;
  double songImgEndSize = 120;
  double songVerticalSpace = 25;
  double songHorizontalSpace = 15;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  double? lerp(double min, double max) {
    return lerpDouble(min, max, controller!.value);
  }
  void toggle()
  {
    final bool  isCompleted=controller!.status==AnimationStatus.completed;
    controller!.fling(velocity: isCompleted?-1:1);
  }

  void verticalDragUpdate(DragUpdateDetails details)
  {
    controller!.value-=details.primaryDelta! / maxHeight;
  }

  void verticalDragEnd(DragEndDetails details)
  {
    if(controller!.isAnimating || controller!.status == AnimationStatus.completed) return;

    final double flingVelocity=  details.velocity.pixelsPerSecond.dy / maxHeight;

    if(flingVelocity <0)
      {
        controller!.fling(velocity: math.max(1,-flingVelocity));
      }
    else if( flingVelocity >0)
      {
        controller!.fling(velocity: math.min(-1, -flingVelocity));
      }
    else {
      controller!.fling(velocity: controller!.value < 0.5 ? -1 : 1);
    }


  }

  double? songTopMargin(int index)
  {
    return lerp(20,10+index*(songVerticalSpace+songImgEndSize));
  }
  double? songLeftMargin(int index) {
    return lerp(index * (songHorizontalSpace + songImgStartSize), 0);
  }

  Widget buildSongContainer(Song song)
  {
    int index = songs.indexOf(song);
    return SongContainer(
      song: song,
      imgSize: lerp(songImgStartSize, songImgEndSize),
      topMargin: songTopMargin(index),
      leftMargin: songLeftMargin(index),
      isCompleted: controller!.status == AnimationStatus.completed,
    );
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: lerp(120, maxHeight),
          child: GestureDetector(
            onTap: toggle,
            onVerticalDragUpdate: verticalDragUpdate,
            onVerticalDragEnd: verticalDragEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Color(0xff920201),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: lerp(20, 40),
                    child: Row(
                      children: [
                        Text(
                          'Popular Songs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: lerp(15, 25),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          controller!.status == AnimationStatus.completed
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: Colors.white,
                          size: lerp(15, 25),
                        )
                      ],
                    ),

                  ),
                  Positioned(
                      top: lerp(35, 80),
                      bottom: 0,
                      left: 0,
                      right: 0,
                    child: SingleChildScrollView(
                      scrollDirection: controller!.status==AnimationStatus.completed?Axis.vertical:Axis.horizontal,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()
                      ),
                      child: Container(
                        height:
                        (songImgEndSize + songVerticalSpace) * songs.length,
                        width: (songImgStartSize + songHorizontalSpace) *
                            songs.length,
                        child: Stack(
                          children: [
                            for (Song song in songs) buildSongContainer(song),
                          ],
                        ),
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
