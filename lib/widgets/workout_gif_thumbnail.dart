// lib/widgets/workout_gif_thumbnail.dart

import 'package:flutter/cupertino.dart';

/// WorkoutGifThumbnail
/// - 운동에 해당하는 animated GIF 파일의 썸네일을 보여주는 위젯입니다.
/// - 배경은 흰색으로 채워지며, gaplessPlayback 및 frameBuilder 옵션을 사용해 GIF 애니메이션이 계속 재생되도록 설정합니다.
class WorkoutGifThumbnail extends StatelessWidget {
  final String assetPath;
  const WorkoutGifThumbnail({Key? key, required this.assetPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: CupertinoColors.white, // 배경을 흰색으로 채움
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.asset(
        assetPath,
        gaplessPlayback: true, // GIF 애니메이션이 끊기지 않도록 설정
        frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
          // frame이 null이 아니면 프레임이 업데이트된 것이므로 항상 child를 리턴.
          return child;
        },
        width: 80,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }
}
