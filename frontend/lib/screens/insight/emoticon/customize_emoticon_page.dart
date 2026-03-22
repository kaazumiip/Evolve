import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/emoticon_model.dart';
import '../../../state/emoticon_provider.dart';
import '../../../generated/l10n/app_localizations.dart';

class CustomizeEmoticonPage extends StatefulWidget {
  const CustomizeEmoticonPage({super.key});

  @override
  State<CustomizeEmoticonPage> createState() => _CustomizeEmoticonPageState();
}

class _CustomizeEmoticonPageState extends State<CustomizeEmoticonPage> {
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color bgColor = Color(0xFFF8F9FF);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF8892A4);
  static const Color chipSelected = primaryBlue;
  static const Color chipUnselected = Color(0xFFEEF2FF);

  // Component options
  final List<String> _leftArms = ['(', 'づ', 'つ', '⊂', 'ヽ', '(っ', '╰(', '٩(', 'ノ('];
  final List<String> _eyes = ['•', '^', '>', '@', '◕', '✧', '˘', '-', 'T', ';', '≧', '⌒'];
  final List<String> _mouths = ['ω', '▽', '‿', 'ε', '3', 'ᴗ', 'o', 'ᵕ', '∀', '□', 'ロ', '~'];
  final List<String> _rightArms = [')', 'づ', 'つ', '⊃', 'ﾉ', ')っ', ')╯', ')۶', ')ﾉ'];
  final List<String> _extras = ['', '♡', '☆', '✧', '~', '♪', '❤', '*', '✿', 'zzZ'];

  String _selectedLeft = '(';
  String _selectedEyes = '•';
  String _selectedMouth = 'ω';
  String _selectedRight = ')';
  String _selectedExtra = '';
  String _selectedCategory = 'Happy';

  String get _preview => '$_selectedLeft$_selectedEyes$_selectedMouth$_selectedEyes$_selectedRight$_selectedExtra';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewCard(),
                    const SizedBox(height: 24),
                    _buildComponentPicker(AppLocalizations.of(context)!.leftArm, _leftArms, _selectedLeft,
                            (val) => setState(() => _selectedLeft = val)),
                    const SizedBox(height: 16),
                    _buildComponentPicker(AppLocalizations.of(context)!.eyes, _eyes, _selectedEyes,
                            (val) => setState(() => _selectedEyes = val)),
                    const SizedBox(height: 16),
                    _buildComponentPicker(AppLocalizations.of(context)!.mouth, _mouths, _selectedMouth,
                            (val) => setState(() => _selectedMouth = val)),
                    const SizedBox(height: 16),
                    _buildComponentPicker(AppLocalizations.of(context)!.rightArm, _rightArms, _selectedRight,
                            (val) => setState(() => _selectedRight = val)),
                    const SizedBox(height: 16),
                    _buildComponentPicker(AppLocalizations.of(context)!.extras, _extras, _selectedExtra,
                            (val) => setState(() => _selectedExtra = val)),
                    const SizedBox(height: 16),
                    _buildCategoryPicker(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: textDark, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.createEmoticon,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.preview,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _preview,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _translateCategory(context, _selectedCategory),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentPicker(
      String label,
      List<String> options,
      String selected,
      ValueChanged<String> onSelect,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final opt = options[i];
              final isSelected = opt == selected;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? chipSelected : chipUnselected,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? primaryBlue
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    opt.isEmpty ? AppLocalizations.of(context)!.none : opt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : primaryBlue,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    const categories = [
      'Happy', 'Love', 'Sad', 'Angry', 'Excited',
      'Hugging', 'Sleepy', 'Custom',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.category,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = cat == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? chipSelected : chipUnselected,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _translateCategory(context, cat),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : primaryBlue,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _saveEmoticon,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.saveEmoticon,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveEmoticon() {
    final emoticon = EmoticonModel(
      face: _preview,
      category: _selectedCategory,
      isCustom: true,
      createdAt: DateTime.now(),
    );
    context.read<EmoticonProvider>().saveCustomEmoticon(emoticon);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoticon.face, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
             Text(AppLocalizations.of(context)!.customEmoticonSaved),
          ],
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  String _translateCategory(BuildContext context, String cat) {
    switch (cat) {
      case 'All': return AppLocalizations.of(context)!.catAll;
      case 'Happy': return AppLocalizations.of(context)!.catHappy;
      case 'Love': return AppLocalizations.of(context)!.catLove;
      case 'Sad': return AppLocalizations.of(context)!.catSad;
      case 'Angry': return AppLocalizations.of(context)!.catAngry;
      case 'Sleepy': return AppLocalizations.of(context)!.catSleepy;
      case 'Hugging': return AppLocalizations.of(context)!.catHugging;
      case 'Excited': return AppLocalizations.of(context)!.catExcited;
      case 'Embarrassed': return AppLocalizations.of(context)!.catEmbarrassed;
      case 'Surprised': return AppLocalizations.of(context)!.catSurprised;
      case 'Confused': return AppLocalizations.of(context)!.catConfused;
      case 'Greeting': return AppLocalizations.of(context)!.catGreeting;
      case 'Winking': return AppLocalizations.of(context)!.catWinking;
      default: return cat;
    }
  }
}
