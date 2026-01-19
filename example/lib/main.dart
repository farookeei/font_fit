import 'package:flutter/material.dart';
import 'package:font_fit/font_fit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FontFit Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const FontFitShowcase(),
    );
  }
}

class FontFitShowcase extends StatelessWidget {
  const FontFitShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FontFit Showcase'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Cards & Headers'),
              Tab(text: 'Buttons & Chips'),
              Tab(text: 'Responsive'),
              Tab(text: 'List Performance'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CardsDemoTab(),
            ButtonsDemoTab(),
            ResponsiveDemoTab(),
            ListPerformanceTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 1: Real-world Cards & Headers
// ---------------------------------------------------------------------------
class CardsDemoTab extends StatelessWidget {
  const CardsDemoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader('Product Cards'),
        SizedBox(
          height: 140,
          child: Row(
            children: [
              _buildProductCard(
                title: 'Wireless Headphones Version',
                price: '\$199.99',
                color: Colors.blue.shade50,
              ),
              const SizedBox(width: 10),
              _buildProductCard(
                title: 'Super Ultra Premium 4K Gaming Monitor 144Hz',
                price: '\$459.00',
                color: Colors.orange.shade50,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader('News Headlines (Fixed Height)'),
        Container(
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.newspaper, size: 40, color: Colors.indigo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FontFit(
                        'Breaking: Flutter 4.0 Release Changes Everything We Know About Widgets',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                        maxLines: 2,
                        minFontSize: 12,
                      ),
                    ),
                    const Text(
                      '2 hours ago',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 32),
            const Spacer(),
            // The constraint: Title must fit in 2 lines max
            SizedBox(
              // height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FontFit(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  minFontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2: Buttons & Chips
// ---------------------------------------------------------------------------
class ButtonsDemoTab extends StatelessWidget {
  const ButtonsDemoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Resizing Buttons'),
          const Text(
            'These buttons have fixed widths. The text shrinks to fit.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFixedButton("OK", width: 80),
              const SizedBox(width: 10),
              _buildFixedButton("Submit Order", width: 100),
              const SizedBox(width: 10),
              _buildFixedButton("Add to Shopping Cart Now", width: 120),
            ],
          ),
          const SizedBox(height: 30),
          const SectionHeader('Status Chips'),
          Container(
            width: 150,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Column(
              children: [
                _buildChip('Active'),
                const SizedBox(height: 8),
                _buildChip('Pending Review Authorization'),
                const SizedBox(height: 8),
                _buildChip('Cancelled by User (Late)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedButton(String label, {required double width}) {
    return Container(
      width: width,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FontFit(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        minFontSize: 8,
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      height: 30,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: FontFit(
        label,
        style: TextStyle(
          color: Colors.indigo.shade800,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 3: Responsive Slider Demo
// ---------------------------------------------------------------------------
class ResponsiveDemoTab extends StatefulWidget {
  const ResponsiveDemoTab({super.key});

  @override
  State<ResponsiveDemoTab> createState() => _ResponsiveDemoTabState();
}

class _ResponsiveDemoTabState extends State<ResponsiveDemoTab> {
  double _width = 300;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Drag slider to resize',
          style: TextStyle(color: Colors.grey),
        ),
        Slider(
          value: _width,
          min: 50,
          max: 350,
          onChanged: (v) => setState(() => _width = v),
        ),
        const SizedBox(height: 20),
        Container(
          width: _width,
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.indigo, width: 2),
            color: Colors.indigo.shade50,
          ),
          child: Center(
            child: FontFit(
              'Resize Me!',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              maxLines: 1,
              minFontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('Width: ${_width.toStringAsFixed(1)}'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 4: List Performance Test
// ---------------------------------------------------------------------------
class ListPerformanceTab extends StatelessWidget {
  const ListPerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Rendering 1000 items. Thanks to optimizations in v0.0.2 (Cached TextPainter), scrolling should remain smooth.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 1000,
            itemBuilder: (context, index) {
              // Alternate long/short text
              final text = index % 2 == 0
                  ? 'Item #$index'
                  : 'Item #$index has significantly longer detailed text to force resizing logic.';

              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(child: Text('${index % 10}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FontFit(
                        text,
                        style: const TextStyle(fontSize: 22),
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}
