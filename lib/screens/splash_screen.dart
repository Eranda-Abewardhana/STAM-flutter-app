import 'package:flutter/material.dart';
import 'package:smart_passenger_alert/theme/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.1,
            colors: [
              Color(0xFF142A57),
              Color(0xFF071938),
              Color(0xFF03102A),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              IgnorePointer(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 220,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 11,
                  ),
                  itemBuilder: (_, __) => Center(
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.17),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        color: const Color(0xFF172A53).withOpacity(0.75),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.primary.withOpacity(0.16)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 45,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.flight_land_rounded,
                            color: Color(0xFF79A6FF),
                            size: 84,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 98,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF79A6FF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Midnight',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFCBD8F7),
                            fontSize: 58,
                            height: 0.95,
                          ),
                    ),
                    Text(
                      'Concierge',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF79A6FF),
                            fontSize: 58,
                            height: 0.95,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Smart Travel Starts Here',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF92A0BF),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: 120,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0),
                            AppColors.primary.withOpacity(0.6),
                            AppColors.primary.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF79A6FF),
                          foregroundColor: const Color(0xFF031338),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 24),
                        ),
                        child: Text(
                          'Begin Journey  ->',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF031338),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary.withOpacity(0.18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 24),
                        ),
                        child: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF8694B3),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'AUTONOMOUS\nINTELLIGENCE  *  GLOBAL\nNETWORK',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF4A5C83),
                            letterSpacing: 4,
                            height: 1.9,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ],
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
