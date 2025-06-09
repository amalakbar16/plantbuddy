import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/article_page.dart';
import 'package:plantbuddy/screens/profile.dart';
import 'package:plantbuddy/screens/kebunku/jadwal/jadwal.dart';
import 'package:plantbuddy/screens/kebunku/kebun/kebunku.dart';
import 'package:plantbuddy/screens/kebunku/tambah/tambahkan.dart';

class TambahKebun extends StatefulWidget {
  const TambahKebun({super.key});

  @override
  State<TambahKebun> createState() => _TambahKebunState();
}

class _TambahKebunState extends State<TambahKebun>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isAnimating = false;
  bool isKebunkuSelected = false;
  bool isJadwalSelected = false;

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.addStatusListener((status) {
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
        } else if (isJadwalSelected) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => const Jadwal(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      }
    });
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
      isKebunkuSelected = false;
    });
    _controller.forward(from: 0);
  }

  void onKebunkuTap() {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      isKebunkuSelected = true;
      isJadwalSelected = false;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final indicatorWidth = screenWidth * 0.33;

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
                  // TambahKebun kiri
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

                  // Jadwal tengah
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
                            color:
                                isJadwalSelected
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

                  // Tambah kanan
                  Positioned(
                    left: screenWidth - 135,
                    top: 0,
                    child: SizedBox(
                      width: 98,
                      child: Text(
                        'Tambah',
                        textAlign: TextAlign.right,
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
                      double screenWidth = MediaQuery.of(context).size.width;
                      double indicatorWidth = screenWidth * 0.33;
                      double startLeft = screenWidth - indicatorWidth;
                      double endLeft = screenWidth / 2 - indicatorWidth / 2;
                      if (isKebunkuSelected) {
                        startLeft = screenWidth - indicatorWidth;
                        endLeft = 0;
                      } else if (isJadwalSelected) {
                        startLeft = screenWidth - indicatorWidth;
                        endLeft = screenWidth / 2 - indicatorWidth / 2;
                      }
                      double leftPosition =
                          startLeft - (startLeft - endLeft) * _animation.value;
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

Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 0),
        child: TambahkanWidget(),
      ),
    ),


          // Bottom Navigation Bar
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
