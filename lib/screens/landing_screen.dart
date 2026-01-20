import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Void Background with Radial Gradient
          Container(
            decoration: const BoxDecoration(
              color: AppColors.voidBg,
              gradient: RadialGradient(
                center: Alignment(0, -1),
                radius: 1.5,
                colors: [
                  AppColors.electricDim,
                  AppColors.voidBg,
                ],
                stops: [0.0, 0.5],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Custom Navigation Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: AppColors.electric,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(LucideIcons.feather, size: 18, color: AppColors.voidBg),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'WHISPERRNOTE',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'LOGIN',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                ),

                // Hero Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Your notes,\n',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 48,
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: 'Secured',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 48,
                                  color: AppColors.electric,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 800.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                        const SizedBox(height: 32),
                        Text(
                          'Transform your ideas with professional note taking and secure your notes. Capture comprehensive content instantly.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.gunmetal,
                          ),
                        ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('GET STARTED FREE'),
                        ).animate().fadeIn(duration: 800.ms, delay: 600.ms).shimmer(delay: 2.seconds),
                      ],
                    ),
                  ),
                ),

                // Features Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildFeatureCard(
                        context,
                        icon: LucideIcons.shieldCheck,
                        title: 'Secure Note Taking',
                        description: 'Capture your ideas with professional-grade note taking tools and comprehensive organizing features.',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        icon: LucideIcons.cloud,
                        title: 'Secure Synchronization',
                        description: 'Securely store and share your notes with professional-grade encryption and private access control.',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        icon: LucideIcons.tag,
                        title: 'Smart Organization',
                        description: 'Organize your thoughts with tags, search, and secure cloud management.',
                      ),
                    ]),
                  ),
                ),
                
                // Footer
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        '© 2025 WHISPERRNOTE. ALL RIGHTS RESERVED.',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 10,
                          color: AppColors.gunmetal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.electricDim,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.electric.withOpacity(0.2)),
            ),
            child: Icon(icon, color: AppColors.electric, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }
}
