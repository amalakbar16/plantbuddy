import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'tambah_jadwal.dart';
import 'edit_jadwal.dart';

class ListJadwal extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;
  final VoidCallback? onRefresh;
  final DateTime selectedDate;

  const ListJadwal({
    super.key,
    required this.schedules,
    this.onRefresh,
    required this.selectedDate,
  });

  @override
  State<ListJadwal> createState() => _ListJadwalState();
}

class _ListJadwalState extends State<ListJadwal> {
  Box? checklistBox;

  @override
  void initState() {
    super.initState();
    _openChecklistBox();
  }

  Future<void> _openChecklistBox() async {
    final box = await Hive.openBox('checklistBox');
    setState(() {
      checklistBox = box;
    });
  }

  // Key unik checklist harian per jadwal
  String checklistKey(int jadwalId, DateTime date) =>
      "checklist_${jadwalId}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";

  // Handler checklist berubah
  void _onChecklistChanged() {
    setState(() {});
      }

  @override
  Widget build(BuildContext context) {
    if (widget.schedules.isEmpty) {
      return Center(
        child: Text(
          'Belum ada jadwal',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
            fontFamily: 'Montserrat',
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header dan tombol tambah
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 14,
            top: 20,
          ),
          child: Row(
            children: [
              const Text(
                'Tugas Kamu',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Material(
                color: const Color(0xFFEEFFF3),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () async {
                    final added = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.55,
                            maxChildSize: 0.6,
                            expand: false,
                            builder: (context, scrollController) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: const TambahJadwal(),
                                ),
                              );
                            },
                          ),
                    );
                    if (added == true && widget.onRefresh != null)
                      widget.onRefresh!();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.add, color: Color(0xFF01B14E), size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Tambah",
                          style: TextStyle(
                            color: Color(0xFF01B14E),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: -0.2,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              checklistBox == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    children: [
                      ...widget.schedules.map((jadwal) {
                        Uint8List? imgBytes;
                        if (jadwal['imageBytes'] != null &&
                            jadwal['imageBytes'] is Uint8List) {
                          imgBytes = jadwal['imageBytes'];
                        }
                        final key = checklistKey(
                          jadwal['id'],
                          widget.selectedDate,
                        );
                        final isDone =
                            checklistBox!.get(key, defaultValue: false) ??
                            false;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final updated = await showModalBottomSheet<bool>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder:
                                  (context) => DraggableScrollableSheet(
                                    initialChildSize: 0.55,
                                    minChildSize: 0.5,
                                    maxChildSize: 0.55,
                                    expand: false,
                                    builder: (context, scrollController) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(26),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: EditJadwal(jadwal: jadwal),
                                        ),
                                      );
                                    },
                                  ),
                            );
                            if (updated == true && widget.onRefresh != null)
                              widget.onRefresh!();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE5E5E5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.11),
                                  blurRadius: 18,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris gambar dan nama + info pengulangan
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child:
                                              imgBytes != null
                                                  ? Image.memory(
                                                    imgBytes,
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    width: 48,
                                                    height: 48,
                                                    color: const Color(
                                                      0xFFF2F2F2,
                                                    ),
                                                    child: const Icon(
                                                      Icons.eco,
                                                      color: Color(0xFF01B14E),
                                                      size: 30,
                                                    ),
                                                  ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Agar tidak overflow
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                jadwal['plant_name'] ?? '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 18,
                                                  letterSpacing: -0.4,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.repeat_rounded,
                                                    color: Colors.grey[400],
                                                    size: 15,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      jadwal['repeat_type'] ??
                                                          '-',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[600],
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Icon(
                                                    Icons.schedule,
                                                    color: Colors.grey[400],
                                                    size: 15,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Flexible(
                                                    child: Text(
                                                      jadwal['time'] ?? '-',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[600],
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    // Checklist harian
                                    PenyiramanWithChecklist(
                                      jadwalId: jadwal['id'],
                                      date: widget.selectedDate,
                                      isDone: isDone,
                                      onChecklistChanged: _onChecklistChanged,
                                      checklistBox: checklistBox!,
                                    ),
                                  ],
                                ),
                                // Icon pengingat otomatis, kanan atas
                                if ((jadwal['reminder_enabled'] ?? 0) == 1)
                                  Positioned(
                                    right: 2,
                                    top: 3,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEEFFF3),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.notifications_active,
                                        color: Color(0xFF01B14E),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
        ),
      ],
    );
  }
}

// Checklist per hari per jadwal (tanpa animasi sama sekali!)
class PenyiramanWithChecklist extends StatefulWidget {
  final int jadwalId;
  final DateTime date;
  final bool isDone;
  final void Function() onChecklistChanged;
  final Box checklistBox;

  const PenyiramanWithChecklist({
    Key? key,
    required this.jadwalId,
    required this.date,
    required this.isDone,
    required this.onChecklistChanged,
    required this.checklistBox,
  }) : super(key: key);

  @override
  State<PenyiramanWithChecklist> createState() => _PenyiramanWithChecklistState();
}

class _PenyiramanWithChecklistState extends State<PenyiramanWithChecklist> {
  late bool done;

  String get checklistKey =>
      "checklist_${widget.jadwalId}_${widget.date.year}${widget.date.month.toString().padLeft(2, '0')}${widget.date.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    done = widget.isDone;
  }

  void _toggleDone() {
    setState(() {
      done = !done;
      widget.checklistBox.put(checklistKey, done);
    });
    widget.onChecklistChanged();
  }

  @override
  void didUpdateWidget(covariant PenyiramanWithChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDone != widget.isDone) {
      setState(() => done = widget.isDone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = const Color(0xFF01B14E);
    final Color mainBlue = const Color(0xFF299CFF);

    return SizedBox(
      height: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon air
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.water_drop, color: mainBlue, size: 26),
          ),
          const SizedBox(width: 16),
          // Text + label done (TANPA ANIMASI SAMA SEKALI)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: done ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  const Text(
                    "Penyiraman",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (done)
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: mainGreen, size: 17),
                        const SizedBox(width: 5),
                        const Text(
                          "Hari Ini Selesai",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFF01B14E),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
          // Checklist button (TANPA ANIMASI)
          GestureDetector(
            onTap: _toggleDone,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 6, top: 2),
              decoration: BoxDecoration(
                color: done ? mainGreen.withOpacity(0.08) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? mainGreen : const Color(0xFFD7E6DA),
                  width: 2.3,
                ),
              ),
              child: done
                  ? Icon(Icons.check_rounded, color: mainGreen, size: 22)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

