import 'package:flutter/material.dart';
import 'package:font_fit/font_fit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Demo2( ),
    );
  }
}
 
 

class Demo extends StatelessWidget {
  const Demo({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SafeText Demo')),
        body: Center(
          child: SizedBox(
            // width: double.infinity,
            child: FontFit(
              
              'A very very very long ksdncksdjn sdkcnksn  dkjcnskdjncdscnldsc lakncsalkjncs dclkjsdcsd clkjscnsd cbdsfc djsa c ashjdlbcaksdbcas dclasjkdcnas dcjlksadncasl kdc',
              style: const TextStyle(fontSize: 24),
              minFontSize: 10,
              maxFontSize: 23,
              maxLines: 5,
            ),
          ),
        ),
      ),
    );
  }
}

 
class Demo2 extends StatelessWidget {
  const Demo2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('FontFit Demo')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Test inside a Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue.shade50,
                      padding: const EdgeInsets.all(8),
                      child: FontFit(
                        'Row Item 1: Very very long text that should shrink nicely',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        minFontSize: 8,
                        maxFontSize: 24,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.green.shade50,
                      padding: const EdgeInsets.all(8),
                      child: FontFit(
                        'Row Item 2: Another long text to test side by side shrink',
                        style: const TextStyle(fontSize: 20),
                        minFontSize: 10,
                        maxFontSize: 22,
                        maxLines: 3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Test inside a Column with Expanded
              Container(
                height: 200,
                color: Colors.orange.shade50,
                child: Column(
                  children: [
                    Expanded(
                      child: FontFit(
                        'This is inside a Column → Expanded widget, text should shrink vertically if needed',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                        minFontSize: 12,
                        maxFontSize: 28,
                        maxLines: 4,
                      ),
                    ),
                    Expanded(
                      child: FontFit(
                        'Second Expanded inside Column, more text to see balancing of available space.',
                        style: const TextStyle(fontSize: 20, color: Colors.deepPurple),
                        minFontSize: 10,
                        maxFontSize: 22,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Test inside a Card with padding
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FontFit(
                    'This is a Card. Sometimes cards have restricted width/height. '
                    'Let’s add more and more text to see if the FontFit adjusts gracefully.',
                    style: const TextStyle(fontSize: 24),
                    minFontSize: 8,
                    maxFontSize: 24,
                    maxLines: 6,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Test inside a GridView (nested in SizedBox for height)
              SizedBox(
                height: 180,
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      color: Colors.pink.shade50,
                      child: FontFit(
                        'Grid Item #$index — Long text inside a grid cell, should shrink properly.',
                        style: const TextStyle(fontSize: 20),
                        minFontSize: 10,
                        maxFontSize: 22,
                        maxLines: 3,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Test inside a SingleChildScrollView
              Container(
                height: 150,
                color: Colors.teal.shade50,
                child: SingleChildScrollView(
                  child: FontFit(
                    'Scrollable area → A very very long text that should shrink, '
                    'but we also allow scrolling so it shouldn’t break anything. '
                    'This is for testing edge cases when text is both shrinkable and scrollable. '
                    'Keep adding more lines to stress test.',
                    style: const TextStyle(fontSize: 22),
                    minFontSize: 8,
                    maxFontSize: 22,
                    maxLines: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
