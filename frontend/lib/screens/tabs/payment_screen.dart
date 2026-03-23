import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_success_screen.dart';
import 'checkout_page.dart';

class PaymentScreen extends StatefulWidget {
  final String title;
  final String cost;
  final List<String> benefits;

  const PaymentScreen({
    super.key,
    required this.title,
    required this.cost,
    required this.benefits,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethodIndex = 0; // 0 for KHQR, 1 for Credit Card

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final accentColor = const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: GoogleFonts.outfit(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          if (!isDark)
            Container(
              width: 40,
              alignment: Alignment.topRight,
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
            )
        ],
      ),
      body: Stack(
        children: [
          if (!isDark)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Process the payment by',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: subColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Plan Summary Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withOpacity(0.5), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? accentColor.withOpacity(0.1) : const Color(0xFFDBEAFE),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: widget.cost.split('/').first.replaceAll('Cost: ', ''),
                                            style: GoogleFonts.outfit(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                                            ),
                                          ),
                                          TextSpan(
                                            text: widget.cost.contains('/') 
                                                ? ' / ${widget.cost.split('/')[1]}' 
                                                : '',
                                            style: GoogleFonts.outfit(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.benefits.map((benefit) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Icon(Icons.check_circle_rounded, size: 14, color: accentColor),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              benefit,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Payment Method Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              _buildPaymentTab('Scan KHQR', 0, isDark),
                              _buildPaymentTab('Credit Card', 1, isDark),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Payment Details
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _selectedMethodIndex == 0 
                              ? _buildKHQRSection(isDark) 
                              : _buildCreditCardSection(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Submit Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              planName: widget.title,
                              planCost: widget.cost,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Payment submitted',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  Widget _buildPaymentTab(String text, int index, bool isDark) {
    final isSelected = _selectedMethodIndex == index;
    final accentColor = const Color(0xFF3B82F6);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMethodIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: isSelected ? accentColor : (isDark ? Colors.white38 : const Color(0xFF64748B)),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKHQRSection(bool isDark) {
    return Column(
      key: const ValueKey('khqr'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Scan KHQR',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Open your mobile banking app & enter amount manually',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/qr code.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'static KHQR - Enter amount in app',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardSection(bool isDark) {
    return Column(
      key: const ValueKey('credit_card'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit / Debit Card',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fill in your card details safely below.',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),
        
        _buildTextField('Card Number', '0000 0000 0000 0000', Icons.credit_card, isDark),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Expiry Date', 'MM/YY', Icons.calendar_today_outlined, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('CVV', '123', Icons.security, isDark)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Cardholder Name', 'John Doe', Icons.person_outline, isDark),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF94A3B8), size: 20),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: isDark ? const BorderSide(color: Colors.white12) : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
