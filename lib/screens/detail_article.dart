import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/article_page.dart';
import 'package:plantbuddy/screens/profile.dart';
import 'package:plantbuddy/screens/kebunku/kebun/kebunku.dart';

class DetailArticlePage extends StatefulWidget {
  final Map<String, dynamic> article;

  const DetailArticlePage({
    super.key,
    required this.article,
  });

  @override
  State<DetailArticlePage> createState() => _DetailArticlePageState();
}

class _DetailArticlePageState extends State<DetailArticlePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF01B14E),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF01B14E),
                      size: 18,
                    ),
                    onPressed: () {
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
                              begin: const Offset(-0.1, 0.0),
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
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: const Color(0xFF01B14E),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          isBookmarked = !isBookmarked;
                        });
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Article Image
                      Image(
                        image: _getImageProvider(widget.article['image_data']),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Article Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category and Date
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF01B14E).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_florist_outlined,
                                        size: 14,
                                        color: const Color(0xFF01B14E),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tanaman',
                                        style: TextStyle(
                                          color: const Color(0xFF01B14E),
                                          fontSize: 12,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(widget.article['published_date'], widget.article['created_at']),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Article Title
                            Text(
                              widget.article['title'] ?? 'Judul tidak tersedia',
                              style: const TextStyle(
                                color: Color(0xFF2E2E2E),
                                fontSize: 24,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Article Content
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.article['content'] ?? 'Konten tidak tersedia.',
                                style: const TextStyle(
                                  color: Color(0xFF2E2E2E),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.7,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.share_outlined, size: 18),
                                    label: const Text('Bagikan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF01B14E),
                                      elevation: 0,
                                      side: const BorderSide(color: Color(0xFF01B14E)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        isBookmarked = !isBookmarked;
                                      });
                                    },
                                    icon: Icon(
                                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      size: 18,
                                    ),
                                    label: Text(isBookmarked ? 'Tersimpan' : 'Simpan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF01B14E),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Bottom Padding for Navigation Bar
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Original Bottom Navigation Bar
          _buildOriginalBottomNavigationBar(),
        ],
      ),
    );
  }

  // Original Bottom Navigation Bar
  Widget _buildOriginalBottomNavigationBar() {
    return Positioned(
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
            )
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
                    pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
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
                children: const [
                  Icon(
                    CupertinoIcons.leaf_arrow_circlepath,
                    color: Color(0xFFD1D1D1),
                    size: 24,
                  ),
                  Text(
                    'Kebunku',
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
                  CupertinoIcons.doc_text_fill,
                  color: Color(0xFF01B14E),
                  size: 24,
                ),
                Text(
                  'Artikel',
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
                    pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
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
    );
  }
}