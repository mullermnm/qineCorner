import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/core/theme/auth_constants.dart';
import 'package:qine_corner/screens/auth/verification_screen.dart';
import 'package:qine_corner/screens/auth/widgets/auth_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  static const Color kPrimaryColor = AppColors.accentMint;
  static const Color kPrimaryLightColor = AppColors.lightBackground;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ref.read(authNotifierProvider.notifier).login(
            phone: _phoneController.text,
            password: _passwordController.text,
          );

      if (mounted) {
        if (!result['isVerified']) {
          // Show verification screen if phone is not verified
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                userId: result['userId'],
                phone: result['phone'],
              ),
            ),
          );
        } else {
          // Navigate to home screen
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        
        // Show error in snackbar for better visibility
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.1),
              const Text(
                "LOGIN",
                style: AuthConstants.titleStyle,
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AuthConstants.kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories,
                  size: 100,
                  color: AuthConstants.kPrimaryColor,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                width: size.width * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(29),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.black),
                        decoration: AuthConstants.textFieldDecoration(
                          labelText: "Phone",
                          hintText: "Your Phone",
                          icon: Icons.phone,
                        ).copyWith(
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: kPrimaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AuthConstants.kPrimaryColor,
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: Colors.black54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: const BorderSide(color: kPrimaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: const BorderSide(color: kPrimaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: const BorderSide(
                                color: kPrimaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: kPrimaryLightColor,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: AuthConstants.elevatedButtonStyle(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "LOGIN",
                                    style: AuthConstants.buttonTextStyle,
                                  ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an Account? ",
                    style: TextStyle(color: AuthConstants.kPrimaryColor),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      "Sign Up",
                      style: AuthConstants.linkTextStyle,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text(
                  "Forgot Password?",
                  style: AuthConstants.linkTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
