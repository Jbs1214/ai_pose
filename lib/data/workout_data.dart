// lib/data/workout_data.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 운동 데이터: 운동 그룹별 [도구 : [운동 목록]] 구조
final Map<String, Map<String, List<String>>> workoutData = {
  '하체': {
    '바벨': [
      '스쿼트',
      '데드리프트',
      '프론트 스쿼트',
      '바벨 런지',
      '굿모닝',
      '바벨 힙 쓰러스트',
      '오버헤드 스쿼트',
      '스내치',
    ],
    '덤벨': [
      '덤벨 런지',
      '덤벨 스플릿 스쿼트',
      '덤벨 데드리프트',
      '덤벨 스텝업',
      '덤벨 가블렛 스쿼트',
      '덤벨 카프 레이즈',
    ],
    '머신': [
      '레그 프레스',
      '레그 익스텐션',
      '레그 컬',
      '스미스 머신 스쿼트',
      '핵 스쿼트',
      '힙 어브덕터 머신',
    ],
    '케이블': [
      '케이블 킥백',
      '케이블 스쿼트',
    ],
    '맨몸': [
      '점프 스쿼트',
      '불가리안 스플릿 스쿼트',
      '싱글 레그 데드리프트',
      '카프 레이즈',
      '월 싯',
      '글루트 브릿지',
    ],
  },
  '등': {
    '바벨': [
      '바벨 로우',
      '데드리프트',
      'T바 로우',
      '바벨 풀오버',
      '바벨 슈러그',
      '스내치',
    ],
    '덤벨': [
      '덤벨 로우',
      '덤벨 풀오버',
      '원암 덤벨 로우',
      '덤벨 슈러그',
      '덤벨 리어 델트 로우',
    ],
    '머신': [
      '렛 풀다운',
      '시티드 로우',
      '리버스 플라이 머신',
      '허리 익스텐션 머신',
      '어시스티드 풀업 머신',
    ],
    '케이블': [
      '케이블 랫 풀다운',
      '케이블 로우',
      '케이블 풀오버',
      '케이블 페이스 풀',
      '케이블 스트레이트 암 풀다운',
    ],
    '맨몸': [
      '풀업',
      '친업',
      '슈퍼맨 익스텐션',
      '행잉 레그 레이즈',
      '리버스 플라이',
      '브릿지',
    ],
  },
  '가슴': {
    '바벨': [
      '벤치프레스',
      '스미스 머신 벤치프레스',
    ],
    '덤벨': [
      '덤벨 플라이',
      '덤벨 풀오버',
      '덤벨 인클라인 프레스',
      '덤벨 네거티브 벤치프레스',
    ],
    '머신': [
      '체스트 프레스',
      '펙 덱 머신',
      '인클라인 체스트 프레스',
      '머신 플라이',
      '스미스 머신 인클라인 프레스',
    ],
    '케이블': [
      '케이블 크로스오버',
      '케이블 플라이',
      '케이블 프레스',
      '케이블 풀오버',
    ],
    '맨몸': [
      '푸쉬업',
      '딥스',
      '디클라인 푸쉬업',
      '인클라인 푸쉬업',
    ],
  },
  '어깨': {
    '바벨': [
      '바벨 오버헤드 프레스',
      '바벨 프론트 레이즈',
      '바벨 업라이트 로우',
      '바벨 클린 앤 프레스',
    ],
    '덤벨': [
      '덤벨 숄더 프레스',
      '덤벨 레터럴 레이즈',
      '덤벨 리버스 플라이',
      '덤벨 프론트 레이즈',
      '덤벨 아놀드 프레스',
    ],
    '머신': [
      '머신 숄더 프레스',
      '머신 레터럴 레이즈',
      '머신 업라이트 로우',
      '스미스 머신 오버헤드 프레스',
    ],
    '케이블': [
      '케이블 프론트 레이즈',
      '케이블 페이스 풀',
      '케이블 업라이트 로우',
    ],
    '맨몸': [
      '핸드스탠드 푸쉬업',
      '파이크 푸쉬업',
      '버드독',
      '사이드 플랭크',
      '크랩 워크',
    ],
  },
  '팔': {
    '바벨': [
      '바벨 컬',
      '클로즈 그립 벤치프레스',
      '바벨 해머 컬',
      '바벨 리버스 컬',
      '바벨 프리처 컬',
    ],
    '덤벨': [
      '덤벨 컬',
      '덤벨 트라이셉스 익스텐션',
      '덤벨 해머 컬',
      '덤벨 컨센트레이션 컬',
      '덤벨 킥백',
      '덤벨 리버스 컬',
    ],
    '케이블': [
      '케이블 푸쉬다운',
      '케이블 트라이셉스 익스텐션',
      '케이블 프론트 컬',
      '케이블 오버헤드 익스텐션',
    ],
    '머신': [
      // 비어 있음
    ],
    '맨몸': [
      '다이아몬드 푸쉬업',
      '딥스',
      '클로즈 그립 푸쉬업',
    ],
  },
  '유산소': {
    '머신': [
      '사이클',
      '로잉 머신',
      '에어 바이크',
    ],
    '맨몸': [
      '버피',
      '마운틴 클라이머',
      '점핑 잭',
      '하이 니즈',
      '런지 점프',
      '스케이터 점프',
      '플랭크 잭',
    ],
  },
};

