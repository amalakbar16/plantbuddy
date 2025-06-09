import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantbuddy/services/api_service.dart' as api;
import 'package:logger/logger.dart';
import 'dart:convert';

class ArticleForm extends StatefulWidget {
  final Map<String, dynamic>? article;

  const ArticleForm({
    super.key,
    this.article,
  });

  @override
  State<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends State<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imageBase64;
  String? _imageName;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!['title'];
      _contentController.text = widget.article!['content'];
      
      if (widget.article!['image_data'] != null) {
        _imageBase64 = widget.article!['image_data'];
        _imageName = 'existing_image.jpg';
        logger.i('Loaded existing image from article');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      
      if (file != null) {
        final bytes = await file.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        
        setState(() {
          _imageBase64 = base64Image;
          _imageName = file.name;
        });
        
        logger.i('Image picked successfully: ${file.name}');
      }
    } catch (e) {
      logger.e('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final articleData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'published_date': formattedDate,
      };

      if (_imageBase64 != null && _imageName != null) {
        articleData['image'] = _imageBase64!;
        articleData['image_name'] = _imageName!;
      }

      try {
        if (widget.article != null) {
          if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
            articleData['image'] = _imageBase64!;
            articleData['image_name'] = _imageName ?? 'article_image.jpg';
          } else if (widget.article!['image_data'] != null && widget.article!['image_data'].toString().isNotEmpty) {
            articleData['image'] = widget.article!['image_data'].toString();
            articleData['image_name'] = 'existing_image.jpg';
          }
          
          final response = await api.ApiService.updateArticle(
            int.parse(widget.article!['id'].toString()), 
            articleData
          );
          
          if (response['success'] != true) {
            throw Exception(response['error'] ?? 'Failed to update article');
          }
          
          logger.i('Update article successful: ${response['message']}');
        } else {
          if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
            articleData['image'] = _imageBase64!;
            articleData['image_name'] = _imageName ?? 'article_image.jpg';
          }
          
          await api.ApiService.createArticle(articleData);
          logger.i('Create article successful');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    widget.article != null 
                      ? 'Artikel berhasil diperbarui' 
                      : 'Artikel berhasil ditambahkan'
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        logger.e('Error in form submission: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.article != null ? 'Edit Artikel' : 'Tambah Artikel',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Card Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload Section
                      Text(
                        'Gambar Artikel',
                        style: TextStyle(
                          color: const Color(0xFF1F2937),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _imageBase64 != null 
                                ? const Color(0xFF01B14E).withOpacity(0.3)
                                : Colors.grey.shade300,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _imageBase64 != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Builder(
                                        builder: (context) {
                                          try {
                                            final base64Str = _imageBase64!
                                                .split(',')
                                                .last
                                                .replaceAll(RegExp(r'\s+'), '')
                                                .trim();
                                            return Image.memory(
                                              base64Decode(base64Str),
                                              width: double.infinity,
                                              height: 220,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return _buildErrorWidget();
                                              },
                                            );
                                          } catch (e) {
                                            return _buildErrorWidget();
                                          }
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF01B14E).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 32,
                                        color: const Color(0xFF01B14E),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Tap untuk menambah gambar',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'JPG, PNG hingga 10MB',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // Title Field
                      Text(
                        'Judul Artikel',
                        style: TextStyle(
                          color: const Color(0xFF1F2937),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan judul artikel yang menarik',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Montserrat',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFF01B14E), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          if (value.length < 5) {
                            return 'Judul minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),

                      // Content Field
                      Text(
                        'Konten Artikel',
                        style: TextStyle(
                          color: const Color(0xFF1F2937),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 12,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tulis konten artikel yang informatif dan menarik...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Montserrat',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFF01B14E), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade400),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konten tidak boleh kosong';
                          }
                          if (value.length < 50) {
                            return 'Konten minimal 50 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF01B14E),
                        const Color(0xFF00A043),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF01B14E).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Menyimpan...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.article != null ? Icons.save : Icons.add,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.article != null ? 'Simpan Perubahan' : 'Tambah Artikel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.red[400],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Error loading image',
            style: TextStyle(
              color: Colors.red[400],
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}