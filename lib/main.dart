import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

final List<XFile> capturedClothingPhotos = [];

void main() {
  runApp(const WearaApp());
}

class WearaApp extends StatelessWidget {
  const WearaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weara',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WEARA',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your clothes. Your style.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 180,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ver. 0.1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    letterSpacing: 1,
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logging in as ${_usernameController.text}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text('Username', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your username',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Password', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedGender;
  String? _selectedLanguage;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  final List<String> _languageOptions = [
    'English',
    'French',
    'Spanish',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SelfieScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text('Name', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Username', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your username',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Password', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Confirm Password', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Re-enter your password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Gender', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _genderOptions
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedGender = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Language', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLanguage,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _languageOptions
                      .map(
                        (language) => DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedLanguage = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your language';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _submit, child: const Text('Submit')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  CameraController? _cameraController;
  XFile? _selfie;
  bool _isCameraReady = false;
  bool _isCountingDown = false;
  int _countdown = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });
      _startCountdown();
    } catch (e) {
      debugPrint('Camera init failed: $e');
    }
  }

  void _startCountdown() {
    if (!_isCameraReady || _isCountingDown) return;
    setState(() {
      _countdown = 3;
      _isCountingDown = true;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _capturePhoto();
      } else {
        setState(() {
          _countdown -= 1;
        });
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final picture = await _cameraController!.takePicture();
      setState(() {
        _selfie = picture;
      });
    } catch (e) {
      debugPrint('Failed to capture photo: $e');
    } finally {
      setState(() {
        _isCountingDown = false;
      });
    }
  }

  void _resetCapture() {
    _countdownTimer?.cancel();
    setState(() {
      _selfie = null;
      _countdown = 3;
      _isCountingDown = false;
    });
    if (_isCameraReady) {
      _startCountdown();
    }
  }

  void _goToPlan() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PlanChoiceScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Selfie'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isCameraReady && _cameraController != null)
                      CameraPreview(_cameraController!)
                    else
                      Container(
                        color: Colors.black,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    CustomPaint(painter: _PersonOutlinePainter()),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selfie == null
                                  ? _isCountingDown
                                        ? 'Hold still... Taking photo in $_countdown'
                                        : 'Stand inside the outline. Photo will be taken automatically.'
                                  : 'Photo captured! Tap restart to take another.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _resetCapture,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                child: const Text('Restart'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _goToPlan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selfie == null
                        ? 'Your photo will be captured automatically when you stand in front of the outline.'
                        : 'Tap restart to capture a new selfie.',
                    style: TextStyle(color: Colors.grey[800], fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                if (_selfie != null)
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_selfie!.path), fit: BoxFit.cover),
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

class _PersonOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color.fromRGBO(255, 255, 255, 0.85);

    final bodyWidth = size.width * 0.45;
    final bodyHeight = size.height * 0.6;
    final bodyLeft = (size.width - bodyWidth) / 2;
    final bodyTop = (size.height - bodyHeight) / 2;
    final bodyRect = Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(32)),
      paint,
    );

    final headCenter = Offset(size.width / 2, bodyTop - bodyHeight * 0.1);
    canvas.drawCircle(headCenter, bodyWidth * 0.18, paint);

    final leftArmStart = Offset(bodyLeft + 10, bodyTop + bodyHeight * 0.18);
    final leftArmEnd = Offset(
      bodyLeft - bodyWidth * 0.15,
      bodyTop + bodyHeight * 0.45,
    );
    final rightArmStart = Offset(
      bodyLeft + bodyWidth - 10,
      bodyTop + bodyHeight * 0.18,
    );
    final rightArmEnd = Offset(
      bodyLeft + bodyWidth + bodyWidth * 0.15,
      bodyTop + bodyHeight * 0.45,
    );

    canvas.drawLine(leftArmStart, leftArmEnd, paint);
    canvas.drawLine(rightArmStart, rightArmEnd, paint);

    final leftLegStart = Offset(
      bodyLeft + bodyWidth * 0.28,
      bodyTop + bodyHeight,
    );
    final leftLegEnd = Offset(
      bodyLeft + bodyWidth * 0.15,
      bodyTop + bodyHeight + bodyHeight * 0.25,
    );
    final rightLegStart = Offset(
      bodyLeft + bodyWidth * 0.72,
      bodyTop + bodyHeight,
    );
    final rightLegEnd = Offset(
      bodyLeft + bodyWidth * 0.85,
      bodyTop + bodyHeight + bodyHeight * 0.25,
    );

    canvas.drawLine(leftLegStart, leftLegEnd, paint);
    canvas.drawLine(rightLegStart, rightLegEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlanChoiceScreen extends StatelessWidget {
  const PlanChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Pack'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Choose the pack you want to continue with.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Free pack gives you basic access. Premium pack unlocks advanced features for a one-time \$5 payment.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ClothesCategoryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Free'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PremiumCategoryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Premium - \$5'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClothesCategoryScreen extends StatelessWidget {
  const ClothesCategoryScreen({super.key});

  static const List<String> _categories = [
    'Shirts',
    'Skirts',
    'Jeans',
    'Dresses',
    'Shorts',
    'Pants/Sweats',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a category to photograph clothes.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: _categories.map((category) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ClothesCameraScreen(category: category),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OutfitCreationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumCategoryScreen extends StatelessWidget {
  const PremiumCategoryScreen({super.key});

  static const List<String> _categories = [
    'Shirts',
    'Skirts',
    'Jeans',
    'Dresses',
    'Shorts',
    'Pants/Sweats',
    'Jewelry',
    'Bags',
    'Shoes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Categories'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a category to photograph items.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hair tutorials included!',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: _categories.map((category) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ClothesCameraScreen(category: category),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(12),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OutfitCreationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClothesCameraScreen extends StatefulWidget {
  final String category;
  const ClothesCameraScreen({required this.category, super.key});

  @override
  State<ClothesCameraScreen> createState() => _ClothesCameraScreenState();
}

class _ClothesCameraScreenState extends State<ClothesCameraScreen> {
  CameraController? _controller;
  final List<XFile> _capturedPhotos = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final photo = await _controller!.takePicture();
    setState(() {
      _capturedPhotos.add(photo);
      capturedClothingPhotos.add(photo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isInitialized && _controller != null
                ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Take photos of ${widget.category.toLowerCase()} for this category.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _takePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Capture Photo'),
                ),
                const SizedBox(height: 12),
                if (_capturedPhotos.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OutfitCreationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Done'),
                  ),
              ],
            ),
          ),
          if (_capturedPhotos.isNotEmpty)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(16),
                itemCount: _capturedPhotos.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_capturedPhotos[index].path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 160,
              color: Colors.white,
              child: const Center(child: Text('No photos captured yet.')),
            ),
        ],
      ),
    );
  }
}

