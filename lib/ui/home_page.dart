import 'package:food_recognizer/ui/preview_page.dart';
import 'package:food_recognizer/widgets/action_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Food Recognizer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kenali makanan dari foto Anda dan dapatkan deskripsi, resep, dan nutrisi.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ActionButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Ambil dari Galeri',
                        subtitle: 'Pilih gambar dari penyimpanan',
                        gradientColors: const [Colors.blue, Colors.blueAccent],
                        onPressed: () =>
                            _openCrop(context, sourceLabel: 'Galeri'),
                      ),
                      const SizedBox(height: 14),
                      ActionButton(
                        icon: Icons.photo_camera_rounded,
                        label: 'Ambil dari Kamera',
                        subtitle: 'Ambil foto langsung dari kamera',
                        gradientColors: const [Colors.indigo, Colors.lightBlue],
                        onPressed: () =>
                            _openCrop(context, sourceLabel: 'Kamera'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCrop(BuildContext context, {required String sourceLabel}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewPage(
          imageUrl:
              'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1600&auto=format&fit=crop',
          sourceLabel: sourceLabel,
        ),
      ),
    );
  }
}
