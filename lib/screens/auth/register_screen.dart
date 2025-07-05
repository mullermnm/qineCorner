import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/screens/auth/login_screen.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/theme/app_colors.dart';
import 'package:qine_corner/core/theme/auth_constants.dart';
import 'package:qine_corner/screens/auth/verification_screen.dart';
import 'package:qine_corner/screens/auth/widgets/auth_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  static const Color kPrimaryColor = AppColors.accentMint;
  static const Color kPrimaryLightColor = AppColors.lightBackground;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Make sure to pass the email to the registration
      final result = await ref.read(authNotifierProvider.notifier).register(
            name: _nameController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            email: _emailController.text, // Add email parameter
          );

      if (mounted) {
        // Show verification screen after successful registration
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              userId: result['userId'],
              phone: result['phone'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error in UI and print to console for debugging
        print('Registration error: $e');
        setState(() {
          _error = e.toString();
        });
        // Show a snackbar with the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Registration failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
                "SIGN UP",
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
                  Icons.menu_book,
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
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.black),
                        decoration: AuthConstants.textFieldDecoration(
                          labelText: "Name",
                          hintText: "Your Name",
                          icon: Icons.person,
                        ).copyWith(
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: kPrimaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.black),
                        decoration: AuthConstants.textFieldDecoration(
                          labelText: "Email",
                          hintText: "Email",
                          icon: Icons.email,
                        ).copyWith(
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: kPrimaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Add email format validation
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.black),
                        decoration: AuthConstants.textFieldDecoration(
                          labelText: "Phone Number",
                          hintText: "Phone Number",
                          icon: Icons.phone,
                        ).copyWith(
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: kPrimaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit phone number';
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
                          labelText: "Password",
                          labelStyle: const TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: "Password",
                          hintStyle: const TextStyle(
                            color: kPrimaryColor,
                          ),
                          prefixIcon: Icon(Icons.lock,
                              color: AuthConstants.kPrimaryColor),
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
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordConfirmationController,
                        obscureText: true,
                        style: TextStyle(color: Colors.black),
                        decoration: AuthConstants.textFieldDecoration(
                          labelText: "Confirm Password",
                          hintText: "Confirm Password",
                          icon: Icons.lock,
                        ).copyWith(
                          hintStyle: const TextStyle(color: Colors.black54),
                          labelStyle: const TextStyle(color: kPrimaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: AuthConstants.elevatedButtonStyle(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    "SIGN UP",
                                    style: AuthConstants.buttonTextStyle,
                                  ),
                          ),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      "Already have an account? Sign In",
                      style: AuthConstants.linkTextStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
