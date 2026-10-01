import 'package:flutter/material.dart';
import 'package:phosphor_icons_flutter/phosphor_icons_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    // PhosphorIconsBold.values references every glyph, so this gallery keeps
    // the whole bold font. Apps that name icons directly
    // (PhosphorIconsBold.acorn) only ship the glyphs they use.
    final icons = PhosphorIconsBold.values.entries
        .where((e) => e.key.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Phosphor bold · ${icons.length}'),
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
              Icon(icon, size: 32),
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
