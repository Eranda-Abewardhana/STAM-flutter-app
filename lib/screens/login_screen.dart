import 'package:flutter/material.dart';
import 'package:smart_passenger_alert/theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.95),
            radius: 1.5,
            colors: [
              Color(0xFF0D2554),
              Color(0xFF06183B),
              Color(0xFF020D27),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF172B55),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 24,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, size: 58, color: Color(0xFF7CA9FF)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Midnight Concierge',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF79A6FF),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ELEVATED TRAVEL INTELLIGENCE',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF919DB8),
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 34),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2047).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: const Color(0xFFD0DAF4),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please enter your credentials to access\nyour terminal.',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF95A1BA),
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 34),
                      Text(
                        'EMAIL ADDRESS',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF8797B8),
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, color: Color(0xFF8E9CB8), size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: const Color(0xFF98A7C5),
                                  ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: 'name@agency.com',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.textTertiary.withOpacity(0.35), height: 30),
                      Row(
                        children: [
                          Text(
                            'SECURITY KEY',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: const Color(0xFF8797B8),
                                  letterSpacing: 2,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            'RECOVER',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: const Color(0xFF7CA9FF),
                                  letterSpacing: 1.8,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.lock_outline, color: Color(0xFF8E9CB8), size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: const Color(0xFF98A7C5),
                                  ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: '........',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF8E9CB8),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.textTertiary.withOpacity(0.35), height: 30),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF79A6FF),
                            foregroundColor: const Color(0xFF041537),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF041537),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFF394D72))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'AUTHORIZED ACCESS',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF7080A0),
                                    letterSpacing: 2,
                                  ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFF394D72))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _socialButton('Google', Icons.android)),
                          const SizedBox(width: 14),
                          Expanded(child: _socialButton('Apple', Icons.apple)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'New to the fleet? ',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: const Color(0xFF8997B4),
                                    ),
                              ),
                              TextSpan(
                                text: 'Create an Account',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: const Color(0xFF5EF498),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF65F59D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'SYSTEM OPTIMAL',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF7D8BAB),
                            letterSpacing: 3,
                          ),
                    ),
                    const Spacer(),
                    const Icon(Icons.security, color: Color(0xFF7D8BAB), size: 18),
                    const SizedBox(width: 10),
                    const Icon(Icons.public, color: Color(0xFF7D8BAB), size: 18),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        foregroundColor: const Color(0xFFC3D0EC),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(44),
        ),
      ),
    );
  }
}
