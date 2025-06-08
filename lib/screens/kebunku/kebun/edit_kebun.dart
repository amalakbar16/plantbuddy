import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:plantbuddy/services/api_service.dart';
import 'package:hive/hive.dart';

class EditKebun extends StatefulWidget {
  final Map<String, dynamic> plant;

  const EditKebun({Key? key, required this.plant}) : super(key: key);

  @override
  _EditKebunState createState() => _EditKebunState();
}

class _EditKebunState extends State<EditKebun> {
  late TextEditingController _nameController;
  String? _selectedSpecies;
  File? _selectedImageFile;
  bool _isSaving = false;

  final List<String> _speciesOptions = [
    'Tanaman Bunga',
    'Tanaman Buah',
    'Tanaman Peneduh',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant['name'] ?? '');
    _selectedSpecies =
        widget.plant['species'] != null &&
                _speciesOptions.contains(widget.plant['species'])
            ? widget.plant['species']
            : _speciesOptions[0];
    _selectedImageFile = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePlant() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final String name = _nameController.text.trim();
      final String species = _selectedSpecies ?? _speciesOptions[0];
      String imageDataBase64;

      if (_selectedImageFile != null) {
        final bytes = await _selectedImageFile!.readAsBytes();
        imageDataBase64 = base64Encode(bytes);
      } else if (widget.plant['image_data'] != null &&
          widget.plant['image_data'].isNotEmpty) {
        imageDataBase64 = widget.plant['image_data'];
      } else {
        imageDataBase64 = '';
      }

      final int id = int.tryParse(widget.plant['id'].toString()) ?? 0;

      final userBox = Hive.box('userBox');
      final userId = userBox.get('userId', defaultValue: 0);

      // Debug: pastikan data tidak kosong
      print(
        'updatePlant debug: id=$id, userId=$userId, name=$name, species=$species, image_length=${imageDataBase64.length}',
      );

      if (id == 0 || userId == 0) {
        throw Exception('Invalid plant or user ID');
      }

      await ApiService.updatePlant(
        id: id,
        userId: userId,
        name: name,
        species: species,
        imageDataBase64: imageDataBase64,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanaman berhasil diperbarui')),
        );
        Navigator.of(context).pop(true); // KEMBALIKAN TRUE!
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui tanaman: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.plant['image_data'] != null &&
        widget.plant['image_data'].isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Edit Tanaman',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color:
                          (_selectedImageFile != null || hasImage)
                              ? Colors.grey.shade200
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            (_selectedImageFile != null || hasImage)
                                ? const Color(0xFF01B14E)
                                : Colors.grey.shade300,
                        width: 2.2,
                        style: BorderStyle.solid,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child:
                        _selectedImageFile != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImageFile!,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            )
                            : (hasImage
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(
                                    Uri.parse(
                                      'data:image/${widget.plant['image_type'] ?? 'png'};base64,${widget.plant['image_data']}',
                                    ).data!.contentAsBytes(),
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_rounded,
                                        color: Colors.grey.shade400,
                                        size: 46,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Tambah Foto",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                  ),
                  if (_selectedImageFile != null || hasImage)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFF01B14E),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Nama Tanaman
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nama Tanaman',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 56,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Jenis Tanaman (Dropdown)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jenis Tanaman',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 56,
              child: DropdownButtonFormField2<String>(
                isExpanded: true,
                value: _selectedSpecies,
                onChanged: (val) => setState(() => _selectedSpecies = val),
                decoration: InputDecoration(
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF01B14E),
                    size: 28,
                  ),
                  iconSize: 28,
                  iconEnabledColor: Color(0xFF01B14E),
                ),
                buttonStyleData: ButtonStyleData(
                  height: 56,
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
                  overlayColor: MaterialStateProperty.all(
                    Color(0xFF01B14E).withOpacity(0.09),
                  ),
                ),
                items:
                    _speciesOptions
                        .map(
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
                                  color: const Color(0xFF01B14E),
                                  size: 22,
                                ),
                                const SizedBox(width: 18),
                                Text(
                                  item,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Tombol Hapus Tanaman
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Konfirmasi Hapus'),
                              content: const Text(
                                'Yakin ingin menghapus tanaman ini?',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Batal'),
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                      );
                      if (confirmed == true) {
                        try {
                          setState(() => _isSaving = true);
                          final userBox = Hive.box('userBox');
                          final userId = userBox.get('userId', defaultValue: 0);
                          final int id =
                              int.tryParse(widget.plant['id'].toString()) ?? 0;
                          if (id == 0 || userId == 0) {
                            throw Exception('ID tanaman/user tidak valid');
                          }
                          await ApiService.deletePlant(id: id, userId: userId);

                          if (mounted) {
                            Navigator.of(context).pop(
                              true,
                            ); // pop dengan result true, agar list refresh
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tanaman berhasil dihapus!'),
                                backgroundColor: Colors.red,
                                duration: Duration(milliseconds: 1200),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus tanaman: $e'),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Hapus Tanaman',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol Simpan
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePlant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
