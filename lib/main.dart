import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

final List<XFile> capturedClothingPhotos = [];
final ValueNotifier<String?> selectedGenderNotifier = ValueNotifier(null);

// Hive box for users
late Box<Map> usersBox;

class UserData {
  final String username;
  final String password;
  final String name;
  final String gender;
  final String language;

  UserData({
    required this.username,
    required this.password,
    required this.name,
    required this.gender,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'gender': gender,
      'language': language,
    };
  }

  static UserData fromMap(Map<dynamic, dynamic> map) {
    return UserData(
      username: map['username'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      gender: map['gender'] as String,
      language: map['language'] as String,
    );
  }
}

class AuthService {
  static Future<bool> registerUser(UserData user) async {
    try {
      if (usersBox.containsKey(user.username)) {
        return false;
      }
      await usersBox.put(user.username, user.toMap());
      return true;
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  static Future<UserData?> loginUser(
      String username, String password) async {
    try {
      if (!usersBox.containsKey(username)) {
        return null;
      }
      final userData = usersBox.get(username) as Map;
      if (userData['password'] == password) {
        return UserData.fromMap(userData);
      }
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  static Future<UserData?> getUserByUsername(String username) async {
    try {
      if (!usersBox.containsKey(username)) {
        return null;
      }
      final userData = usersBox.get(username) as Map;
      return UserData.fromMap(userData);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }
}

Color _genderThemeColor(String? gender) {
  switch (gender) {
    case 'Female':
      return const Color(0xFFD36C9A);
    case 'Male':
      return const Color(0xFF4A90E2);
    default:
      return Colors.black;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  usersBox = await Hive.openBox<Map>('users');
  runApp(const WearaApp());
}

class WearaApp extends StatelessWidget {
  const WearaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedGenderNotifier,
      builder: (context, selectedGender, child) {
        final themeColor = _genderThemeColor(selectedGender);
        return MaterialApp(
          title: 'Weara',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeColor,
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          home: const SplashScreen(),
        );
      },
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

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = await AuthService.loginUser(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        selectedGenderNotifier.value = user.gender;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SelfieScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newUser = UserData(
        username: _usernameController.text,
        password: _passwordController.text,
        name: _nameController.text,
        gender: _selectedGender ?? 'Other',
        language: _selectedLanguage ?? 'English',
      );

      final success = await AuthService.registerUser(newUser);

      if (!mounted) return;

      if (success) {
        selectedGenderNotifier.value = _selectedGender;
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SelfieScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username already exists'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                    selectedGenderNotifier.value = value;
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
      appBar: AppBar(title: const Text('Take Selfie')),
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
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                                child: const Text('Restart'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _goToPlan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
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
      appBar: AppBar(title: const Text('Choose Your Pack')),
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
                final isFemale = selectedGenderNotifier.value == 'Female';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => isFemale
                        ? const FemaleFreeCategoryScreen()
                        : const ClothesCategoryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF1493),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Free'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final isFemale = selectedGenderNotifier.value == 'Female';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => isFemale
                        ? const FemaleClothesScreen()
                        : const PremiumCategoryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB6C1),
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

class FemaleFreeCategoryScreen extends StatelessWidget {
  const FemaleFreeCategoryScreen({super.key});

  static const List<Map<String, String>> _femaleCategories = [
    {
      'name': 'Shorts',
      'image': 'assets/female/1_shorts.jpg',
    },
    {
      'name': 'Dresses',
      'image': 'assets/female/4_dress.jpg',
    },
    {
      'name': 'Skirts',
      'image': 'assets/female/5_skirts.jpg',
    },
    {
      'name': 'Pants/Sweats',
      'image': 'assets/female/6_pants.jpg',
    },
    {
      'name': 'Jeans',
      'image': 'assets/female/7_jeans.jpg',
    },
    {
      'name': 'Shirts',
      'image': 'assets/female/8_shirts.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select'),
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
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: _femaleCategories.map((item) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ClothesCameraScreen(category: item['name']!),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(100),
                                  child: const Center(
                                    child: Icon(
                                      Icons.checkroom,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(150),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item['name']!,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                backgroundColor:
                    Theme.of(context).colorScheme.primary,
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

class FemaleClothesScreen extends StatelessWidget {
  const FemaleClothesScreen({super.key});

  static const List<Map<String, String>> _femaleCategories = [
    {'name': 'Shorts', 'image': 'assets/female/1_shorts.jpg'},
    {'name': 'Shoes', 'image': 'assets/female/2_shoes.jpg'},
    {'name': 'Jewelry', 'image': 'assets/female/3_jewelry.jpg'},
    {'name': 'Dresses', 'image': 'assets/female/4_dress.jpg'},
    {'name': 'Skirts', 'image': 'assets/female/5_skirts.jpg'},
    {'name': 'Pants/Sweats', 'image': 'assets/female/6_pants.jpg'},
    {'name': 'Jeans', 'image': 'assets/female/7_jeans.jpg'},
    {'name': 'Shirts', 'image': 'assets/female/8_shirts.jpg'},
    {'name': 'Bags', 'image': 'assets/female/9_bags.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select')),
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
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: _femaleCategories.map((item) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ClothesCameraScreen(category: item['name']!),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(100),
                                  child: const Center(
                                    child: Icon(
                                      Icons.checkroom,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(150),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item['name']!,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
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

  static String _getCategoryImage(String category) {
    switch (category) {
      case 'Shirts':
        return 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop';
      case 'Skirts':
        return 'https://images.unsplash.com/photo-1598305245394-8e4b77285028?w=300&h=300&fit=crop';
      case 'Jeans':
        return 'https://images.unsplash.com/photo-1542272604-787c62d465d1?w=300&h=300&fit=crop';
      case 'Dresses':
        return 'https://images.unsplash.com/photo-1595777707802-41d92a8ef921?w=300&h=300&fit=crop';
      case 'Shorts':
        return 'https://images.unsplash.com/photo-1612818498360-9e4b235f046d?w=300&h=300&fit=crop';
      case 'Pants/Sweats':
        return 'https://images.unsplash.com/photo-1506629082847-11d82165b63d?w=300&h=300&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select')),
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
                childAspectRatio: 1.0,
                children: _categories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ClothesCameraScreen(category: category),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _getCategoryImage(category),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(100),
                                  child: Center(
                                    child: Icon(
                                      Icons.checkroom,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(50),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(150),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                category,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
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

  static String _getCategoryImage(String category) {
    switch (category) {
      case 'Shirts':
        return 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop';
      case 'Skirts':
        return 'https://images.unsplash.com/photo-1598305245394-8e4b77285028?w=300&h=300&fit=crop';
      case 'Jeans':
        return 'https://images.unsplash.com/photo-1542272604-787c62d465d1?w=300&h=300&fit=crop';
      case 'Dresses':
        return 'https://images.unsplash.com/photo-1595777707802-41d92a8ef921?w=300&h=300&fit=crop';
      case 'Shorts':
        return 'https://images.unsplash.com/photo-1612818498360-9e4b235f046d?w=300&h=300&fit=crop';
      case 'Pants/Sweats':
        return 'https://images.unsplash.com/photo-1506629082847-11d82165b63d?w=300&h=300&fit=crop';
      case 'Jewelry':
        return 'https://images.unsplash.com/photo-1515562141207-5dab665231df?w=300&h=300&fit=crop';
      case 'Bags':
        return 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=300&h=300&fit=crop';
      case 'Shoes':
        return 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=300&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Categories')),
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ClothesCameraScreen(category: category),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _getCategoryImage(category),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(100),
                                  child: const Center(
                                    child: Icon(
                                      Icons.checkroom,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(50),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(150),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                category,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
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
      appBar: AppBar(title: Text(widget.category)),
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
      appBar: AppBar(title: const Text('Outfit Creation')),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
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
      appBar: AppBar(title: const Text('Create Outfit Criteria')),
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
                backgroundColor: _canGenerate
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
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
      appBar: AppBar(title: const Text('Generated Outfits')),
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
