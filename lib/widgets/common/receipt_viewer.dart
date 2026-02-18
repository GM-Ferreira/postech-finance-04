import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

class ReceiptViewer {
  static void show(BuildContext context, {File? file, String? url}) {
    assert(file != null || url != null, 'Deve passar file ou url');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Comprovante'),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
              automaticallyImplyLeading: false,
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: file != null
                  ? Image.file(file, fit: BoxFit.contain)
                  : CachedNetworkImage(
                      imageUrl: url!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              SizedBox(height: 8),
                              Text('Erro ao carregar imagem'),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
