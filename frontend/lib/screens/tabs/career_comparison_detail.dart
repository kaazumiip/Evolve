import 'package:flutter/material.dart';

class CareerComparisonDetailScreen extends StatelessWidget {
  final Map<String, dynamic> comparisonData;

  const CareerComparisonDetailScreen({super.key, required this.comparisonData});

  @override
  Widget build(BuildContext context) {
    if (comparisonData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Career Breakdown')),
        body: const Center(child: Text('No data available')),
      );
    }

    final keys = comparisonData.keys.where((k) => k != 'summary_verdict').toList();
    if (keys.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Career Breakdown')),
        body: const Center(child: Text('Invalid comparison data')),
      );
    }

    final career1 = comparisonData[keys[0]];
    final career2 = comparisonData[keys[1]];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Career Paths & Roadmaps',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF1565C0),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1565C0),
            tabs: [
              Tab(text: career1['title'] ?? 'Career 1'),
              Tab(text: career2['title'] ?? 'Career 2'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCareerTab(career1),
            _buildCareerTab(career2),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Facts
          Row(
            children: [
              Expanded(child: _buildFactBox('Salary', data['salary_range'] ?? 'N/A', Icons.monetization_on_outlined, Colors.green)),
              const SizedBox(width: 15),
              Expanded(child: _buildFactBox('Demand', data['market_demand'] ?? 'N/A', Icons.trending_up, Colors.blue)),
            ],
          ),
          const SizedBox(height: 15),
          _buildFactBox('Work/Life Balance', data['work_life_balance'] ?? 'N/A', Icons.balance, Colors.orange),
          const SizedBox(height: 30),

          // Core Skills
          const Text('Core Technical Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (data['core_skills'] as List<dynamic>? ?? []).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Text(
                  skill.toString(),
                  style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          // Educational Roadmap
          const Text('Educational Roadmap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...((data['roadmap'] as List<dynamic>? ?? []).map((step) {
            return _buildRoadmapStep(
              step['step']?.toString() ?? '1', 
              step['title']?.toString() ?? 'Step', 
              step['description']?.toString() ?? ''
            );
          })).toList(),
        ],
      ),
    );
  }

  Widget _buildFactBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRoadmapStep(String stepNumber, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
