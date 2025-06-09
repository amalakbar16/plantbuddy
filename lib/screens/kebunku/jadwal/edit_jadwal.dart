import 'package:flutter/material.dart';
import 'package:plantbuddy/services/api_service.dart';

class EditJadwal extends StatefulWidget {
  final Map<String, dynamic> jadwal;
  final VoidCallback? onUpdated;
  const EditJadwal({super.key, required this.jadwal, this.onUpdated});

  @override
  State<EditJadwal> createState() => _EditJadwalState();
}

class _EditJadwalState extends State<EditJadwal> {
  late List<String> repeatDays; // Multi-select hari
  late TimeOfDay selectedTime;
  late bool reminderEnabled;
  bool isLoading = false;

  // Semua hari dalam seminggu
  static const List<String> allDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();

    // Parsing repeat_type ke List<String>
    String repeatTypeRaw = widget.jadwal['repeat_type'] ?? 'Setiap Hari';
    if (repeatTypeRaw.toLowerCase().replaceAll(' ', '') == 'setiaphari') {
      repeatDays = List.from(allDays);
    } else {
      repeatDays = repeatTypeRaw.split(',')
          .map((d) => d.trim().isNotEmpty ? _capitalize(d.trim()) : null)
          .whereType<String>()
          .toList();
    }

    selectedTime = _parseTime(widget.jadwal['time']);
    reminderEnabled = widget.jadwal['reminder_enabled'] == 1;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  TimeOfDay _parseTime(String? time) {
    if (time == null || time.isEmpty) return const TimeOfDay(hour: 7, minute: 0);
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  void _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _showRepeatPicker() async {
    // Tampilkan bottomsheet multi-select hari
    List<String> tempSelected = List.from(repeatDays);
    bool isSetiapHari = tempSelected.length == 7;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Pilih Hari Pengulangan",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8, runSpacing: 6,
                    children: [
                      for (var day in allDays)
                        FilterChip(
                          label: Text(day),
                          selected: tempSelected.contains(day),
                          selectedColor: const Color(0xFF01B14E).withOpacity(0.18),
                          checkmarkColor: const Color(0xFF01B14E),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                tempSelected.add(day);
                              } else {
                                tempSelected.remove(day);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Setiap Hari"),
                        onPressed: () {
                          setModalState(() {
                            tempSelected = List.from(allDays);
                          });
                        },
                      ),
                      TextButton(
                        child: const Text("Reset"),
                        onPressed: () {
                          setModalState(() => tempSelected.clear());
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, tempSelected);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF01B14E),
                        ),
                        child: const Text("Pilih", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    ).then((pickedDays) {
      if (pickedDays != null) {
        setState(() => repeatDays = List<String>.from(pickedDays));
      }
    });
  }

  Future<void> _onSave() async {
    if (repeatDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal satu hari pengulangan!")),
      );
      return;
    }
    setState(() => isLoading = true);

    String repeatTypeValue =
        repeatDays.length == 7 ? "Setiap Hari" : repeatDays.join(', ');

    final success = await ApiService.updateSchedule(
      scheduleId: widget.jadwal['id'],
      repeatType: repeatTypeValue,
      time:
          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
      reminderEnabled: reminderEnabled,
    );
    setState(() => isLoading = false);

    if (success) {
      if (widget.onUpdated != null) widget.onUpdated!();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jadwal berhasil diupdate!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal update jadwal")),
      );
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Jadwal?"),
        content: const Text("Apakah Anda yakin ingin menghapus jadwal ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => isLoading = true);
    final success = await ApiService.deleteSchedule(scheduleId: widget.jadwal['id']);
    setState(() => isLoading = false);

    if (success) {
      if (widget.onUpdated != null) widget.onUpdated!();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jadwal berhasil dihapus!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal hapus jadwal")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String pengulanganTeks =
        repeatDays.length == 7 ? "Setiap Hari" : repeatDays.join(', ');

    return AbsorbPointer(
      absorbing: isLoading,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "Edit Jadwal",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              // Repeat Picker
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(Icons.repeat, color: Colors.grey[600]),
                  title: const Text("Pengulangan", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(pengulanganTeks, style: TextStyle(color: Colors.black87, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showRepeatPicker,
                ),
              ),
              const SizedBox(height: 13),
              // Time Picker
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(Icons.access_time_rounded, color: Colors.grey[600]),
                  title: const Text("Waktu", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(selectedTime.format(context), style: TextStyle(color: Colors.black87, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showTimePicker,
                ),
              ),
              const SizedBox(height: 13),
              // Reminder Switch
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                color: const Color(0xFFF6F6F6),
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  value: reminderEnabled,
                  activeColor: const Color(0xFF01B14E),
                  onChanged: (v) => setState(() => reminderEnabled = v),
                  title: const Text("Pengingat Otomatis", style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text("Ingatkan saya tentang jadwal ini"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Hapus
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text("Hapus Jadwal", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Simpan
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF01B14E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text("Simpan", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
