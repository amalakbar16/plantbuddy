import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plantbuddy/auth/login.dart';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/article_page.dart';
import 'package:plantbuddy/screens/kebunku/kebun/kebunku.dart';
import 'package:hive/hive.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Section
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 280,
                  child: Stack(
                    children: [
                      // Green Background
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 220,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF01B14E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Back Button
                      Positioned(
                        left: 24,
                        top: 85,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const HomePage(),
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
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF01B14E),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Profile Title
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 100,
                        child: Center(
                          child: Text(
                            'Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Profile Picture
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 158,
                        child: Align(
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFD1D1D1),
                                  shape: OvalBorder(
                                    side: BorderSide(
                                      width: 5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                CupertinoIcons.person_fill,
                                size: 55,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Edit Profile Button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 60,
            top: 280,
            child: GestureDetector(
              onTap: () {
                // Action when tapped
              },
              child: Container(
                width: 120,
                height: 40,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 120,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF171E1D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          'Edit Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // New Section Added Below "Edit Profil" Button
          Positioned(
            left: 0,
            top: 350,
            child: Container(
              width: 410,
              height: 355,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 410,
                      height: 29,
                      decoration: BoxDecoration(color: const Color(0xFFF6F6F6)),
                    ),
                  ),
                  Positioned(
                    left: 31,
                    top: 6,
                    child: Text(
                      'Konten',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Tersimpan
                  Positioned(
                    left: 27,
                    top: 49,
                    child: Icon(
                      Icons.bookmark_border, // Tersimpan Icon
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 54,
                    top: 48,
                    child: Text(
                      'Tersimpan',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 48,
                    child: Icon(
                      Icons.arrow_forward_ios, // Panah di kanan
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  // Umpan Balik
                  Positioned(
                    left: 27,
                    top: 85,
                    child: Icon(
                      Icons.comment, // Umpan Balik Icon
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 54,
                    top: 84,
                    child: Text(
                      'Umpan Balik',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 84,
                    child: Icon(
                      Icons.arrow_forward_ios, // Panah di kanan
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  // Rate Us
                  Positioned(
                    left: 27,
                    top: 121,
                    child: Icon(
                      Icons.star_border, // Rate Us Icon
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 54,
                    top: 121,
                    child: Text(
                      'Rate Us',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 121,
                    child: Icon(
                      Icons.arrow_forward_ios, // Panah di kanan
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  // Tentang PlantBuddy
                  Positioned(
                    left: 27,
                    top: 156,
                    child: Icon(
                      Icons.info_outline, // Tentang Icon
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 54,
                    top: 156,
                    child: Text(
                      'Tentang PlantBuddy',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 156,
                    child: Icon(
                      Icons.arrow_forward_ios, // Panah di kanan
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  // Privacy Policy
                  Positioned(
                    left: 27,
                    top: 191,
                    child: Icon(
                      Icons.lock, // Privacy Policy Icon
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 54,
                    top: 192,
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 192,
                    child: Icon(
                      Icons.arrow_forward_ios, // Panah di kanan
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  // Bantuan
                  Positioned(
                    left: 27,
                    top: 230,
                    child: Icon(
                      Icons.help_outline, // Bantuan Icon
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 54,
                    top: 229,
                    child: Text(
                      'Bantuan',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 229,
                    child: Icon(
                      Icons.arrow_forward_ios, // Panah di kanan
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  // Keluar
Positioned(
  left: 27,
  top: 264,
  child: GestureDetector(
    onTap: () {
      // Menambahkan aksi untuk keluar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin keluar?',
              style: TextStyle(
                fontFamily: 'Montserrat',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
                TextButton(
                  onPressed: () async {
                    var box = await Hive.openBox('userBox');
                    await box.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          var curve = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
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
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Ya, Keluar',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      );
    },
    child: Icon(
      Icons.exit_to_app, // Keluar Icon
      color: Colors.red,
      size: 20,
    ),
  ),
),
Positioned(
  left: 54,
  top: 264,
  child: GestureDetector(
    onTap: () {
      // Menambahkan aksi untuk keluar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin keluar?',
              style: TextStyle(
                fontFamily: 'Montserrat',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var curve = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        );
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
                    (route) => false,
                  );
                },
                child: Text(
                  'Ya, Keluar',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      );
    },
    child: Text(
      'Keluar',
      style: TextStyle(
        color: Colors.red,
        fontSize: 15,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),
Positioned(
  right: 16,
  top: 264,
  child: GestureDetector(
    onTap: () {
      // Menambahkan aksi untuk keluar saat ikon panah ditekan
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin keluar?',
              style: TextStyle(
                fontFamily: 'Montserrat',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var curve = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        );
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
                    (route) => false,
                  );
                },
                child: Text(
                  'Ya, Keluar',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      );
    },
    child: Icon(
      Icons.arrow_forward_ios, // Panah di kanan
      color: Colors.red,
      size: 16,
    ),
  ),
),

                  // Hapus Akun
                  Positioned(
                    left: 27,
                    top: 300,
                    child: Icon(
                      Icons.delete, // Hapus Akun Icon
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 54,
                    top: 300,
                    child: Text(
                      'Hapus Akun',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 300,
                    child: Icon(
                      Icons.arrow_forward_ios, // Panah di kanan
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom navigation bar
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 84,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                shadows: [
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
                                  const HomePage(),
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
                      children: [
                        Icon(
                          CupertinoIcons.house_fill,
                          color: const Color(0xFFD1D1D1),
                          size: 24,
                        ),
                        Text(
                          'Beranda',
                          style: TextStyle(
                            color: const Color(0xFFD1D1D1),
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
                          pageBuilder: (context, animation, secondaryAnimation) => Kebunku(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var curve = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            );
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
                      children: [
                        Icon(
                          CupertinoIcons.leaf_arrow_circlepath,
                          color: const Color(0xFFD1D1D1),
                          size: 24,
                        ),
                        Text(
                          'Kebunku',
                          style: TextStyle(
                            color: const Color(0xFFD1D1D1),
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
                      children: [
                        Icon(
                          CupertinoIcons.doc_text_fill,
                          color: const Color(0xFFD1D1D1),
                          size: 24,
                        ),
                        Text(
                          'Artikel',
                          style: TextStyle(
                            color: const Color(0xFFD1D1D1),
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
                    children: [
                      Icon(
                        CupertinoIcons.person_fill,
                        color: const Color(0xFF01B14E),
                        size: 24,
                      ),
                      Text(
                        'Profil',
                        style: TextStyle(
                          color: const Color(0xFF01B14E),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 2.17,
                        ),
                      ),
                    ],
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
