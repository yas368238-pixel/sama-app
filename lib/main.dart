import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SamaApp());
}

class SamaApp extends StatelessWidget {
  const SamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'هوش مصنوعی سما',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', 'IR')],
      locale: const Locale('fa', 'IR'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  String? _imageUrl;
  String _errorMessage = '';

  Future<void> _generateImage() async {
    final userPrompt = _promptController.text.trim();
    if (userPrompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا توصیفی برای تصویر بنویسید')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _imageUrl = null;
    });

    try {
      final encodedPrompt = Uri.encodeComponent('$userPrompt, high quality, 8k, detailed, iranian art style option');
      final imageUrl = 'https://image.pollinations.ai/prompt/$encodedPrompt?width=1024&height=1024&nologo=true&seed=${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = imageUrl;
        });
      } else {
        setState(() {
          _errorMessage = 'خطا در دریافت تصویر از سرور. دوباره تلاش کنید.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'اتصال اینترنت خود را بررسی کنید.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('هوش مصنوعی سما (Sama)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _isLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.blueAccent),
                                SizedBox(height: 16),
                                Text('در حال ساخت تصویر شما...', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          )
                        : _imageUrl != null
                            ? Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              )
                            : Center(
                                child: Text(
                                  _errorMessage.isNotEmpty
                                      ? _errorMessage
                                      : 'متن خود را بنویسید و دکمه ساخت را بزنید',
                                  style: const TextStyle(color: Colors.white54),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptController,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'مثلا: یک سیمرغ ایرانی روی قمه دماوند با استایل دیجیتال آرت...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'خلق تصویر',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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

