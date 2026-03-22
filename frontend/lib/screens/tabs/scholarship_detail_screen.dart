import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';


class ScholarshipDetailScreen extends StatefulWidget {
  final Map<String, dynamic> scholarship;

  const ScholarshipDetailScreen({super.key, required this.scholarship});

  @override
  State<ScholarshipDetailScreen> createState() => _ScholarshipDetailScreenState();
}

class _ScholarshipDetailScreenState extends State<ScholarshipDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isFavorited = false;
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _logView();
  }

  Future<void> _logView() async {
    final title = widget.scholarship['title']?.toString() ?? 'Scholarship';
    await _apiService.logScholarshipView(widget.scholarship['id'], title);
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await _apiService.checkFavorite('scholarship', widget.scholarship['id']);
    if (mounted) {
      setState(() {
        _isFavorited = status;
        _isLoadingFav = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorited = !_isFavorited); // Optimistic UI update
    final result = await _apiService.toggleFavorite('scholarship', widget.scholarship['id']);
    if (mounted) {
      setState(() {
        _isFavorited = result['isFavorited'] ?? false;
      });
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null) return const Color(0xFF1565C0);
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
      }
      return const Color(0xFF1565C0);
    } catch (e) {
      return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scholarship = widget.scholarship;
    final primaryColor = _parseColor(scholarship['color']?.toString());
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.grey.shade600;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          if (!_isLoadingFav)
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.star : Icons.star_border,
                color: _isFavorited ? Colors.amber : Colors.grey.shade400,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _getTranslated('title'),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            
            // Provider
            Row(
              children: [
                if (scholarship['logo_url'] != null && scholarship['logo_url'].toString().isNotEmpty)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(scholarship['logo_url'].toString()),
                    onBackgroundImageError: (_, __) {},
                    child: Icon(Icons.school, size: 14, color: primaryColor), // Fallback visually behind if error fails
                  )
                else
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: primaryColor.withOpacity(0.2),
                    child: Icon(Icons.school, size: 14, color: primaryColor),
                  ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.by,
                  style: TextStyle(color: subTextColor, fontSize: 13),
                ),
                Expanded(
                  child: Text(
                    _getTranslated('provider'),
                    style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Blue Highlight Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getTranslated('description'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Grid of 4 info boxes
            Row(
              children: [
                Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.awardAmount, _getTranslated('amount'), primaryColor, cardColor, subTextColor, textColor, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.deadline, _getTranslated('deadline'), primaryColor, cardColor, subTextColor, textColor, isDark)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (scholarship['applicantsCount'] != null && 
                    scholarship['applicantsCount'].toString().toLowerCase() != 'n/a' && 
                    scholarship['applicantsCount'].toString().isNotEmpty)
                  Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.applicants, _getTranslated('applicantsCount'), textColor, cardColor, subTextColor, textColor, isDark))
                else
                  Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.scholarshipType, _getTranslated('type'), textColor, cardColor, subTextColor, textColor, isDark)),
                  
                const SizedBox(width: 12),
                
                if (scholarship['pacing'] != null && 
                    scholarship['pacing'].toString().toLowerCase() != 'n/a' && 
                    scholarship['pacing'].toString().isNotEmpty)
                  Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.pacing, _getTranslated('pacing'), textColor, cardColor, subTextColor, textColor, isDark))
                else
                  Expanded(child: _buildInfoCard(AppLocalizations.of(context)!.eligibility, _getTranslated('eligibility'), textColor, cardColor, subTextColor, textColor, isDark)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Apply Now Button
            if (scholarship['website'] != null && scholarship['website'].toString().isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final urlString = scholarship['website'].toString();
                    final Uri url = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open the website link: ${url.toString()}')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.applyNow,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            // Application Requirement
            if (scholarship['requirements'] != null) ...[
               Text(AppLocalizations.of(context)!.applicationRequirement,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              ...((scholarship['requirements'] as List).map((req) {
                return _buildRequirementRow(
                  title: req['name']?.toString() ?? '',
                  desc: req['desc']?.toString() ?? '',
                  isWarning: req['icon'] == 'warning' || (req['desc']?.toString().toLowerCase().contains('required') == false),
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark
                );
              })).toList(),
              const SizedBox(height: 32),
            ] else ...[
                Text(AppLocalizations.of(context)!.applicationRequirement,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              _buildRequirementRow(title: 'Academic Transcript', desc: 'Required', cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, isDark: isDark),
              _buildRequirementRow(title: 'Personal Essay', desc: 'Explain why you are the best fit for this scholarship', cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, isDark: isDark),
              const SizedBox(height: 32),
            ],

            // Application Process
            if (scholarship['processes'] != null) ...[
               Text(AppLocalizations.of(context)!.applicationProcess,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              ...((scholarship['processes'] as List).asMap().entries.map((entry) {
                int idx = entry.key;
                var step = entry.value;
                int total = (scholarship['processes'] as List).length;
                return _buildProcessStep(
                  stepNum: (idx + 1).toString(),
                  title: step['title']?.toString() ?? '',
                  desc: step['desc']?.toString() ?? '',
                  isLast: idx == total - 1,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark
                );
              })).toList(),
              
              // Process Info Box
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: isDark ? Colors.blue.shade300 : Colors.blue, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.youAreOnStep('1', (scholarship['processes'] as List).length.toString()),
                        style: TextStyle(color: isDark ? Colors.blue.shade200 : Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Quick Facts
             if (scholarship['quickFacts'] != null) ...[
                Text(AppLocalizations.of(context)!.quickFacts,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              ...(scholarship['quickFacts'] as Map<String, dynamic>).entries.map((entry) {
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 12.0),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         _capitalize(entry.key),
                         style: TextStyle(color: subTextColor, fontSize: 13),
                       ),
                       Text(
                         entry.value.toString(),
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                       ),
                     ],
                   ),
                 );
              }).toList(),
              const SizedBox(height: 32),
             ],

            // About Provider
            Row(
              children: [
                Icon(Icons.public, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.about(_getTranslated('provider')),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getTranslated('aboutProvider'),
              style: TextStyle(color: subTextColor, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            
             if (scholarship['providerDetails'] != null) ...[
               ...(scholarship['providerDetails'] as Map<String, dynamic>).entries.map((entry) {
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 12.0),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         _capitalize(entry.key),
                         style: TextStyle(color: subTextColor, fontSize: 13),
                       ),
                       Text(
                         entry.value.toString(),
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                       ),
                     ],
                   ),
                 );
              }).toList(),
             ],
            const SizedBox(height: 32),

            // Requirements Checklist
             if (scholarship['checklist'] != null) ...[
               Text(AppLocalizations.of(context)!.requirementsChecklist,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
               ...((scholarship['checklist'] as List).map((req) {
                 return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          req.toString(),
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                      ],
                    ),
                  );
               })).toList(),
               const SizedBox(height: 32),
             ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color valueColor, Color cardColor, Color subTextColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: subTextColor, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow({required String title, required String desc, bool isWarning = false, required Color cardColor, required Color textColor, required Color subTextColor, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
             radius: 16,
             backgroundColor: isWarning ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
             child: Icon(
               isWarning ? Icons.priority_high : Icons.check, 
               color: isWarning ? Colors.orange : Colors.green, 
               size: 18
             ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({required String stepNum, required String title, required String desc, required bool isLast, required Color textColor, required Color subTextColor, required bool isDark}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : Colors.blue.shade100,
                  child: Text(
                    stepNum,
                    style: TextStyle(color: isDark ? Colors.blue.shade200 : Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslated(String field) {
    if (AppLocalizations.of(context)!.localeName == 'km') {
       final kmVal = widget.scholarship['${field}_km'];
       if (kmVal != null && kmVal.toString().isNotEmpty) return kmVal.toString();
    }
    return widget.scholarship[field]?.toString() ?? 'N/A';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    final RegExp exp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    String split = s.replaceAll(exp, ' ');
    return split[0].toUpperCase() + split.substring(1);
  }
}