/// 특정 운동 이름을 입력하면 어떤 근육 그룹인지 찾는 함수
String getMuscleGroupForWorkout(String workoutName) {
  for (var muscleGroup in workoutData.keys) {
    final Map<String, List<String>> toolMap = workoutData[muscleGroup]!;
    for (var tool in toolMap.keys) {
      final List<String> workouts = toolMap[tool]!;
      if (workouts.contains(workoutName)) {
        return muscleGroup;
      }
    }
  }
  return '전체';
}

/// 운동 이름을 받아서 해당 운동의 GIF(또는 PNG) 썸네일 위젯을 반환
/// 운동 썸네일 위젯
Widget buildWorkoutThumbnail(String workoutName) {
  switch (workoutName) {
    case "데드리프트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/deadlift.gif');
    case "바벨 힙 쓰러스트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/barbell_hip_thrust.gif');
    case "바벨 런지":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/barbell_lunge.gif');
    case "불가리안 스플릿 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/bulgarian_split_squat.gif');
    case "카프 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/calf_raise.gif');
    case "레그 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/leg_curl.gif');
    case "덤벨 카프 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/dumbbell_calf_raise.gif');
    case "덤벨 가블렛 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/dumbbell_goblet_squat.gif');
    case "덤벨 데드리프트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/dumbell_deadlift.gif');
    case "덤벨 런지":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/dumbell_lunge.gif');
    case "덤벨 스플릿 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/dumbell_split_squat.gif');
    case "덤벨 스텝업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/dumbell_stepup.gif');
    case "프론트 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/front_squat.gif');
    case "글루트 브릿지":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/glute_bridge.gif');
    case "굿모닝":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/good_morning.gif');
    case "핵 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/hack_squat.gif');
    case "점프 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/jump_squat.gif');
    case "레그 익스텐션":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/leg_extension.gif');
    case "레그 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/leg_press.gif');
    case "오버헤드 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/overhead_squat.gif');
    case "싱글 레그 데드리프트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/singele_leg_deadlift.gif');
    case "스미스 머신 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/smith_machine_squat.gif');
    case "스내치":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/snach.gif');
    case "스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/squat.gif');
    case "월 싯":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/wall_sit.gif');
    case "힙 어브덕터 머신":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/leg/hip-adductor-machine.gif');
    case "케이블 킥백":
      return const WorkoutGifThumbnail(assetPath: 'assets/images/cable-kick-back.png');
    case "케이블 스쿼트":
      return const WorkoutGifThumbnail(assetPath: 'assets/images/cable-squat.png');
  // 팔
    case "바벨 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/barbell_curl.gif');
    case "클로즈 그립 벤치프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/barbell_close_grip_press.gif');
    case "바벨 해머 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/barbell_curl.gif');
    case "바벨 프리처 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/barbell_preacher_curl.gif');
    case "바벨 리버스 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/barbell_reverse_curl.gif');
    case "케이블 프론트 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/cable_front_curl.gif');
    case "케이블 오버헤드 익스텐션":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/cable_overhead_extension.gif');
    case "케이블 푸쉬다운":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/cable_push_down.gif');
    case "케이블 트라이셉스 익스텐션":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/cable_triceps_extension.gif');
    case "클로즈 그립 푸쉬업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/close_grip_pushup.gif');
    case "다이아몬드 푸쉬업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/diamond_push_up.gif');
    case "딥스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/dips.gif');
    case "덤벨 컨센트레이션 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/dumbbell_concentration_curl.gif');
    case "덤벨 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/dumbbell_curl.gif');
    case "덤벨 해머 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/dumbbell_hammer_curl.gif');
    case "덤벨 킥백":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/dumbbell_kick_back.gif');
    case "덤벨 리버스 컬":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/dumbbell_reverse_curl.gif');
    case "덤벨 트라이셉스 익스텐션":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/arm/dumbbell_triceps_extension.gif');
  // 등
    case "어시스티드 풀업 머신":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/assisted_pull_up.gif');
    case "허리 익스텐션 머신":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/back_extension_machine.gif');
    case "바벨 슈러그":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/barbell-shrugs.gif');
    case "바벨 풀오버":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/barbell_pullover.gif');
    case "바벨 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/barbell_row.gif');
    case "브릿지":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/bridge.gif');
    case "케이블 페이스 풀":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/cable_facepull.gif');
    case "케이블 랫 풀다운":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/cable_lat_pull_down.gif');
    case "케이블 풀오버":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/cable_pull_over.gif');
    case "케이블 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/cable_row.gif');
    case "친업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/chin_up.gif');
    case "덤벨 리어 델트 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/dumbbell_lear_delt_row.gif');
    case "덤벨 풀오버":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/dumbbell_pullover.gif');
    case "덤벨 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/dumbbell_row.gif');
    case "덤벨 슈러그":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/dumbbell_shrug.gif');
    case "행잉 레그 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/hanging_legraises.gif');
    case "렛 풀다운":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/lat_pulldown.gif');
    case "원암 덤벨 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/one_arm_dumbbell_row.gif');
    case "풀업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/pull_up.gif');
    case "리버스 플라이":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/reverse_fly.gif');
    case "리버스 플라이 머신":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/reverse_fly_machine.gif');
    case "시티드 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/seated_row.gif');
    case "케이블 스트레이트 암 풀다운":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/straight_arm_pulldown.gif');
    case "슈퍼맨 익스텐션":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/superman_extension.gif');
    case "T바 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/tbar_row.gif');
    case "스내치":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/back/snatch.gif');
  // 유산소
    case "에어 바이크":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/air_bike.gif');
    case "사이클":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/bicycle.gif');
    case "버피":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/burpee.gif');
    case "하이 니즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/high_knees.gif');
    case "점핑 잭":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/jumping_jack.gif');
    case "런지 점프":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/lunge_jump.gif');
    case "마운틴 클라이머":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/mountain_climer.gif');
    case "플랭크 잭":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/plank_jack.gif');
    case "로잉 머신":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/rowing_machine.gif');
    case "러닝 머신":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/running_machine.gif');
    case "스케이터 점프":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/cardio/skater_squat.gif');
  // 가슴
    case "벤치프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/BB.gif');
    case "바벨 벤치 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/barbell_bench_press.gif');
    case "바벨 디클라인 벤치 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/barbell_decline_bench_press.gif');
    case "바벨 인클라인 벤치 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/barbell_incline_bench_press.gif');
    case "케이블 크로스오버":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/cable_crossover.gif');
    case "케이블 플라이":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/cable_fly.gif');
    case "케이블 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/cable_press.gif');
    case "케이블 풀오버":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/cable_pullover.gif');
    case "디클라인 푸쉬업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/decline_push_up.gif');
    case "딥스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/dips.gif');
    case "덤벨 벤치 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/dumbbell_bench_press.gif');
    case "덤벨 플라이":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/dumbbell_fly.gif');
    case "덤벨 인클라인 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/dumbbell_incline_press.gif');
    case "덤벨 네거티브 벤치프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/dumbbell_negative_bench_press.gif');
    case "덤벨 풀오버":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/dumbbell_pullover.gif');
    case "인클라인 푸쉬업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/incline_push_up.gif');
    case "체스트 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/machine_chest_press.gif');
    case "머신 플라이":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/machine_fly.gif');
    case "인클라인 체스트 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/machine_incline_chest_press.gif');
    case "펙 덱 머신":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/machine_peck_deck_fly.gif');
    case "푸쉬업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/push_up.gif');
    case "스미스 머신 벤치프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/smith_machine_bench_press.gif');
    case "스미스 머신 인클라인 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/chest/smith_machine_incline_press.gif');
  // 어깨
    case "바벨 오버헤드 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/barbell-overhead-press.gif');
    case "바벨 업라이트 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/barbell-upright-row.gif');
    case "바벨 클린 앤 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/barbell_clean_and_press.gif');
    case "바벨 프론트 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/barbell_front-raise.gif');
    case "바벨 리버스 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/barbell_reverse_raises.gif');
    case "버드독":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/bird-dog.gif');
    case "케이블 페이스 풀":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/cable-face-pull.gif');
    case "케이블 프론트 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/cable-front-raises.gif');
    case "케이블 리버스 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/cable-reverse-fly.gif');
    case "케이블 업라이트 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/cable-upright-row.gif');
    case "크랩 워크":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/crab-walk.gif');
    case "덤벨 아놀드 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/dumbbell-arnold-press.gif');
    case "덤벨 프론트 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/dumbbell-front-raise.gif');
    case "덤벨 레터럴 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/dumbbell-lateral-raises.gif');
    case "덤벨 리버스 플라이":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/dumbbell-reverse-fly.gif');
    case "덤벨 숄더 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/dumbbell_shoulder_press.gif');
    case "핸드스탠드 푸쉬업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/handstand-push-up.gif');
    case "머신 레터럴 레이즈":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/machine-lateral-raise.gif');
    case "머신 숄더 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/machine-shoulder-press.gif');
    case "머신 업라이트 로우":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/machine-upright-row.gif');
    case "파이크 푸쉬업":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/pike-push-up.gif');
    case "사이드 플랭크":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/side-plankn.gif');
    case "스미스 머신 오버헤드 프레스":
      return const WorkoutGifThumbnail(assetPath: 'assets/video/shoulder/smith-machine-overhead-press.gif');
    default:
      return const SizedBox(width: 50, height: 40);
  }
}

/// 운동 썸네일을 표시하는 공통 위젯
class WorkoutGifThumbnail extends StatelessWidget {
  final String assetPath;
  const WorkoutGifThumbnail({Key? key, required this.assetPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 40,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
      ),
    );
  }
}