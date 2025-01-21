// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:qine_corner/common/widgets/loading_animation.dart';
// import 'package:qine_corner/core/providers/auth_provider.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';

// class AuthScreen extends ConsumerStatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   ConsumerState<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends ConsumerState<AuthScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _otpController = TextEditingController();
//   bool _isLoading = false;
//   bool _isRegistering = true;
//   int? _userId;
//   String? _otp;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _nameController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final result = await ref.read(authProvider.notifier).register(
//             name: _nameController.text,
//             phone: _phoneController.text,
//             password: _passwordController.text,
//             passwordConfirmation: _confirmPasswordController.text,
//           );

//       setState(() {
//         _userId = result.userId as int?;
//         _otp = result.otp;
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       await ref.read(authProvider.notifier).login(
//             phone: _phoneController.text,
//             password: _passwordController.text,
//           );
//       if (mounted) {
//         context.go('/home');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _verifyPhone() async {
//     if (!_formKey.currentState!.validate() || _userId == null) return;

//     setState(() => _isLoading = true);

//     try {
//       await ref.read(authProvider.notifier).verifyPhone(
//             userId: _userId!,
//             otp: _otpController.text,
//           );
//       if (mounted) {
//         context.go('/home');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_userId != null
//             ? 'Verify Phone'
//             : (_isRegistering ? 'Register' : 'Login')),
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             if (_userId == null) ...[
//               if (_isRegistering) ...[
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Full Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) =>
//                       value?.isEmpty == true ? 'Please enter your name' : null,
//                 ),
//                 const SizedBox(height: 16),
//               ],
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) => value?.isEmpty == true
//                     ? 'Please enter your phone number'
//                     : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) => value?.isEmpty == true
//                     ? 'Please enter your password'
//                     : null,
//               ),
//               if (_isRegistering) ...[
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _confirmPasswordController,
//                   decoration: const InputDecoration(
//                     labelText: 'Confirm Password',
//                     border: OutlineInputBorder(),
//                   ),
//                   obscureText: true,
//                   validator: (value) => value != _passwordController.text
//                       ? 'Passwords do not match'
//                       : null,
//                 ),
//               ],
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed:
//                     _isLoading ? null : (_isRegistering ? _register : _login),
//                 child: _isLoading
//                     ? const LoadingAnimation()
//                     : Text(_isRegistering ? 'Register' : 'Login'),
//               ),
//               TextButton(
//                 onPressed: _isLoading
//                     ? null
//                     : () => setState(() => _isRegistering = !_isRegistering),
//                 child: Text(_isRegistering
//                     ? 'Already have an account? Login'
//                     : 'Don\'t have an account? Register'),
//               ),
//             ] else ...[
//               if (_otp != null) ...[
//                 Text(
//                   'Development OTP: $_otp',
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 const SizedBox(height: 16),
//               ],
//               PinCodeTextField(
//                 appContext: context,
//                 length: 6,
//                 controller: _otpController,
//                 onChanged: (value) {},
//                 pinTheme: PinTheme(
//                   shape: PinCodeFieldShape.box,
//                   borderRadius: BorderRadius.circular(8),
//                   fieldHeight: 50,
//                   fieldWidth: 40,
//                   activeFillColor: Colors.white,
//                   inactiveFillColor: Colors.white,
//                   selectedFillColor: Colors.white,
//                   activeColor: Theme.of(context).primaryColor,
//                   inactiveColor: Colors.grey,
//                   selectedColor: Theme.of(context).primaryColor,
//                 ),
//                 keyboardType: TextInputType.number,
//                 enableActiveFill: true,
//                 validator: (value) =>
//                     value?.isEmpty == true ? 'Please enter the OTP code' : null,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _verifyPhone,
//                 child: _isLoading
//                     ? const LoadingAnimation()
//                     : const Text('Verify Phone'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
