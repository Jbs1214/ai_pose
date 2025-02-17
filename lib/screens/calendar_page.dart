// lib/screens/calendar_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 머슬 그룹별 색상 정의 (캘린더 도트 및 범례에 사용)
const Map<String, Color> muscleGroupColors = {
  '하체': Colors.red,
  '등': Colors.blue,
  '가슴': Colors.green,
  '어깨': Colors.yellow,
  '팔': Colors.orange,
  '유산소': Colors.black,
};

/// CalendarPage: TableCalendar를 이용하여 운동 기록을 표시하는 페이지
class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 현재 포커스된 날짜 및 선택된 날짜 (TableCalendar에서 사용)
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Firestore에서 불러온 운동 기록을 날짜별로 저장하는 맵
  // key: (년,월,일) DateTime, value: 운동 기록 리스트
  Map<DateTime, List<Map<String, dynamic>>> _workoutEvents = {};

  @override
  void initState() {
    super.initState();
    _loadMonthlyWorkoutEvents(_focusedDay);
  }

  /// (1) Firestore에서 해당 월의 운동 기록을 불러와 _workoutEvents에 저장
  Future<void> _loadMonthlyWorkoutEvents(DateTime focusedDay) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final start = DateTime(focusedDay.year, focusedDay.month, 1);
    final end = DateTime(focusedDay.year, focusedDay.month + 1, 1);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .get();

      final Map<DateTime, List<Map<String, dynamic>>> events = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final ts = data['date'] as Timestamp;
        // 날짜 키: 시간 정보를 제거한 DateTime 객체 (년,월,일)
        final dateKey = DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day);
        events.putIfAbsent(dateKey, () => []);
        events[dateKey]!.add(data);
      }
      setState(() {
        _workoutEvents = events;
      });
    } catch (e) {
      debugPrint("Error loading monthly events: $e");
    }
  }

  /// (2) 특정 날짜(day)에 해당하는 운동 기록 리스트 반환
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _workoutEvents[dateKey] ?? [];
  }

  /// (3) 날짜 선택 시 상태 업데이트 후 팝업으로 해당 날짜의 운동 기록 표시
  /// 선택 효과는 투명(배경색 없음)으로 처리
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showWorkoutDetailsPopup(selectedDay);
  }

  /// (4) 중앙 팝업으로 선택한 날짜의 운동 기록을 표시
  /// 팝업창 배경은 흰색, 텍스트는 검은색, 폰트 크기는 16, 높이는 내용에 맞게 조정
  void _showWorkoutDetailsPopup(DateTime day) {
    final events = _getEventsForDay(day);
    showDialog(
      context: context,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(minHeight: 150, maxHeight: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // 팝업 배경 흰색
                borderRadius: BorderRadius.circular(12),
              ),
              child: events.isEmpty
                  ? const Center(
                child: Text(
                  "해당 날짜에는 운동 기록이 없습니다.",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${event['workoutName']} | 세트: ${event['setCount']}세트 | 무게: ${event['weight'] ?? '없음'}kg",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// (5) 캘린더 하단에 범례(Legend)를 한 줄로 표시 (캘린더 바로 아래에 붙임)
  Widget _buildLegend() {
    final legendItems = muscleGroupColors.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "${entry.key} 운동",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: legendItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: "캘린더" 텍스트, 흰색 배경, 폰트 크기 20, 중앙 정렬, 검정 텍스트
      appBar: AppBar(
        title: const Text(
          '캘린더',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 캘린더 바로 위에 범례 붙이기
          _buildLegend(),
          // TableCalendar: Expanded로 남은 공간 채움
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                // "2025년 2월" 등 기본 헤더 텍스트 보이도록 기본 설정 사용
                titleTextStyle: TextStyle(fontSize: 22, color: Colors.blue),
                leftChevronVisible: true,
                rightChevronVisible: true,
              ),
              calendarStyle: CalendarStyle(
                // 오늘 날짜: 배경은 투명, 글자색은 기본(이벤트에 따라 변경)
                todayDecoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                // 선택된 날짜: 배경은 회색 (선택 효과 표시)
                selectedDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Colors.black),
                weekendTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Colors.black),
              ),
              calendarBuilders: CalendarBuilders(
                // 기본 날짜 셀 빌더: 운동 기록이 있으면 글자색을 파란색, 없으면 검정색
                defaultBuilder: (context, day, focusedDay) {
                  final events = _getEventsForDay(day);
                  final textColor = events.isNotEmpty ? Colors.blue : Colors.black;
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: textColor),
                    ),
                  );
                },
                // Marker: 각 날짜 셀 하단에 머슬 그룹 도트를 표시 (없으면 빈 SizedBox)
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    final muscleGroups = events
                        .map((e) => (e as Map<String, dynamic>)['muscleGroup'] as String)
                        .toSet();
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: muscleGroups.map((mg) {
                          final dotColor = muscleGroupColors[mg] ?? Colors.black;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                _loadMonthlyWorkoutEvents(focusedDay);
              },
            ),
          ),
        ],
      ),
    );
  }
}
