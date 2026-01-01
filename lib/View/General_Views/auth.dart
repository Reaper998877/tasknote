import 'package:flutter/material.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/General/theme.dart';
import 'package:tasknote/Service/authentication.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State variables
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Toggle between Login and Signup mode
  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  // Handle Form Submission
  Future<void> _submit() async {
    // Check Internet First
    bool isConnected = await CommonFunctions.checkInternet();
    if (!isConnected) {
      scaffoldMessenger(context, "No internet connection");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = Authentication(context: context);

      // Call the method from your provided code snippet
      await auth.signInWithEmailPassword(
        context,
        _isLogin,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      scaffoldMessenger(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double logoSize = CommonFunctions.getWidth(context, 0.45);
    const colors = [
      Color(0xFF54acbf),
      Color(0xFF26658c),
      Color(0xFF023859), // Vibrant Violet
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: CommonFunctions.getHeight(context, 1),
          padding: EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Header
              Container(
                height: logoSize,
                width: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      blurRadius: 35,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icon/splashLogo.png', // Replaced variable with string for copy-paste safety
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join us and start organizing your life",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),

              // Auth Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTheme.inputTextStyle(),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white70),

                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTheme.inputTextStyle(),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.lock_open_rounded,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            color: Colors.white,
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    // Confirm Password (Signup only)
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        style: AppTheme.inputTextStyle(),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isLogin ? "Login" : "Sign Up",
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Toggle Button
                    SizedBox(
                      child: _isLogin
                          ? Row(
                              mainAxisSize: .min,
                              mainAxisAlignment: .center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : _toggleMode,
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: .min,
                              mainAxisAlignment: .center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: _isLoading ? null : _toggleMode,
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // TextButton(
                    //   onPressed: _isLoading ? null : _toggleMode,
                    //   child: Text(style: TextStyle(color: Colors.white),
                    //     _isLogin
                    //         ? "Don't have an account? Sign Up"
                    //         : "Already have an account? Login",
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
