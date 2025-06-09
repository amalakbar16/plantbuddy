import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:plantbuddy/services/api_service.dart';
import 'package:plantbuddy/screens/kebunku/kebun/kebunku.dart';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/article_page.dart';
import 'package:plantbuddy/screens/profile.dart';
import 'package:plantbuddy/screens/kebunku/tambah/tambah_kebun.dart';
import 'package:plantbuddy/screens/kebunku/jadwal/tanggal.dart';
import 'jadwal_kosong.dart';
import 'list_jadwal.dart';

class Jadwal extends StatefulWidget {
  const Jadwal({super.key});

  @override
  State<Jadwal> createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isAnimating = false;
  bool isKebunkuSelected = false;
  bool isTambahSelected = false;

  List<Map<String, dynamic>> _schedules = [];
  bool _loading = true;

  DateTime _selectedDate = DateTime.now(); // Untuk filter tanggal

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (isKebunkuSelected) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => const Kebunku(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (isTambahSelected) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const TambahKebun(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
        setState(() {
          isAnimating = false;
        });
      }
    });

    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _loading = true);
    final userBox = await Hive.openBox('userBox');
    final int? userId = userBox.get('userId');
    if (userId != null) {
      final list = await ApiService.getSchedulesForUser(userId);
      final parsedList =
          list.map<Map<String, dynamic>>((jadwal) {
            Uint8List? imgBytes;
            if (jadwal['image_data'] != null &&
                jadwal['image_data'].isNotEmpty) {
              try {
                imgBytes = base64Decode(jadwal['image_data']);
              } catch (_) {
                imgBytes = null;
              }
            }
            return {
              'id': jadwal['id'],
              'plant_name': jadwal['plant_name'],
              'species': jadwal['species'],
              'repeat_type': jadwal['repeat_type'],
              'time': jadwal['time'],
              'reminder_enabled': jadwal['reminder_enabled'],
              'imageBytes': imgBytes,
            };
          }).toList();

      setState(() {
        _schedules = parsedList;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  /// ======================== FILTER SCHEDULES SESUAI PENGULANGAN HARI ========================
  List<Map<String, dynamic>> _getSchedulesForSelectedDate() {
    final selectedDay = _getIndonesianDay(
      _selectedDate.weekday,
    ); // contoh: "senin"

    return _schedules.where((jadwal) {
      final repeatRaw = (jadwal['repeat_type'] ?? '').toLowerCase();
      final repeat = repeatRaw.replaceAll(' ', ''); // Hapus spasi biar aman

      // Case 1: "Setiap Hari"
      if (repeat.contains('setiaphari')) return true;

      // Case 2: Multi-hari, misal "senin,jumat,minggu" atau "senin, rabu, jumat"
      // (handle koma, spasi, dsb)
      final hariPengulangan =
          repeatRaw
              .replaceAll('setiap', '') // handle kasus "Setiap Senin, Rabu"
              .replaceAll(' ', '')
              .split(',')
              .map((s) => s.trim())
              .toList();

      // Cocokkan ke hari yang dipilih (case-insensitive)
      if (hariPengulangan.contains(selectedDay)) return true;

      // Bisa tambahkan case untuk repeat_type custom lain (misal: sekali, tanggal tertentu, dst)

      return false;
    }).toList();
  }

  /// =====================================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onKebunkuTap() {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      isKebunkuSelected = true;
      isTambahSelected = false;
    });
    _controller.forward(from: 0);
  }

  void onTambahTap() {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      isTambahSelected = true;
      isKebunkuSelected = false;
    });
    _controller.forward(from: 0);
  }

  void onJadwalTap() {
    if (isAnimating) return;
    // Already on Jadwal, no action needed
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final indicatorWidth = screenWidth * 0.33;
    final filteredSchedules = _getSchedulesForSelectedDate();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Appbar custom
          Positioned(
            top: 80,
            left: 0,
            child: Container(
              width: screenWidth,
              height: 32,
              child: Stack(
                children: [
                  // Kebunku kiri ( text)
                  Positioned(
                    left: 18,
                    top: 0,
                    child: GestureDetector(
                      onTap: onKebunkuTap,
                      child: SizedBox(
                        width: 98,
                        child: Text(
                          'KebunKu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                isKebunkuSelected
                                    ? Colors.black
                                    : Colors.black.withOpacity(0.5),
                            fontSize: 17,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 1,
                            letterSpacing: -0.50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Jadwal tengah (tab bar text)
                  Positioned(
                    left: screenWidth / 2 - 40,
                    top: 0,
                    child: SizedBox(
                      width: 98,
                      child: Text(
                        'Jadwal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: -0.50,
                        ),
                      ),
                    ),
                  ),
                  // Tambah kanan
                  Positioned(
                    left: screenWidth - 135,
                    top: 0,
                    child: GestureDetector(
                      onTap: onTambahTap,
                      child: SizedBox(
                        width: 98,
                        child: Text(
                          'Tambah',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color:
                                isTambahSelected
                                    ? Colors.black
                                    : Colors.black.withOpacity(0.5),
                            fontSize: 17,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 1,
                            letterSpacing: -0.50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Garis bawah abu
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  // Garis bawah hitam (tab aktif) animated
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double startLeft = screenWidth / 2 - 58;
                      double endLeft = 0.0;
                      if (isKebunkuSelected) {
                        startLeft = screenWidth / 2 - 58;
                        endLeft = 0;
                      } else if (isTambahSelected) {
                        startLeft = screenWidth / 2 - 58;
                        endLeft = screenWidth - indicatorWidth;
                      } else {
                        startLeft = screenWidth / 2 - 58;
                        endLeft = screenWidth / 2 - 58;
                      }
                      double leftPosition =
                          startLeft + (endLeft - startLeft) * _animation.value;
                      return Positioned(
                        bottom: 0,
                        left: leftPosition,
                        width: indicatorWidth,
                        child: Container(height: 1, color: Colors.black),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Widget tanggal di bawah tab bar
          Positioned(
            top: 113,
            left: 0,
            right: 0,
            child: Tanggal(
              schedules: _schedules,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
          // ======== Main Content ========
          Positioned.fill(
            top: 200,
            bottom: 60,
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        const SizedBox(height: 40),
                        Expanded(
                          child:
                              filteredSchedules.isEmpty
                                  ? const JadwalKosong()
                                  : ListJadwal(
                                    schedules: filteredSchedules,
                                    onRefresh: _fetchSchedules,
                                    selectedDate:
                                        _selectedDate, // <-- ini penting
                                  ),
                        ),
                      ],
                    ),
          ),
          // ====== Bottom Navigation Bar ======
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              height: 84,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 2,
                    offset: Offset(0, 0),
                    spreadRadius: 0.50,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  HomePage(),
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.house_fill,
                          color: Color(0xFFD1D1D1),
                          size: 24,
                        ),
                        Text(
                          'Beranda',
                          style: TextStyle(
                            color: Color(0xFFD1D1D1),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 2.17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        CupertinoIcons.leaf_arrow_circlepath,
                        color: Color(0xFF01B14E),
                        size: 24,
                      ),
                      Text(
                        'Kebunku',
                        style: TextStyle(
                          color: Color(0xFF01B14E),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 2.17,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const ArticlePage(),
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.doc_text_fill,
                          color: Color(0xFFD1D1D1),
                          size: 24,
                        ),
                        Text(
                          'Artikel',
                          style: TextStyle(
                            color: Color(0xFFD1D1D1),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 2.17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const ProfilePage(),
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          CupertinoIcons.person_fill,
                          color: Color(0xFFD1D1D1),
                          size: 24,
                        ),
                        Text(
                          'Profil',
                          style: TextStyle(
                            color: Color(0xFFD1D1D1),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 2.17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper nama hari
String _getIndonesianDay(int weekday) {
  // 1=Senin, ..., 7=Minggu
  const names = [
    'senin',
    'selasa',
    'rabu',
    'kamis',
    'jumat',
    'sabtu',
    'minggu',
  ];
  return names[(weekday - 1) % 7];
}
