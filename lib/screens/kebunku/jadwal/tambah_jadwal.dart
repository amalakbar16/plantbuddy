import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:plantbuddy/services/api_service.dart';
import 'pilih_tanaman.dart';

class TambahJadwal extends StatefulWidget {
  const TambahJadwal({super.key});

  @override
  State<TambahJadwal> createState() => _TambahJadwalState();
}

class _TambahJadwalState extends State<TambahJadwal> {
  Map<String, dynamic>? _selectedTanaman;
  bool _reminder = false;
  List<String> _selectedDays = [];
  TimeOfDay? _selectedTime;
  bool _saving = false;

  static const dayList = [
    "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"
  ];

  // Format waktu jam:mm sesuai MySQL/Backend
  String _formatTimeOfDay(TimeOfDay tod) =>
      "${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}";

  String get _pengulangan {
    if (_selectedDays.isEmpty) return "";
    if (_selectedDays.length == 7) return "Setiap Hari";
    return "Setiap " + _selectedDays.join(", ");
  }

  Future<void> _onSave() async {
    if (_selectedTanaman == null ||
        _pengulangan.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Lengkapi data jadwal sebelum menyimpan!",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final userBox = await Hive.openBox('userBox');
      final int? userId = userBox.get('userId');
      if (userId == null) throw "User tidak ditemukan";
      // Panggil API simpan jadwal
      await ApiService.addSchedule(
        userId: userId,
        plantId: int.parse(_selectedTanaman!['id'].toString()),
        repeatType: _pengulangan,
        time: _formatTimeOfDay(_selectedTime!),
        reminderEnabled: _reminder,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Jadwal berhasil disimpan!",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Gagal menyimpan jadwal: $e",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showPilihTanamanModal() async {
    final userBox = await Hive.openBox('userBox');
    final int? userId = userBox.get('userId');
    if (userId == null) return;
    final List<Map<String, dynamic>> tanamanList =
        await ApiService.getPlantsForUser(userId);
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return PilihTanaman(
            tanamanList: tanamanList,
            onSelected: (tanaman) {
              if (!mounted) return;
              setState(() {
                _selectedTanaman = tanaman;
              });
            },
          );
        },
      ),
    );
  }

  void _showPilihPengulangan() async {
    List<String> tempDays = List.from(_selectedDays);
    bool semuaDipilih = tempDays.length == 7;

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Pilih Hari Pengulangan",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: semuaDipilih,
                          onChanged: (v) {
                            setSheetState(() {
                              if (v == true) {
                                tempDays = List.from(dayList);
                                semuaDipilih = true;
                              } else {
                                tempDays.clear();
                                semuaDipilih = false;
                              }
                            });
                          },
                        ),
                        const Text("Pilih Semua (Setiap Hari)",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    ...dayList.map((hari) => CheckboxListTile(
                          value: tempDays.contains(hari),
                          title: Text(hari),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFF01B14E),
                          onChanged: (v) {
                            setSheetState(() {
                              if (v == true) {
                                tempDays.add(hari);
                              } else {
                                tempDays.remove(hari);
                              }
                              semuaDipilih = tempDays.length == 7;
                            });
                          },
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: const Text("Batal"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF01B14E),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context, tempDays);
                            },
                            child: const Text("Pilih"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _selectedDays = result);
    }
  }

  void _showPilihWaktu() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tambah Jadwal",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // PILIH TANAMAN
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.eco, color: Color(0xFF01B14E)),
                  title: const Text(
                    "Pilih Tanaman",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _selectedTanaman == null
                        ? "Pilih"
                        : _selectedTanaman!['name'] ?? "-",
                    style: TextStyle(
                      color:
                          _selectedTanaman == null ? Colors.grey : Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPilihTanamanModal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // PENGULANGAN
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.repeat, color: Colors.grey[600]),
                  title: const Text(
                    "Pengulangan",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _pengulangan.isEmpty ? "Pilih" : _pengulangan,
                    style: TextStyle(
                      color: _pengulangan.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPilihPengulangan,
                ),
              ),
              const SizedBox(height: 8),
              // WAKTU
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.access_time_rounded,
                    color: Colors.grey[600],
                  ),
                  title: const Text(
                    "Waktu",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _selectedTime == null
                        ? "Pilih"
                        : _selectedTime!.format(context),
                    style: TextStyle(
                      color: _selectedTime == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPilihWaktu,
                ),
              ),
              const SizedBox(height: 16),
              // PENGINGAT OTOMATIS
              Card(
                margin: EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFF6F6F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  title: const Text(
                    "Pengingat Otomatis",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text("Ingatkan saya tentang jadwal saya"),
                  trailing: Switch(
                    value: _reminder,
                    activeColor: const Color(0xFF01B14E),
                    onChanged: (v) => setState(() => _reminder = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // BUTTON SIMPAN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedTanaman != null &&
                                  _pengulangan.isNotEmpty &&
                                  _selectedTime != null
                              ? const Color(0xFF01B14E)
                              : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: (_selectedTanaman != null &&
                            _pengulangan.isNotEmpty &&
                            _selectedTime != null &&
                            !_saving)
                        ? _onSave
                        : null,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Simpan",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: (_selectedTanaman != null &&
                                      _pengulangan.isNotEmpty &&
                                      _selectedTime != null)
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
