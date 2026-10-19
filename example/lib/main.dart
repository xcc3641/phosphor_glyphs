import 'package:flutter/material.dart';
import 'package:phosphor_glyphs/phosphor_glyphs.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phosphor Icons',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _query = '';
  bool _duotone = false;

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    // `values` references every glyph, so this gallery keeps the whole bold
    // and duotone fonts. Apps that name icons directly
    // (PhosphorIconsBold.acorn) only ship the glyphs they use.
    final Map<String, Object> all =
        _duotone ? PhosphorIconsDuotone.values : PhosphorIconsBold.values;
    final icons =
        all.entries.where((e) => e.key.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Phosphor ${_duotone ? 'duotone' : 'bold'} · ${icons.length}',
        ),
        actions: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(PhosphorIconsBold.acorn),
                label: Text('Bold'),
              ),
              ButtonSegment(
                value: true,
                icon: PhosphorDuotoneIcon(PhosphorIconsDuotone.acorn),
                label: Text('Duotone'),
              ),
            ],
            selected: {_duotone},
            onSelectionChanged: (s) => setState(() => _duotone = s.single),
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search icons',
                prefixIcon: Icon(PhosphorIconsBold.magnifyingGlass),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 112,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final MapEntry(key: name, value: icon) = icons[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              switch (icon) {
                final PhosphorDuotoneIconData d =>
                  PhosphorDuotoneIcon(d, size: 32),
                final IconData i => Icon(i, size: 32),
                _ => const SizedBox.square(dimension: 32),
              },
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