class OutfitCreationScreen extends StatelessWidget {
  const OutfitCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Creation'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Choose your outfit criteria before creating your looks.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your generated outfits will use the clothes you photographed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OutfitOptionsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Start Creating Your Outfit'),
            ),
          ],
        ),
      ),
    );
  }
}

class OutfitOptionsScreen extends StatefulWidget {
  const OutfitOptionsScreen({super.key});

  @override
  State<OutfitOptionsScreen> createState() => _OutfitOptionsScreenState();
}

class _OutfitOptionsScreenState extends State<OutfitOptionsScreen> {
  String? _selectedLocation;
  String? _selectedStyle;
  String? _selectedWeather;

  static const List<String> _locations = [
    'Home',
    'Work',
    'Party',
    'Beach',
    'Gym',
  ];

  static const List<String> _styles = [
    'Casual',
    'Formal',
    'Sporty',
    'Elegant',
    'Street',
  ];

  static const List<String> _weathers = [
    'Sunny',
    'Rainy',
    'Snowy',
    'Windy',
    'Cloudy',
  ];

  bool get _canGenerate =>
      _selectedLocation != null &&
      _selectedStyle != null &&
      _selectedWeather != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Outfit Criteria'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select location, style, and weather to generate outfits.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              items: _locations
                  .map(
                    (location) => DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStyle,
              decoration: const InputDecoration(
                labelText: 'Style',
                border: OutlineInputBorder(),
              ),
              items: _styles
                  .map(
                    (style) =>
                        DropdownMenuItem(value: style, child: Text(style)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStyle = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedWeather,
              decoration: const InputDecoration(
                labelText: 'Weather',
                border: OutlineInputBorder(),
              ),
              items: _weathers
                  .map(
                    (weather) =>
                        DropdownMenuItem(value: weather, child: Text(weather)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWeather = value;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _canGenerate
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GeneratedOutfitsScreen(
                            location: _selectedLocation!,
                            style: _selectedStyle!,
                            weather: _selectedWeather!,
                            photos: capturedClothingPhotos,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canGenerate ? Colors.black : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class GeneratedOutfitsScreen extends StatelessWidget {
  final String location;
  final String style;
  final String weather;
  final List<XFile> photos;

  const GeneratedOutfitsScreen({
    required this.location,
    required this.style,
    required this.weather,
    required this.photos,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Outfits'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: photos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No clothes photos found. Please go back and photograph items before generating outfits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Generated for $style, $weather weather, $location.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final photo = photos[index % photos.length];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.file(
                                  File(photo.path),
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Outfit ${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'A $style outfit for $location in $weather weather using your photographed clothes.',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
