import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_screen.dart';
import 'package:frontend/services/api_service.dart';
import '../../generated/l10n/app_localizations.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white : const Color(0xFF94A3B8); // Changed to white

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.pricingTitle,
          style: GoogleFonts.outfit(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.chooseBestPlan,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: subColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildPlanCard(
              context,
              title: AppLocalizations.of(context)!.freeAccess,
              cost: 'Cost: 0\$',
              color: const Color(0xFF2563EB),
              gradient: null,
              icon: Icons.explore_outlined,
              aiAccess: [
                '5 AI messages per day',
                'AI responses: 50-80 words',
                'Short, simple guidance only',
                'No deep analysis',
              ],
              otherAccess: [
                'Core self-discovery activities',
                'Basic career & major exploration',
                'Full app access',
              ],
              summaryText: AppLocalizations.of(context)!.freePlanSub,
            ),
            const SizedBox(height: 24),
            _buildPlanCard(
              context,
              title: AppLocalizations.of(context)!.premium,
              cost: '2.50\$/month',
              color: null,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
              ),
              icon: Icons.workspace_premium_outlined,
              isPopular: true,
              aiAccess: [
                '60 AI messages per month',
                'AI responses: 300-500 words',
                'Deep reflection & reasoning',
                'Personalized guidance',
              ],
              otherAccess: [
                'University major comparison',
                'Personalized action roadmap',
                'Priority system performance',
                'Continuous access',
              ],
              summaryText: AppLocalizations.of(context)!.premiumPlanSub,
            ),
            const SizedBox(height: 24),
            _buildFocusedDecisionPackCard(context),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String cost,
    Color? color,
    LinearGradient? gradient,
    IconData? icon,
    bool isPopular = false,
    required List<String> aiAccess,
    required List<String> otherAccess,
    required String summaryText,
  }) {
    List<Widget> children = [
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: isPopular ? 16 : 0),
        decoration: BoxDecoration(
          color: color,
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (color ?? Colors.purple).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cost,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureSection(AppLocalizations.of(context)!.aiAccessTitle, aiAccess),
            const SizedBox(height: 16),
            _buildFeatureSection(AppLocalizations.of(context)!.otherAccessTitle, otherAccess),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('➡ ', style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Text(
                    summaryText,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: ApiService.currentGlobalSubscription == title ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        title: title,
                        cost: cost,
                        benefits: [...aiAccess, ...otherAccess],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color ?? Colors.purple,
                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                  disabledForegroundColor: const Color(0xFF64748B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  ApiService.currentGlobalSubscription == title 
                      ? AppLocalizations.of(context)!.youSubscribed 
                      : AppLocalizations.of(context)!.pickPlan,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
    
    if (isPopular) {
      children.add(
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                AppLocalizations.of(context)!.mostPopular,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Stack(children: children);
  }

  Widget _buildFocusedDecisionPackCard(BuildContext context) {
    List<Widget> children = [
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0EA5E9), Color(0xFF10B981)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.track_changes_outlined, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Focused Decision Pack',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Cost: 5\$',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'One-Time Decision Pack\n\$5 (single use)',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletList([
              '7 days of focused access',
              '20 in-depth AI messages (total)',
              'Long, detailed responses (300-800 words)',
              'Clear major direction & summary',
              'No subscription required',
            ]),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.after7Days,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
             _buildBulletList([
              'Your results remain saved',
              'AI chat closes for this pack',
              'You return to Free Access',
              'You can upgrade to Premium anytime',
            ]),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('➡ ', style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.focusedPackSub,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: ApiService.currentGlobalSubscription == 'Focused Decision Pack' ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(
                        title: 'Focused Decision Pack',
                        cost: 'Cost: 5\$',
                        benefits: [
                          '7 days of focused access',
                          '20 in-depth AI messages',
                          'Clear major direction & summary',
                          'No subscription required',
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0EA5E9),
                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                  disabledForegroundColor: const Color(0xFF64748B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  ApiService.currentGlobalSubscription == 'Focused Decision Pack' 
                      ? 'You subscribe to this plan' 
                      : 'Pick the plan',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              AppLocalizations.of(context)!.oneTime,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    ];
    return Stack(children: children);
  }

  Widget _buildFeatureSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _buildBulletList(items),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
