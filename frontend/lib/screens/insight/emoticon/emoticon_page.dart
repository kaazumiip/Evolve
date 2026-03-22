import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/emoticon_model.dart';
import '../../../state/emoticon_provider.dart';
import 'customize_emoticon_page.dart';
import '../../../generated/l10n/app_localizations.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class EmoticonPage extends StatefulWidget {
  const EmoticonPage({super.key});

  @override
  State<EmoticonPage> createState() => _EmoticonPageState();
}

class _EmoticonPageState extends State<EmoticonPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ─── Managed Colors (handled in build via isDark) ──────────────────────────
  static const Color primaryBlueStatic = Color(0xFF3B82F6);
  static const Color lightGray = Color(0xFFD9D9D9);
  static const Color textMutedStatic = Color(0xFF8892A4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmoticonProvider>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyEmoticon(EmoticonModel emoticon) async {
    await Clipboard.setData(ClipboardData(text: emoticon.face));
    await context.read<EmoticonProvider>().copyEmoticon(emoticon);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(emoticon.face, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.copiedToClipboard),
            ],
          ),
          backgroundColor: kPrimaryBlue(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF8F9FF);
    final primaryBlue = kPrimaryBlue(context);
    final textDark = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(isDark, textDark, cardBg),
                _buildSearchBar(isDark, cardBg),
                _buildCategoryChips(isDark, primaryBlue),
                _buildTrendingSection(isDark, textDark, primaryBlue),
                _buildCustomSection(isDark, textDark, primaryBlue),
                _buildRecentsSection(isDark, textDark, primaryBlue, cardBg),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            _buildCustomizeButton(primaryBlue),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar(bool isDark, Color textDark, Color cardBg) {
    return SliverToBoxAdapter(
      child: Padding(
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
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.chevron_left_rounded,
                    color: textDark, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.emoticon,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textDark,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark, Color cardBg) {
    final textMuted = isDark ? Colors.white38 : const Color(0xFF8892A4);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) =>
                context.read<EmoticonProvider>().updateSearch(val),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.findYourVibe,
              hintStyle: TextStyle(color: textMuted, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded,
                  color: textMuted, size: 20),
              suffixIcon: Consumer<EmoticonProvider>(
                builder: (_, provider, __) => provider.searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    provider.updateSearch('');
                  },
                  child: Icon(Icons.close_rounded,
                      color: textMuted, size: 18),
                )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Category Chips ──────────────────────────────────────────────────────────
  Widget _buildCategoryChips(bool isDark, Color primaryBlue) {
    final chipUnselected = isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEEF2FF);
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 52,
        child: Consumer<EmoticonProvider>(
          builder: (_, provider, __) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            scrollDirection: Axis.horizontal,
            itemCount: EmoticonProvider.filterCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = EmoticonProvider.filterCategories[i];
              final selected = provider.selectedCategory == cat;
              return GestureDetector(
                onTap: () => provider.selectCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? primaryBlue : chipUnselected,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _translateCategory(context, cat),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : (isDark ? Colors.white70 : primaryBlue),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Trending Section ────────────────────────────────────────────────────────
  Widget _buildTrendingSection(bool isDark, Color textDark, Color primaryBlue) {
    return Consumer<EmoticonProvider>(
      builder: (_, provider, __) {
        final items = provider.searchQuery.isNotEmpty || provider.selectedCategory != 'All'
            ? provider.filteredEmoticons
            : provider.trendingEmoticons;
        final title = provider.searchQuery.isNotEmpty
            ? AppLocalizations.of(context)!.searchResults
            : provider.selectedCategory != 'All'
            ? _translateCategory(context, provider.selectedCategory)
            : AppLocalizations.of(context)!.trendingKawaii;

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    if (provider.searchQuery.isEmpty &&
                        provider.selectedCategory == 'All' &&
                        !provider.showAll)
                      GestureDetector(
                        onTap: () => provider.toggleShowAll(),
                        child: Text(
                          AppLocalizations.of(context)!.seeAll,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: items.isEmpty
                    ? _buildEmptyState(isDark)
                    : GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: items.length > 6 && provider.selectedCategory == 'All' && provider.searchQuery.isEmpty && !provider.showAll
                            ? 6
                            : items.length,
                        itemBuilder: (_, i) => _EmoticonCard(emoticon: items[i], onCopy: _copyEmoticon),
                      ),
              ),

            ],
          ),
        );
      },
    );
  }

  // ─── Custom Section ──────────────────────────────────────────────────────────
  Widget _buildCustomSection(bool isDark, Color textDark, Color primaryBlue) {
    return Consumer<EmoticonProvider>(
      builder: (_, provider, __) {
        if (provider.customEmoticons.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: primaryBlue, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.myCustom,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: provider.customEmoticons.length,
                  itemBuilder: (_, i) => _EmoticonCard(
                    emoticon: provider.customEmoticons[i],
                    onCopy: _copyEmoticon,
                    isCustom: true,
                    onDelete: () =>
                        provider.deleteCustomEmoticon(provider.customEmoticons[i].face),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Recents Section ─────────────────────────────────────────────────────────
  Widget _buildRecentsSection(bool isDark, Color textDark, Color primaryBlue, Color cardBg) {
    final textMuted = isDark ? Colors.white38 : const Color(0xFF8892A4);
    return Consumer<EmoticonProvider>(
      builder: (_, provider, __) {
        if (provider.recents.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                    Text(
                      AppLocalizations.of(context)!.recents,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text(AppLocalizations.of(context)!.clearRecents),
                          content: Text(AppLocalizations.of(context)!.removeAllRecentEmoticons),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.clearRecents();
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.clear,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.clear,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              ...provider.recents.take(3).map(
                    (r) => _RecentItem(recent: r, onCopy: _copyEmoticon, isDark: isDark, textDark: textDark, cardBg: cardBg),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Customize FAB ──────────────────────────────────────────────────────────
  Widget _buildCustomizeButton(Color primaryBlue) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<EmoticonProvider>(),
                child: const CustomizeEmoticonPage(),
              ),
            ),
          ),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                 Text(
                  AppLocalizations.of(context)!.customize,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textMuted = isDark ? Colors.white38 : const Color(0xFF8892A4);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
             const Text('(¯ . ¯;)', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.noEmoticonsFound,
                style: TextStyle(color: textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ─── Emoticon Card Widget ─────────────────────────────────────────────────────
class _EmoticonCard extends StatelessWidget {
  final EmoticonModel emoticon;
  final Future<void> Function(EmoticonModel) onCopy;
  final bool isCustom;
  final VoidCallback? onDelete;

  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF8892A4);

  const _EmoticonCard({
    required this.emoticon,
    required this.onCopy,
    this.isCustom = false,
    this.onDelete,
  });

  Color get _cardAccent {
    const colors = {
      'Happy': Color(0xFFFFF7ED),
      'Love': Color(0xFFFFF0F6),
      'Sad': Color(0xFFEFF6FF),
      'Angry': Color(0xFFFFF1F2),
      'Sleepy': Color(0xFFF5F3FF),
      'Hugging': Color(0xFFF0FDF4),
      'Excited': Color(0xFFFFFBEB),
      'Embarrassed': Color(0xFFFDF4FF),
      'Surprised': Color(0xFFEFF6FF),
      'Confused': Color(0xFFF0FDFA),
      'Greeting': Color(0xFFF0FDF4),
      'Winking': Color(0xFFFFFBEB),
    };
    return colors[emoticon.category] ?? const Color(0xFFF8F9FF);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = kPrimaryBlue(context);
    final textMuted = isDark ? Colors.white38 : const Color(0xFF8892A4);

    return GestureDetector(
      onTap: () => onCopy(emoticon),
      onLongPress: isCustom
          ? () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
           shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(AppLocalizations.of(context)!.deleteCustomEmoticon),
          content: Text(
              AppLocalizations.of(context)!.removeFaceFromCustomList(emoticon.face)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                onDelete?.call();
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.delete,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      )
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : _cardAccent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isCustom
                ? primaryBlue.withOpacity(0.3)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoticon.face,
                  style: TextStyle(fontSize: 32, color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _translateCategory(context, emoticon.category),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (isCustom)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Item Widget ───────────────────────────────────────────────────────
class _RecentItem extends StatelessWidget {
  final RecentEmoticon recent;
  final Future<void> Function(EmoticonModel) onCopy;
  final bool isDark;
  final Color textDark;
  final Color cardBg;

  const _RecentItem({
    required this.recent, 
    required this.onCopy, 
    required this.isDark, 
    required this.textDark, 
    required this.cardBg
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = kPrimaryBlue(context);
    final textMuted = isDark ? Colors.white38 : const Color(0xFF8892A4);
    final chipUnselected = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEEF2FF);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: chipUnselected,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.history_rounded,
                color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recent.emoticon.face,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_translateCategory(context, recent.emoticon.category)} · ${recent.timeAgo}',
                  style: TextStyle(fontSize: 11, color: textMuted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onCopy(recent.emoticon),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: chipUnselected,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.copy_rounded,
                  color: primaryBlue, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

String _translateCategory(BuildContext context, String cat) {
  final l10n = AppLocalizations.of(context)!;
  switch (cat) {
    case 'All': return l10n.catAll;
    case 'Happy': return l10n.catHappy;
    case 'Love': return l10n.catLove;
    case 'Sad': return l10n.catSad;
    case 'Angry': return l10n.catAngry;
    case 'Sleepy': return l10n.catSleepy;
    case 'Hugging': return l10n.catHugging;
    case 'Excited': return l10n.catExcited;
    case 'Embarrassed': return l10n.catEmbarrassed;
    case 'Surprised': return l10n.catSurprised;
    case 'Confused': return l10n.catConfused;
    case 'Greeting': return l10n.catGreeting;
    case 'Winking': return l10n.catWinking;
    default: return cat;
  }
}
