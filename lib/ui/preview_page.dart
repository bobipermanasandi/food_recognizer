import 'package:food_recognizer/ui/prediction_detail_page.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatefulWidget {
  final String imageUrl;
  final String sourceLabel;
  const PreviewPage({
    super.key,
    required this.imageUrl,
    required this.sourceLabel,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  Rect? _fakeCropRect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Gambar'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(label: Text(widget.sourceLabel)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(widget.imageUrl, fit: BoxFit.cover),
                    ),
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (_fakeCropRect != null)
                      Positioned(
                        left: _fakeCropRect!.left,
                        top: _fakeCropRect!.top,
                        width: _fakeCropRect!.width,
                        height: _fakeCropRect!.height,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.secondary,
                              width: 3,
                            ),
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.06,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.crop_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Crop'),
                    ),
                    onPressed: () {
                      setState(() {
                        _fakeCropRect = const Rect.fromLTWH(40, 40, 200, 200);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.analytics_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Lanjut Prediksi'),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PredictionDetailPage(imageUrl: widget.imageUrl),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
