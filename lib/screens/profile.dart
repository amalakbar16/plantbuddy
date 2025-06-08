import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plantbuddy/auth/login.dart';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/article_page.dart';
import 'package:plantbuddy/screens/kebunku/kebun/kebunku.dart';
import 'package:hive/hive.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    var box = Hive.box('userBox');
    await box.delete('userId');
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
  }

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
                                        const HomePage(userName: ''),
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
              onTap: () => _logout(context),
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
          // ... rest of the UI unchanged ...
        ],
      ),
    );
  }
}
