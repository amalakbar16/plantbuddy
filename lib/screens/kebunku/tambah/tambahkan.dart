import 'package:plantbuddy/services/api_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:hive/hive.dart';

class TambahkanWidget extends StatefulWidget {
  const TambahkanWidget({Key? key}) : super(key: key);

  @override
  State<TambahkanWidget> createState() => _TambahkanWidgetState();
}

class _TambahkanWidgetState extends State<TambahkanWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaTanamanController = TextEditingController();
  String? _selectedJenis;
  bool _isPicking = false;
  int? _userId;

  final jenisTanamanList = ["Tanaman Bunga", "Tanaman Buah", "Tanaman Peneduh"];

  static const double fieldHeight = 56;
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 16);

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _namaTanamanController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    try {
      if (!Hive.isBoxOpen('userBox')) {
        await Hive.openBox('userBox');
      }
      var box = Hive.box('userBox');
      setState(() {
        _userId = box.get('userId');
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gagal memuat User ID. Silakan login ulang.',
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
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gagal memilih gambar: $e',
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
      }
    } finally {
      setState(() => _isPicking = false);
    }
  }

  Future<void> _submitForm() async {
    if (_namaTanamanController.text.isEmpty || _selectedJenis == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mohon isi semua field',
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
      }
      return;
    }
    if (_userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'User ID tidak ditemukan. Silakan login ulang.',
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
      }
      return;
    }

    String? imageDataBase64;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      imageDataBase64 = base64Encode(bytes);
    }

    try {
      final response = await ApiService.addPlant(
        userId: _userId!,
        name: _namaTanamanController.text.trim(),
        species: _selectedJenis!,
        imageDataBase64: imageDataBase64,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tanaman berhasil ditambahkan',
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
        setState(() {
          _namaTanamanController.clear();
          _selectedJenis = null;
          _selectedImage = null;
        });
        // Jika ingin langsung menutup halaman setelah submit sukses, tambahkan:
        // Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gagal menambahkan tanaman: $e',
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          elevation: 7,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Foto Produk
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: _selectedImage != null ? Colors.grey.shade200 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _selectedImage != null ? Color(0xFF01B14E) : Colors.grey.shade300,
                            width: 2.2,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2),
                          ],
                        ),
                        child: _selectedImage == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_rounded, color: Colors.grey.shade400, size: 46),
                                    SizedBox(height: 10),
                                    Text(
                                      "Tambah Foto",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _selectedImage!,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      if (_selectedImage != null)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
                              ],
                            ),
                            child: Icon(Icons.edit, color: Color(0xFF01B14E), size: 24),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 26),
                // Field: Nama Tanaman
                SizedBox(
                  height: fieldHeight,
                  child: TextFormField(
                    controller: _namaTanamanController,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: "Nama Tanaman",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.6,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.6,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Color(0xFF01B14E),
                          width: 2.0,
                        ),
                      ),
                      contentPadding: fieldPadding,
                    ),
                  ),
                ),
                SizedBox(height: 22),
                // Field: Jenis Tanaman (Dropdown)
                SizedBox(
                  height: fieldHeight,
                  child: DropdownButtonFormField2<String>(
                    isExpanded: true,
                    value: _selectedJenis,
                    onChanged: (val) => setState(() => _selectedJenis = val),
                    decoration: InputDecoration(
                      labelText: "Jenis Tanaman",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.6,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.6,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Color(0xFF01B14E),
                          width: 2.0,
                        ),
                      ),
                      contentPadding: fieldPadding,
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF01B14E), size: 28),
                      iconSize: 28,
                      iconEnabledColor: Color(0xFF01B14E),
                    ),
                    buttonStyleData: ButtonStyleData(
                      height: fieldHeight,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      elevation: 8,
                      maxHeight: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            spreadRadius: 3,
                            offset: Offset(2, 10),
                          ),
                        ],
                      ),
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height: 56,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      overlayColor: MaterialStateProperty.all(Color(0xFF01B14E).withOpacity(0.09)),
                    ),
                    items: jenisTanamanList.map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Row(
                          children: [
                            Icon(
                              item == "Tanaman Bunga"
                                  ? Icons.local_florist_rounded
                                  : item == "Tanaman Buah"
                                      ? Icons.eco_rounded
                                      : Icons.park_rounded,
                              color: Color(0xFF01B14E),
                              size: 22,
                            ),
                            SizedBox(width: 18),
                            Text(
                              item,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ),
                ),
                SizedBox(height: 28),
                // Tombol Tambahkan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      backgroundColor: const Color(0xFF01B14E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: Text(
                      'Tambahkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
