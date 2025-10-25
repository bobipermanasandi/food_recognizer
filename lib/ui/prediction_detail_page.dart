import 'package:food_recognizer/widgets/confidence_indicator.dart';
import 'package:food_recognizer/widgets/ingredient_item.dart';
import 'package:food_recognizer/widgets/nutrition_card.dart';
import 'package:food_recognizer/widgets/section_widget.dart';
import 'package:food_recognizer/widgets/step_item.dart';
import 'package:flutter/material.dart';

class PredictionDetailPage extends StatelessWidget {
  final String imageUrl;
  const PredictionDetailPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Prediksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nasi Goreng',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text('Kepercayaan 92%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: -8,
                        children: const [
                          Chip(label: Text('Indonesia')),
                          Chip(label: Text('Pedas')),
                          Chip(label: Text('Nasi')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionWidget(
              title: 'Prediksi makanan',
              child: Builder(
                builder: (context) {
                  final double confidence = 0.87; // contoh nilai
                  final int percent = (confidence * 100).round();
                  final String note = confidence >= 0.85
                      ? 'Sangat yakin dengan prediksi ini'
                      : (confidence >= 0.6
                            ? 'Cukup yakin dengan prediksi ini'
                            : 'Perlu verifikasi ulang terhadap prediksi ini');

                  final Color accent = () {
                    if (confidence >= 0.85) {
                      return Colors.green;
                    } else if (confidence >= 0.6) {
                      return Colors.amber.shade700;
                    } else {
                      return Colors.red;
                    }
                  }();
                  return Card(
                    elevation: 4,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: ConfidenceIndicator(
                              value: confidence,
                              color: accent,
                              text: '$percent%',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tingkat kepercayaan',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  note,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: -8,
                                  children: [
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: accent.withValues(
                                        alpha: 0.12,
                                      ),
                                      avatar: Icon(
                                        Icons.insights_rounded,
                                        size: 18,
                                        color: accent,
                                      ),
                                      label: Text(
                                        percent >= 85
                                            ? 'Confidence: Tinggi'
                                            : (percent >= 60
                                                  ? 'Confidence: Sedang'
                                                  : 'Confidence: Rendah'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(color: accent),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SectionWidget(
              title: 'Deskripsi',
              child: const Text(
                'Nasi goreng adalah hidangan nasi yang digoreng dengan bumbu seperti kecap, bawang, dan cabai, sering disajikan dengan telur dan kerupuk.',
              ),
            ),
            const SizedBox(height: 16),
            DefaultTabController(
              length: 2,
              child: Builder(
                builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor:
                            theme.colorScheme.onSurfaceVariant,
                        indicatorColor: theme.colorScheme.primary,
                        tabs: const [
                          Tab(text: 'Resep'),
                          Tab(text: 'Nutrisi'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: AnimatedBuilder(
                          animation: DefaultTabController.of(
                            context,
                          ).animation!,
                          builder: (context, _) {
                            final controller = DefaultTabController.of(context);

                            Widget recipe = SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bahan',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Card(
                                    elevation: 0,
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          IngredientItem(
                                            text: '2 porsi nasi putih dingin',
                                          ),
                                          IngredientItem(
                                            text:
                                                '2 siung bawang putih, cincang',
                                          ),
                                          IngredientItem(text: '1 butir telur'),
                                          IngredientItem(
                                            text:
                                                '1 sdm kecap manis, garam, merica',
                                          ),
                                          IngredientItem(
                                            text: 'Minyak untuk menumis',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Langkah-langkah',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  const StepItem(
                                    number: 1,
                                    text: 'Tumis bawang hingga harum.',
                                  ),
                                  const StepItem(
                                    number: 2,
                                    text: 'Masukkan telur, orak-arik.',
                                  ),
                                  const StepItem(
                                    number: 3,
                                    text:
                                        'Tambahkan nasi, bumbu, dan kecap. Aduk rata.',
                                  ),
                                  const StepItem(
                                    number: 4,
                                    text:
                                        'Masak hingga nasi panas dan bumbu meresap.',
                                  ),
                                ],
                              ),
                            );

                            Widget nutrition = SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: const [
                                  NutritionTileCard(
                                    label: 'Kalori',
                                    value: '520 kcal',
                                    icon: Icons.local_fire_department_rounded,
                                  ),
                                  NutritionTileCard(
                                    label: 'Protein',
                                    value: '14 g',
                                    icon: Icons.fitness_center_rounded,
                                  ),
                                  NutritionTileCard(
                                    label: 'Lemak',
                                    value: '18 g',
                                    icon: Icons.opacity_rounded,
                                  ),
                                  NutritionTileCard(
                                    label: 'Karbohidrat',
                                    value: '72 g',
                                    icon: Icons.grain_rounded,
                                  ),
                                  NutritionTileCard(
                                    label: 'Serat',
                                    value: '3 g',
                                    icon: Icons.eco_rounded,
                                  ),
                                ],
                              ),
                            );

                            final pages = [recipe, nutrition];

                            return SizedBox(
                              height: 300,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.02, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey<int>(controller.index),
                                  child: pages[controller.index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Bagikan'),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
