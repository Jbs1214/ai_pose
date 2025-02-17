import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'workout_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    final availableCamerasList = await availableCameras();
    setState(() {
      cameras = availableCamerasList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('나의 운동'),
      ),
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
                            '01.24. 금요일',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoButton.filled(
                            child: const Text('오늘의 운동 시작하기'),
                            onPressed: cameras == null
                                ? null // 카메라 로딩 중일 때 버튼 비활성화
                                : () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => WorkoutSelectionPage(cameras: cameras!),
                                ),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.black,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 루틴 예시 아이템
                          _buildRoutineItem(
                            context,
                            title: '등 하체',
                            subtitle: '등, 이두',
                            timeAgo: '20시간 전',
                          ),
                          const SizedBox(height: 12),
                          _buildRoutineItem(
                            context,
                            title: '가슴',
                            subtitle: '가슴, 삼두',
                            timeAgo: '약 1일 전',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // "+추가" 버튼
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 8,
              ),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () => _showAddMenu(context),
                  child: const Text('+추가'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "내 루틴" 개별 아이템
  Widget _buildRoutineItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String timeAgo,
      }) {
    return Container(
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.activeGreen,
                  ),
                ),
              ],
            ),
          ),

          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.ellipsis,
              color: CupertinoColors.systemGrey,
              size: 24,
            ),
            onPressed: () => _showAddMenu(context),
          ),
        ],
      ),
    );
  }

  /// "+추가" 버튼 팝업
  void _showAddMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('새로운 항목 추가'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 나만의 루틴 추가 로직
              },
              child: const Text('나만의 루틴 추가'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 운동 계획 추가 로직
              },
              child: const Text('운동 계획 추가'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        );
      },
    );
  }
}
