import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Tanggal extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const Tanggal({
    super.key,
    required this.schedules,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<Tanggal> createState() => _TanggalState();
}

class _TanggalState extends State<Tanggal> {
  Box? checklistBox;

  @override
  void initState() {
    super.initState();
    _openChecklistBox();
  }

  Future<void> _openChecklistBox() async {
    final box = await Hive.openBox('checklistBox');
    if (mounted) {
      setState(() {
        checklistBox = box;
      });
    }
  }

  String _makeChecklistKey(int jadwalId, DateTime date) {
    final ymd =
        "${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    return 'checklist_${jadwalId}_$ymd';
  }

  bool _shouldShowDot(DateTime date) {
    if (widget.schedules.isEmpty) return false;
    if (checklistBox == null || !checklistBox!.isOpen) return false;

    // Hanya tampilkan jika ada jadwal di hari tsb
    bool hasActiveUnfinished = false;
    for (final jadwal in widget.schedules) {
      // Periksa apakah jadwal berlaku di hari ini
      final repeatRaw = (jadwal['repeat_type'] ?? '').toString().toLowerCase().replaceAll(' ', '');
      final selectedDay = _getIndonesianDay(date.weekday);
      if (repeatRaw.contains('setiaphari') ||
          repeatRaw.split(',').contains(selectedDay)) {
        // Reminder harus aktif!
        if ((jadwal['reminder_enabled'] ?? 0) == 1) {
          int id = jadwal['id'] ?? 0;
          String checklistKey = _makeChecklistKey(id, date);
          bool done = checklistBox!.get(checklistKey, defaultValue: false) ?? false;
          if (!done) {
            hasActiveUnfinished = true;
            break;
          }
        }
      }
    }
    return hasActiveUnfinished;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final int weekday = today.weekday;
    final weekStart = today.subtract(Duration(days: weekday - 1));
    final weekDates = List<DateTime>.generate(
      7, (i) => weekStart.add(Duration(days: i)),
    );
    final days = ['Sn', 'Sl', 'Rb', 'K', 'J', 'Sb', 'M'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withAlpha(30),
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // Bulan dan tahun
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 18, top: 14, bottom: 6),
            child: Text(
              "${_getMonthName(weekDates[0].month)} ${weekDates[0].year}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Hari
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    days[i],
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.65),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 2),
          // Tanggal
          Row(
            children: List.generate(7, (i) {
              final date = weekDates[i];
              final isSelected = date.year == widget.selectedDate.year &&
                  date.month == widget.selectedDate.month &&
                  date.day == widget.selectedDate.day;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final bool showDot = _shouldShowDot(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onDateSelected(date),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 190),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF01B14E)
                              : isToday
                                  ? const Color(0x2201B14E)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${date.day}",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? const Color(0xFF01B14E)
                                    : const Color(0xFF444444),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                        child: showDot
                            ? Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF01B14E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF01B14E)
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Helper nama hari Indonesia (senin-minggu)
String _getIndonesianDay(int weekday) {
  const names = [
    'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'
  ];
  return names[(weekday - 1) % 7];
}

// Helper nama bulan
String _getMonthName(int month) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return months[month - 1];
}
