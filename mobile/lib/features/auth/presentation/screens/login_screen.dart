import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_colors.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/core/constants/app_strings.dart';
import 'package:tirta/core/utils/validators.dart';
import 'package:tirta/features/auth/presentation/providers/auth_provider.dart';
import 'package:tirta/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tirta/shared/widgets/tirta_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }

      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        context.go(AppRoutes.dashboard);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Title
                  Icon(
                    Icons.water_drop,
                    size: 64.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Error display
                  if (authState.error != null) ...[
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.error, size: 20.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Email field
                  AuthTextField(
                    label: AppStrings.email,
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  SizedBox(height: 16.h),

                  // Password field
                  AuthTextField(
                    label: AppStrings.password,
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push(AppRoutes.forgotPassword);
                      },
                      child: Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Login button
                  TirtaButton(
                    text: AppStrings.login,
                    isLoading: authState.isLoading,
                    onPressed: _handleLogin,
                  ),
                  SizedBox(height: 32.h),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccount,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.register);
                        },
                        child: Text(
                          AppStrings.registerNow,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
