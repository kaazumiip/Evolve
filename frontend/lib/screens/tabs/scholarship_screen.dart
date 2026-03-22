import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import 'scholarship_detail_screen.dart';

class ScholarshipExplorerScreen extends StatefulWidget {
  const ScholarshipExplorerScreen({super.key});

  @override
  State<ScholarshipExplorerScreen> createState() => _ScholarshipExplorerScreenState();
}

class _ScholarshipExplorerScreenState extends State<ScholarshipExplorerScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _scholarships = [];
  String _filter = 'All';

  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Set<int> _favoritedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchScholarships(force: false);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _apiService.getFavorites();
    if (mounted) {
      setState(() {
        _favoritedIds = favorites
            .where((f) => f['itemType'] == 'scholarship')
            .map((f) => int.tryParse(f['itemId'].toString()) ?? 0)
            .toSet();
      });
    }
  }

  Future<void> _fetchScholarships({bool force = false}) async {
    if (force) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _scholarships = [];
        _hasMore = true;
      });
    } else if (_currentPage == 1) {
      setState(() => _isLoading = true);
    }

    final data = await _apiService.getScoutedScholarships(page: _currentPage, limit: _limit, force: force);
    if (mounted) {
      setState(() {
        if (force || _currentPage == 1) {
          _scholarships = data;
        } else {
          _scholarships.addAll(data);
        }
        // As long as the backend returns *something*, we allow the user to 
        // fetch the next page. If the next page is out of cache bounds, the 
        // backend natively triggers an AI auto-scout!
        _hasMore = data.isNotEmpty;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    await _fetchScholarships(force: false);
  }

  List<dynamic> get _filteredScholarships {
    if (_filter == 'All') return _scholarships;
    return _scholarships.where((s) => s['type'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scholarshipExplorer, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _currentPage = 1;
              _fetchScholarships(force: false);
            },
            tooltip: AppLocalizations.of(context)!.refreshCache,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredScholarships.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredScholarships.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredScholarships.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: _isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton.icon(
                                        onPressed: _loadMore,
                                        icon: const Icon(Icons.expand_more),
                                        label: Text(AppLocalizations.of(context)!.viewMoreScholarships),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                          foregroundColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF1565C0),
                                          side: BorderSide(color: isDark ? const Color(0xFF818CF8) : const Color(0xFF1565C0)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                      ),
                              ),
                            );
                          }
                          final s = _filteredScholarships[index];
                          return _buildScholarshipCard(s);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          {'key': 'All', 'label': AppLocalizations.of(context)!.all},
          {'key': 'National', 'label': AppLocalizations.of(context)!.national},
          {'key': 'International', 'label': AppLocalizations.of(context)!.international},
        ].map((f) {
          final isSelected = _filter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(f['label'] as String),
              selected: isSelected,
              onSelected: (val) => setState(() => _filter = f['key'] as String),
              selectedColor: const Color(0xFF1565C0).withOpacity(0.2),
              checkmarkColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF1565C0),
              labelStyle: TextStyle(
                color: isSelected ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF1565C0)) : (isDark ? Colors.white54 : Colors.black54),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScholarshipCard(Map<String, dynamic> s) {
    final Color cardColor = _parseColor(s['color'] ?? '#1565C0');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : cardColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : cardColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          s['type']?.toString().toUpperCase() == 'NATIONAL' ? AppLocalizations.of(context)!.national.toUpperCase() : (s['type']?.toString().toUpperCase() == 'INTERNATIONAL' ? AppLocalizations.of(context)!.international.toUpperCase() : AppLocalizations.of(context)!.all.toUpperCase()),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getTranslated(s, 'title'),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: s['logo_url'] != null && s['logo_url'].toString().isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            s['logo_url'].toString(),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.school, color: cardColor, size: 24),
                          ),
                        )
                      : Icon(Icons.school, color: cardColor, size: 24),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _favoritedIds.contains(s['id']) ? Icons.favorite : Icons.favorite_border,
                    color: _favoritedIds.contains(s['id']) ? Colors.redAccent : Colors.white,
                  ),
                  onPressed: () => _toggleFavorite(s),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.business_outlined, AppLocalizations.of(context)!.provider, _getTranslated(s, 'provider'), isDark),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.monetization_on_outlined, AppLocalizations.of(context)!.benefit, _getTranslated(s, 'amount'), isDark),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.groups_outlined, AppLocalizations.of(context)!.eligibility, _getTranslated(s, 'eligibility'), isDark),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today_outlined, AppLocalizations.of(context)!.deadline, _getTranslated(s, 'deadline'), isDark),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showScholarshipDetails(s),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.of(context)!.applyDetails, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.scoutingScholarships, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.noScholarshipsFound1, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(AppLocalizations.of(context)!.tryRefreshingOrChangingFilters, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showScholarshipDetails(Map<String, dynamic> s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScholarshipDetailScreen(scholarship: s)),
    );
  }

  Future<void> _toggleFavorite(Map<String, dynamic> s) async {
    final id = int.tryParse(s['id'].toString()) ?? 0;
    if (id == 0) return;

    final result = await _apiService.toggleFavorite('scholarship', id);
    final isFavorited = result['isFavorited'] ?? false;

    if (mounted) {
      setState(() {
        if (isFavorited) {
          _favoritedIds.add(id);
        } else {
          _favoritedIds.remove(id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? AppLocalizations.of(context)!.addedToFavorites : AppLocalizations.of(context)!.removedFromFavorites,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isFavorited ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getTranslated(Map<String, dynamic> s, String field) {
    if (AppLocalizations.of(context)!.localeName == 'km') {
       final kmVal = s['${field}_km'];
       if (kmVal != null && kmVal.toString().isNotEmpty) return kmVal.toString();
    }
    return s[field]?.toString() ?? 'N/A';
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
      }
      return const Color(0xFF1565C0);
    } catch (e) {
      return const Color(0xFF1565C0);
    }
  }
}
