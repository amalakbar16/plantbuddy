import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/article_page.dart';

class DetailArticlePage extends StatelessWidget {
  final Map<String, dynamic> article;

  const DetailArticlePage({
    super.key,
    required this.article,
  });

  String _formatDate(String? publishedDate, String? createdAt) {
    try {
      if (publishedDate != null && publishedDate.isNotEmpty) {
        final date = DateTime.parse(publishedDate);
        return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
      } else if (createdAt != null && createdAt.isNotEmpty) {
        final date = DateTime.parse(createdAt);
        return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return 'Tanggal tidak tersedia';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  ImageProvider _getImageProvider(String? imageData) {
    if (imageData != null && imageData.isNotEmpty && imageData.startsWith('data:image')) {
      try {
        final base64Data = imageData.split(',')[1];
        final decodedBytes = base64Decode(base64Data);
        return MemoryImage(decodedBytes);
      } catch (e) {
        print('Error decoding image: $e');
      }
    }
    return const NetworkImage("https://via.placeholder.com/800x600");
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF01B14E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Lebih soft, modern background
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Artikel (Scrollable)
            Positioned.fill(
              bottom: 84, // Space for navbar
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // **Gambar Artikel + Tombol Back**
                      Stack(
                        children: [
                          // Card modern untuk gambar
                          Container(
                            width: double.infinity,
                            height: 210,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image(
                                image: _getImageProvider(article['image_data']),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 210,
                                errorBuilder: (c, o, s) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, size: 52, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          // Tombol Back (floating, simple)
                          Positioned(
                            left: 14,
                            top: 14,
                            child: Material(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(100),
                              elevation: 0.8,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const ArticlePage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        var curve = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOut,
                                        );
                                        var fadeAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
                                        var slideAnim = Tween(
                                          begin: const Offset(0.0, 0.08),
                                          end: Offset.zero,
                                        ).animate(curve);
                                        return FadeTransition(
                                          opacity: fadeAnim,
                                          child: SlideTransition(
                                            position: slideAnim,
                                            child: child,
                                          ),
                                        );
                                      },
                                      transitionDuration: const Duration(milliseconds: 320),
                                    ),
                                  );
                                },
                                child: const SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Color(0xFF01B14E),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // **Judul Artikel**
                      Text(
                        article['title'] ?? 'Judul tidak tersedia',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          letterSpacing: 0.1,
                          height: 1.25,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // **Tanggal Publish**
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(article['published_date'], article['created_at']),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // **Konten Artikel**
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.03),
                              blurRadius: 7,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        child: Text(
                          article['content'] ?? 'Konten tidak tersedia.',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.65,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // **Bottom Navigation Bar (Modern, Floating)**
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // **Home**
                    _NavBarItem(
                      icon: CupertinoIcons.house_fill,
                      label: 'Beranda',
                      selected: false,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const HomePage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var curve = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );
                              var fadeAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
                              var slideAnim = Tween(
                                begin: const Offset(0.0, 0.06),
                                end: Offset.zero,
                              ).animate(curve);
                              return FadeTransition(
                                opacity: fadeAnim,
                                child: SlideTransition(
                                  position: slideAnim,
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 320),
                          ),
                        );
                      },
                      themeColor: themeColor,
                    ),
                    // **Kebunku**
                    _NavBarItem(
                      icon: CupertinoIcons.leaf_arrow_circlepath,
                      label: 'Kebunku',
                      selected: false,
                      onTap: () {},
                      themeColor: themeColor,
                    ),
                    // **Artikel (Selected)**
                    _NavBarItem(
                      icon: CupertinoIcons.doc_text_fill,
                      label: 'Artikel',
                      selected: true,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const ArticlePage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var curve = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );
                              var fadeAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
                              var slideAnim = Tween(
                                begin: const Offset(0.0, 0.06),
                                end: Offset.zero,
                              ).animate(curve);
                              return FadeTransition(
                                opacity: fadeAnim,
                                child: SlideTransition(
                                  position: slideAnim,
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 320),
                          ),
                        );
                      },
                      themeColor: themeColor,
                    ),
                    // **Profil**
                    _NavBarItem(
                      icon: CupertinoIcons.person_fill,
                      label: 'Profil',
                      selected: false,
                      onTap: () {},
                      themeColor: themeColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// **Widget Modular untuk Item Navbar**
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color themeColor;
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? themeColor : Colors.grey.shade300,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? themeColor : Colors.grey.shade400,
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
