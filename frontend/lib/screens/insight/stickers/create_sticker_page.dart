import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/sticker_service.dart';
import '../../../generated/l10n/app_localizations.dart';

class CreateStickerPage extends StatefulWidget {
  const CreateStickerPage({super.key});

  @override
  State<CreateStickerPage> createState() => _CreateStickerPageState();
}

class _CreateStickerPageState extends State<CreateStickerPage> {
  final StickerService _stickerService = StickerService();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isPublic = false;
  bool _isProcessing = false;
  bool _isUploading = false;
  bool _backgroundRemoved = false;

  static const Color primaryBlue = Color(0xFF3B82F6);

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _backgroundRemoved = false;
      });
    }
  }

  Future<void> _removeBackground() async {
    setState(() => _isProcessing = true);
    
    // Simulate background removal processing
    // In a real app, this would call a backend API or a local ML model
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isProcessing = false;
      _backgroundRemoved = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.backgroundRemovedSuccessfully)),
    );
  }

  Future<void> _saveSticker() async {
    if (_selectedImage == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectImageAndEnterName)),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      await _stickerService.createSticker(
        name: _nameController.text,
        isPublic: _isPublic,
        imageFile: _selectedImage!,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToSaveSticker)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createSticker, style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Card
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primaryBlue.withValues(alpha: 0.1), width: 2),
                  image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.contain,
                        opacity: _isProcessing ? 0.3 : 1.0,
                      )
                    : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_selectedImage == null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context)!.selectAPhoto, style: TextStyle(color: Colors.grey.shade400)),
                        ],
                      ),
                    if (_isProcessing)
                      _buildScanAnimation(),
                    if (_backgroundRemoved && !_isProcessing)
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.objectSelected, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),


            
            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing || _isUploading ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(AppLocalizations.of(context)!.changePhoto),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: primaryBlue.withValues(alpha: 0.5)),
                      foregroundColor: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_selectedImage != null && !_isProcessing && !_isUploading && !_backgroundRemoved) 
                        ? _removeBackground 
                        : null,
                    icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.alphaMask, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Text(AppLocalizations.of(context)!.collectionSettings, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.stickerName,
                hintText: AppLocalizations.of(context)!.stickerNameHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.label_outline, color: primaryBlue),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: Text(AppLocalizations.of(context)!.makePublic, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(AppLocalizations.of(context)!.makePublicSubtitle),
                value: _isPublic,
                onChanged: (val) => setState(() => _isPublic = val),
                activeColor: primaryBlue,
              ),
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading || _selectedImage == null ? null : _saveSticker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  shadowColor: primaryBlue.withValues(alpha: 0.3),
                ),
                child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(AppLocalizations.of(context)!.finishAndAddToCollection, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  Widget _buildScanAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: primaryBlue),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.analyzingDepth, style: GoogleFonts.raleway(color: primaryBlue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              top: 280 * value,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  boxShadow: [
                    BoxShadow(color: primaryBlue.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
