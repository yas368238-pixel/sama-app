import 'package:flutter/material.dart';

void main() {
  runApp(const SamaApp());
}

class SamaApp extends StatelessWidget {
  const SamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ImageGeneratorScreen(),
    );
  }
}

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;
  bool _hasError = false;

  void _generateImage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      final encodedText = Uri.encodeComponent(text);
      _imageUrl = 'https://pollinations.ai/p/$encodedText?width=1024&height=1024&seed=${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('هوش مصنوعی سما (Sama)'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageUrl == null
                        ? const Center(child: Text('متن خود را وارد کرده و دکمه خلق تصویر را بزنید.'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (_isLoading) setState(() => _isLoading = false);
                                  });
                                  return child;
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (_isLoading || !_hasError) {
                                    setState(() {
                                      _isLoading = false;
                                      _hasError = true;
                                    });
                                  }
                                });
                                return const Center(child: Text('خطا در دریافت تصویر از سرور. دوباره تلاش کنید.'));
                              },
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'توصیف تصویر مورد نظر به فارسی یا انگلیسی...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('خلق تصویر', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

