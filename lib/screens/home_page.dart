import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_selection_page.dart';
import 'package:motion_recognition_app/data/workout_data.dart';
///import 'package:motion_recognition_app/screens/routine_content_page.dart';


/// HomePage: +추가 버튼을 누르면 RoutineDetailPage에서 선택한 운동들을 하나의 루틴으로 추가하고,
/// 내 루틴 목록은 이름 수정, 삭제가 가능하며 SharedPreferences로 영구 저장됩니다.
/// 사용자가 생성한 루틴을 누르면 해당 루틴의 운동 및 이미지를 보여주는 RoutineContentPage로 이동합니다.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// 루틴 정보를 담는 간단한 구조:
/// - title: 루틴 이름 (사용자가 수정 가능)
/// - subtitle: 초록 글씨로 표시될 내용 (운동 부위 목록)
/// - workouts: 실제 운동 리스트
/// - timeAgo: 생성/업데이트 시간
class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _addedRoutines = [];

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _saveRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('addedRoutines', jsonEncode(_addedRoutines));
  }

  Future<void> _loadRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final String? routinesString = prefs.getString('addedRoutines');
    if (routinesString != null) {
      final List<dynamic> routinesJson = jsonDecode(routinesString);
      setState(() {
        _addedRoutines.clear();
        _addedRoutines.addAll(
          routinesJson.map((e) => e as Map<String, dynamic>).toList(),
        );
      });
    }
  }

  /// 선택한 운동들에서 각 운동의 근육군 추출 (중복 제거)
  List<String> _extractMuscleGroups(List<String> workouts) {
    final Set<String> muscleGroupSet = {};
    for (final w in workouts) {
      final group = getMuscleGroupForWorkout(w);
      if (group != '전체') {
        muscleGroupSet.add(group);
      }
    }
    return muscleGroupSet.toList();
  }

  /// 루틴 이름 수정 대화상자 (취소/확인 버튼 모두 동작)
  void _showRenameDialog(BuildContext context, int index) {
    final TextEditingController controller = TextEditingController(
      text: _addedRoutines[index]['title'],
    );
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text("루틴 이름 수정"),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CupertinoTextField(
              controller: controller,
              placeholder: "새로운 루틴 이름 입력",
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("취소"),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // 대화상자 닫기
                }
              },
            ),
            CupertinoDialogAction(
              child: const Text("확인"),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      _addedRoutines[index]['title'] = controller.text.trim();
                    });
                    _saveRoutines();
                  }
                }
                Future.delayed(const Duration(milliseconds: 250), () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // 딜레이 후 대화상자 닫기
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// 루틴 옵션 팝업 (ActionSheet)
  /// 사용자 루틴(isCustom == true)인 경우 이름 수정 및 삭제 가능
  void _showRoutineOptions(
      BuildContext context, {
        required String routineTitle,
        required int? index,
        required bool isCustom,
      }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            routineTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            _buildAction(
              context,
              icon: CupertinoIcons.pencil,
              text: '이름 수정',
              onTap: () {
                Navigator.pop(context);
                if (isCustom && index != null) {
                  _showRenameDialog(context, index);
                }
              },
            ),
            _buildAction(
              context,
              icon: CupertinoIcons.trash,
              text: '루틴 삭제',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                if (isCustom && index != null) {
                  setState(() {
                    _addedRoutines.removeAt(index);
                  });
                  _saveRoutines();
                }
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text('취소'),
          ),
        );
      },
    );
  }

  /// ActionSheet 항목 생성 (기존 로직 그대로)
  Widget _buildAction(
      BuildContext context, {
        required IconData icon,
        required String text,
        bool isDestructive = false,
        required VoidCallback onTap,
      }) {
    return CupertinoActionSheetAction(
      isDestructiveAction: isDestructive,
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? CupertinoColors.destructiveRed : CupertinoColors.black,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// "내 루틴" 개별 아이템 생성
  /// - isCustom가 true이면, 해당 루틴을 탭하면 RoutineContentPage로 이동하여 루틴 내용을 보여줌
  Widget _buildRoutineItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String timeAgo,
        required int? index,
        required bool isCustom,
      }) {
    Widget item = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.flame_fill,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: CupertinoColors.activeGreen),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.ellipsis, color: CupertinoColors.systemGrey, size: 24),
            onPressed: () => _showRoutineOptions(
              context,
              routineTitle: title,
              index: index,
              isCustom: isCustom,
            ),
          ),
        ],
      ),
    );
    // 사용자 생성 루틴이면 전체 아이템을 탭할 때 해당 루틴의 상세 내용을 보여주는 페이지로 이동
    if (isCustom && index != null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => RoutineContentPage(routine: _addedRoutines[index]),
            ),
          );
        },
        child: item,
      );
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('나의 운동')),
      child: SafeArea(
        child: Column(
          children: [
            // 루틴 리스트 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 날짜와 "오늘의 운동 시작하기" 버튼
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '2.20. 목요일',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          CupertinoButton.filled(
                            child: const Text('오늘의 운동 시작하기'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(builder: (_) => const WorkoutSelectionPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // "내 루틴" 섹션
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '내 루틴',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.black),
                          ),
                          const SizedBox(height: 16),
                          _buildRoutineItem(context, title: '등 하체', subtitle: '등, 이두', timeAgo: '20시간 전', index: null, isCustom: false),
                          const SizedBox(height: 12),
                          _buildRoutineItem(context, title: '가슴', subtitle: '가슴, 삼두', timeAgo: '약 1일 전', index: null, isCustom: false),
                          const SizedBox(height: 12),
                          for (int i = 0; i < _addedRoutines.length; i++) ...[
                            _buildRoutineItem(
                              context,
                              title: _addedRoutines[i]['title'],
                              subtitle: _addedRoutines[i]['subtitle'],
                              timeAgo: _addedRoutines[i]['timeAgo'],
                              index: i,
                              isCustom: true,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // "+추가" 버튼 → RoutineDetailPage로 이동하여 선택된 운동들을 반환받음
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () async {
                    final selectedWorkouts = await Navigator.push<List<String>>(
                      context,
                      CupertinoPageRoute(builder: (_) => const RoutineDetailPage()),
                    );
                    if (selectedWorkouts != null && selectedWorkouts.isNotEmpty) {
                      final muscleGroups = _extractMuscleGroups(selectedWorkouts);
                      setState(() {
                        _addedRoutines.add({
                          'title': '사용자 루틴 #${_addedRoutines.length + 1}',
                          'subtitle': muscleGroups.join(', '),
                          'workouts': selectedWorkouts,
                          'timeAgo': '방금 전',
                        });
                      });
                      _saveRoutines();
                    }
                  },
                  child: const Text('루틴 추가하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// RoutineDetailPage: 사용자가 여러 운동을 선택하여 HomePage로 반환
class RoutineDetailPage extends StatefulWidget {
  const RoutineDetailPage({super.key});

  @override
  _RoutineDetailPageState createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  String searchQuery = '';
  final Set<String> _selectedWorkouts = {};

  List<Widget> _buildWorkoutList() {
    List<Widget> widgets = [];
    workoutData.forEach((muscleGroup, toolMap) {
      List<Widget> muscleGroupWidgets = [];
      toolMap.forEach((tool, workouts) {
        final List<String> filteredWorkouts = workouts.where((workout) {
          return workout.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
        if (filteredWorkouts.isNotEmpty) {
          muscleGroupWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                tool,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
          for (String workout in filteredWorkouts) {
            final isSelected = _selectedWorkouts.contains(workout);
            muscleGroupWidgets.add(
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedWorkouts.remove(workout);
                    } else {
                      _selectedWorkouts.add(workout);
                    }
                  });
                },
                child: Container(
                  color: isSelected ? CupertinoColors.systemGrey5.withOpacity(0.4) : null,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildWorkoutThumbnail(workout),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          workout,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (isSelected)
                        const Icon(CupertinoIcons.check_mark_circled_solid, color: CupertinoColors.activeGreen),
                    ],
                  ),
                ),
              ),
            );
          }
          muscleGroupWidgets.add(const SizedBox(height: 8));
        }
      });
      if (muscleGroupWidgets.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              muscleGroup,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
        widgets.addAll(muscleGroupWidgets);
        widgets.add(
          Container(
            height: 1,
            color: CupertinoColors.systemGrey4,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      }
    });
    if (widgets.isEmpty && searchQuery.isNotEmpty) {
      widgets.add(
        Center(
          child: Text(
            '검색 결과가 없습니다.',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedWorkouts.length;
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('루틴 상세'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                placeholder: '운동 이름 검색',
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _buildWorkoutList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: selectedCount == 0
                      ? null
                      : () {
                    Navigator.pop(context, _selectedWorkouts.toList());
                  },
                  child: Text('운동 $selectedCount개 추가하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// RoutineContentPage: 사용자가 생성한 루틴을 탭하면, 해당 루틴에 포함된 운동 목록과 이미지를 보여줍니다.
class RoutineContentPage extends StatelessWidget {
  final Map<String, dynamic> routine;
  const RoutineContentPage({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> workouts = routine['workouts'] as List<dynamic>;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(routine['title']),
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index] as String;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  buildWorkoutThumbnail(workout),
                  const SizedBox(width: 8),
                  Text(
                    workout,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}