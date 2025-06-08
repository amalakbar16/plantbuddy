import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/article_page.dart';
import 'package:plantbuddy/screens/profile.dart';
import 'package:plantbuddy/screens/kebunku/jadwal/jadwal.dart';
import 'package:plantbuddy/screens/kebunku/tambah/tambah_kebun.dart';
import 'package:plantbuddy/services/api_service.dart';
import 'package:hive/hive.dart';

import 'edit_kebun.dart';

Widget _circleIcon({
  required IconData icon,
  required Color iconColor,
  required Color borderColor,
  bool rotateUp = false,
}) {
  Widget childIcon = Icon(icon, color: iconColor, size: 30);
  if (rotateUp) {
    childIcon = Transform.rotate(
      angle: -90 * 3.1415926535 / 180,
      child: childIcon,
    );
  }
  return Container(
    width: 55,
    height: 55,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 3),
    ),
    child: Center(child: childIcon),
  );
}

class Kebunku extends StatefulWidget {
  const Kebunku({super.key});

  @override
  State<Kebunku> createState() => _KebunkuState();
}

class _KebunkuState extends State<Kebunku> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isAnimating = false;
  bool isJadwalSelected = false;
  bool isTambahSelected = false;

  List<Map<String, dynamic>> _plants = [];
  bool _isLoading = true;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isJadwalSelected) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const Jadwal(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (isTambahSelected) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const TambahKebun(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      }
    });
    _fetchPlants();
  }

  Future<void> _fetchPlants({bool animate = true}) async {
    if (animate) {
      setState(() => _opacity = 0.0);
      await Future.delayed(const Duration(milliseconds: 180));
    }
    final userBox = await Hive.openBox('userBox');
    final int? userId = userBox.get('userId');
    if (userId == null) {
      setState(() {
        _plants = [];
        _isLoading = false;
        _opacity = 1.0;
      });
      return;
    }
    final plants = await ApiService.getPlantsForUser(userId);
    if (mounted) {
      setState(() {
        _plants = plants;
        _isLoading = false;
        _opacity = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onJadwalTap() {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      isJadwalSelected = true;
      isTambahSelected = false;
    });
    _controller.forward();
  }

  void onTambahTap() {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      isTambahSelected = true;
      isJadwalSelected = false;
    });
    _controller.forward();
  }

  void onKebunkuTap() {
    if (isAnimating) return;
  }

  Widget _buildPlantList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Tanaman Saya',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 6, bottom: 24),
            itemCount: _plants.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plant = _plants[index];
              final imageUrl = plant['image_data'] != null && plant['image_data'].isNotEmpty
                  ? 'data:image/${plant['image_type']};base64,${plant['image_data']}'
                  : null;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () async {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.85,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        expand: false,
                        builder: (context, scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: EditKebun(plant: plant),
                            ),
                          );
                        },
                      ),
                    );
                    if (result == true) {
                      await _fetchPlants();
                      _showAnimatedSnackbar(context, 'Tanaman berhasil diperbarui!');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 13,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl != null
                              ? Image.memory(
                                  Uri.parse(imageUrl).data!.contentAsBytes(),
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 54,
                                  height: 54,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.local_florist,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant['name'] ?? 'No Name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                plant['species'] ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey[600],
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DraggableScrollableSheet(
                                initialChildSize: 0.65,
                                minChildSize: 0.6,
                                maxChildSize: 0.65,
                                expand: false,
                                builder: (context, scrollController) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: EditKebun(plant: plant),
                                    ),
                                  );
                                },
                              ),
                            );
                            if (result == true) {
                              await _fetchPlants();
                              _showAnimatedSnackbar(context, 'Tanaman berhasil diperbarui!');
                            }
                          },
                          child: Icon(
                            Icons.more_horiz,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(double screenWidth) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? Align(
                  alignment: Alignment(0, -0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 20,
                              top: 26,
                              child: _circleIcon(
                                icon: Icons.water_drop,
                                iconColor: Colors.blue[600]!,
                                borderColor: Colors.blue[100]!,
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 26,
                              child: _circleIcon(
                                icon: Icons.content_cut,
                                iconColor: Colors.green[600]!,
                                borderColor: Colors.green[100]!,
                                rotateUp: true,
                              ),
                            ),
                            Positioned(
                              left: 55,
                              bottom: 24,
                              child: _circleIcon(
                                icon: Icons.wb_sunny,
                                iconColor: Colors.orange[700]!,
                                borderColor: Colors.orange[100]!,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tanamanmu Kosong',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kelola tanaman dengan mudah, dan\npantau pertumbuhannya.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.55),
                          fontSize: 19,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 180,
                        height: 60,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black.withOpacity(0.7),
                            side: BorderSide(
                              width: 1.5,
                              color: Colors.black.withOpacity(0.7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              letterSpacing: -0.5,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const TambahKebun(),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  var curve = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  );
                                  var fadeAnim = Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).animate(curve);
                                  var slideAnim = Tween(
                                    begin: const Offset(0.0, 0.1),
                                    end: const Offset(0.0, 0.0),
                                  ).animate(curve);
                                  return FadeTransition(
                                    opacity: fadeAnim,
                                    child: SlideTransition(
                                      position: slideAnim,
                                      child: child,
                                    ),
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                          child: const Text('Tambah Tanaman'),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildPlantList(),
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final indicatorWidth = screenWidth * 0.33;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // HEADER
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Container(
              width: screenWidth,
              height: 32,
              child: Stack(
                children: [
                  Positioned(
                    left: 35,
                    top: 0,
                    child: GestureDetector(
                      onTap: onKebunkuTap,
                      child: SizedBox(
                        width: 98,
                        child: Text(
                          'KebunKu',
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
                  ),
                  Positioned(
                    left: screenWidth / 2 - 40,
                    top: 0,
                    child: GestureDetector(
                      onTap: onJadwalTap,
                      child: SizedBox(
                        width: 98,
                        child: Text(
                          'Jadwal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isJadwalSelected ? Colors.black : Colors.black.withOpacity(0.5),
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
                            color: isTambahSelected ? Colors.black : Colors.black.withOpacity(0.5),
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
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double leftPosition = 0;
                      if (isJadwalSelected) {
                        leftPosition = indicatorWidth;
                      } else if (isTambahSelected) {
                        leftPosition = indicatorWidth * 2;
                      } else {
                        leftPosition = 0;
                      }
                      return Positioned(
                        bottom: 0,
                        left: leftPosition * _animation.value,
                        width: indicatorWidth,
                        child: Container(height: 1, color: Colors.black),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // CONTENT utama dengan animasi (tanpa header/navbar)
          Positioned.fill(
            top: 120, // offset supaya tidak ketiban header
            bottom: 84, // offset supaya tidak ketiban navbar
            child: _buildMainContent(screenWidth),
          ),
          // NAVBAR
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
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              HomePage(userName: ''),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                            var fadeAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
                            var slideAnim = Tween(
                              begin: const Offset(0.0, 0.1),
                              end: const Offset(0.0, 0.0),
                            ).animate(curve);
                            return FadeTransition(
                              opacity: fadeAnim,
                              child: SlideTransition(
                                position: slideAnim,
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
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
                          pageBuilder: (context, animation, secondaryAnimation) => const ArticlePage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                            var fadeAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
                            var slideAnim = Tween(
                              begin: const Offset(0.0, 0.1),
                              end: const Offset(0.0, 0.0),
                            ).animate(curve);
                            return FadeTransition(
                              opacity: fadeAnim,
                              child: SlideTransition(
                                position: slideAnim,
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
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
                          pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                            var fadeAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
                            var slideAnim = Tween(
                              begin: const Offset(0.0, 0.1),
                              end: const Offset(0.0, 0.0),
                            ).animate(curve);
                            return FadeTransition(
                              opacity: fadeAnim,
                              child: SlideTransition(
                                position: slideAnim,
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
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

  void _showAnimatedSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF01B14E),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
