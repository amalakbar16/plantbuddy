import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:plantbuddy/screens/homepage.dart';
import 'package:plantbuddy/screens/detail_article.dart';
import 'package:plantbuddy/services/api_service.dart';
import 'package:plantbuddy/screens/profile.dart';
import 'package:plantbuddy/screens/kebunku/kebun/kebunku.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final Function() onTap;

  const ArticleCard({
    Key? key,
    required this.article,
    required this.onTap,
  }) : super(key: key);

  String _formatPublishedDate(String? publishedDate, String? createdAt) {
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
        // Extract base64 data after the comma
        final base64Data = imageData.split(',')[1];
        final decodedBytes = base64Decode(base64Data);
        return MemoryImage(decodedBytes);
      } catch (e) {
        print('Error decoding image: $e');
      }
    }
    return const NetworkImage("https://via.placeholder.com/116x79");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Indicator
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF01B14E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_florist_outlined,
                                size: 12,
                                color: const Color(0xFF01B14E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tanaman',
                                style: TextStyle(
                                  color: const Color(0xFF01B14E),
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatPublishedDate(article['published_date'], article['created_at']),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Article Title
                    Text(
                      article['title'] ?? 'No Title',
                      style: const TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Article Preview
                    Text(
                      article['content'] != null && article['content'].toString().length > 100
                          ? '${article['content'].toString().substring(0, 100)}...'
                          : article['content']?.toString() ?? 'No content',
                      style: TextStyle(
                        color: const Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Read Button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF01B14E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Baca Artikel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Article Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image(
                    image: _getImageProvider(article['image_data']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

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
    _loadArticles();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedArticles = await ApiService.getArticles();
      
      if (!mounted) return;

      if (fetchedArticles.isEmpty) {
        setState(() {
          articles = [];
          isLoading = false;
          errorMessage = 'No articles available';
        });
        return;
      }

      setState(() {
        articles = fetchedArticles;
        isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      print('Error loading articles: $e');
      if (!mounted) return;
      
      setState(() {
        articles = [];
        isLoading = false;
        errorMessage = 'Failed to load articles. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: RefreshIndicator(
        onRefresh: _loadArticles,
        color: const Color(0xFF01B14E),
        child: Stack(
          children: [
            Column(
              children: [
                // Header with Search
                _buildHeader(),
                
                // Articles List
                Expanded(
                  child: _buildArticlesList(),
                ),
              ],
            ),
            
            // Original Bottom Navigation Bar
            _buildOriginalBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Header with Search
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF01B14E), Color(0xFF009E44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF01B14E).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        children: [
          // Title
          const Text(
            'Artikel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          // Search Bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari artikel...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Montserrat',
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        color: Colors.grey[400],
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Articles List
  Widget _buildArticlesList() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF01B14E),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Memuat artikel...',
              style: TextStyle(
                color: Color(0xFF888888),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadArticles,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01B14E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada artikel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Artikel akan ditampilkan di sini',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      );
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Artikel Terbaru',
                style: TextStyle(
                  color: Color(0xFF2E2E2E),
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF888888),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Articles
          ...articles.map((article) => ArticleCard(
            article: article,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => DetailArticlePage(article: article),
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
          )).toList(),
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
          shadows: const [
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