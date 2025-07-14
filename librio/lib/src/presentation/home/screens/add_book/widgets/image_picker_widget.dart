import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final bool isUploading;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;
  final bool hasError;

  const ImagePickerWidget({
    Key? key,
    this.selectedImage,
    this.isUploading = false,
    required this.onPickImage,
    this.onRemoveImage,
    this.hasError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? Colors.red[300]! : Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: hasError ? Colors.red[400] : Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toque para\nadicionar foto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                hasError ? Colors.red[600] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (selectedImage != null && onRemoveImage != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemoveImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
