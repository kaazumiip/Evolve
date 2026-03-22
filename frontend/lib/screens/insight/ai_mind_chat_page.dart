import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../utils/interest_helper.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class AIMindChatPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AIMindChatPage({super.key, required this.userData});

  @override
  State<AIMindChatPage> createState() => _AIMindChatPageState();
}

class _AIMindChatPageState extends State<AIMindChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  bool _isLoading = false;
  final String _openRouterApiKey = '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';
  final ScrollController _scrollController = ScrollController();
  String _currentPlan = 'Free Access';
  int _messageCount = 0;
  int _messageLimit = 5; // Default for Free
  String get _currentPlanLabel {
    if (_currentPlan == 'Free Access') return AppLocalizations.of(context)!.freeAccess;
    return _currentPlan;
  }
  
  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadUsageStats();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('ai_mind_chat_history');
    if (saved != null) {
      try {
        final List<dynamic> decoded = List<dynamic>.from(jsonDecode(saved));
        setState(() {
          _messages.clear();
          _messages.addAll(decoded.map((e) => Map<String, dynamic>.from(e)).toList());
        });
      } catch (e) {
        debugPrint('Error loading chat history: $e');
      }
    }
    
    if (_messages.isEmpty) {
      setState(() {
        _messages.add({
          'isAI': true,
          'text': AppLocalizations.of(context)!.aiGreeting,
        });
      });
    }
    _scrollToBottom();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_mind_chat_history', jsonEncode(_messages));
  }

  Future<void> _loadUsageStats() async {
    _currentPlan = ApiService.currentGlobalSubscription;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    String key = '';

    // Set limits and storage keys based on plan
    if (_currentPlan == 'Premium') {
      _messageLimit = 60; 
      key = 'ai_chat_usage_month_${now.year}_${now.month}';
    } else if (_currentPlan == 'Focused Decision Pack') {
      _messageLimit = 20;
      key = 'ai_chat_usage_focused'; // total for this pack
    } else {
      _messageLimit = 5; 
      key = 'ai_chat_usage_day_${now.toIso8601String().split('T')[0]}';
    }

    setState(() {
      _messageCount = prefs.getInt(key) ?? 0;
    });
  }

  Future<void> _incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    String key = '';

    if (_currentPlan == 'Premium') {
      key = 'ai_chat_usage_month_${now.year}_${now.month}';
    } else if (_currentPlan == 'Focused Decision Pack') {
      key = 'ai_chat_usage_focused';
    } else {
      key = 'ai_chat_usage_day_${now.toIso8601String().split('T')[0]}';
    }

    await prefs.setInt(key, _messageCount + 1);
    setState(() {
      _messageCount++;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'isAI': false,
        'text': text,
      });
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();
    _saveChatHistory();
    
    // Call OpenRouter API
    try {
      await _incrementUsage();
      final dio = Dio();
      
      // Personalized instructions based on interests
      final List<dynamic> interestsRaw = widget.userData['interests'] ?? [];
      final List<String> interestNames = [];
      for (var item in interestsRaw) {
        if (item is int) {
          interestNames.add(InterestHelper.getCategoryName(item));
        } else if (item is String) {
          interestNames.add(item);
        }
      }

      final String interestsPrompt = interestNames.isNotEmpty 
          ? "You know the user is interested in: ${interestNames.join(', ')}. Explicitly mention how your advice relates to these specific passions."
          : "The user has not selected specific interests yet. Encourage them to explore their passions in STEM, Arts, or Business to help you guide them better.";

      // Plan-based instructions
      String depthInstruction = "";
      int maxResponseTokens = 500;
      
      if (_currentPlan == 'Premium') {
        depthInstruction = "Provide in-depth reflection and reasoning. Integrate their interests (${interestNames.join('/')}) deeply into the conversation. Responses should be around 300 words.";
        maxResponseTokens = 700;
      } else if (_currentPlan == 'Focused Decision Pack') {
        depthInstruction = "Provide strategic, highly detailed guidance. Create a roadmap based on their interests (${interestNames.join('/')}). Most detailed responses (around 500 words).";
        maxResponseTokens = 1000;
      } else {
        depthInstruction = "Keep responses simple and concise. Briefly mention how their interest in ${interestNames.isNotEmpty ? interestNames.first : 'their future'} applies. Responses: 50-80 words.";
        maxResponseTokens = 200;
      }

      // Convert previous messages to OpenRouter format
      List<Map<String, dynamic>> chatHistory = [
        {
          "role": "system", 
          "content": "You are a helpful, empathetic, and insightful AI Mind Guide. Your goal is to guide students in self-discovery, mental wellness, and personal growth. $interestsPrompt $depthInstruction"
        }
      ];
      
      for (var msg in _messages) {
        chatHistory.add({
          "role": msg['isAI'] ? "assistant" : "user",
          "content": msg['text']
        });
      }

      final response = await dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_openRouterApiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "model": "google/gemini-2.0-flash-001",
          "messages": chatHistory,
          "max_tokens": maxResponseTokens,
        },
      );

      final reply = response.data['choices'][0]['message']['content'];
      
          if (mounted) {
            setState(() {
              _messages.add({
                'isAI': true,
                'text': reply,
              });
              _isLoading = false;
            });
            _saveChatHistory();
            _scrollToBottom();
          }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isAI': true,
            'text': AppLocalizations.of(context)!.aiError(e.toString().split('\n')[0]),
          });
          _isLoading = false;
        });
        _saveChatHistory();
        _scrollToBottom();
        print("AI Chat Error Details: $e");
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = kPrimaryBlue(context);
    final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF7F9FC);
    final themeActionColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: themeActionColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.aiMindChat, 
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            Text(AppLocalizations.of(context)!.poweredByGemini, 
              style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_rounded, color: isDark ? Colors.white60 : Colors.black54),
            onPressed: _confirmClearChat,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAI = msg['isAI'] as bool;

                return Align(
                  alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isAI 
                          ? (isDark ? const Color(0xFF1E293B) : Colors.white) 
                          : brandColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isAI ? 0 : 20),
                        bottomRight: Radius.circular(isAI ? 20 : 0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isAI 
                            ? (isDark ? Colors.white.withOpacity(0.9) : Colors.black87) 
                            : Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_messageCount >= _messageLimit && _currentPlan == 'Free Access')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      AppLocalizations.of(context)!.freeLimitReached,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          enabled: _messageCount < _messageLimit || _currentPlan != 'Free Access',
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.typeYourMessage,
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: (_isLoading || (_messageCount >= _messageLimit && _currentPlan == 'Free Access')) ? null : _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_isLoading || (_messageCount >= _messageLimit && _currentPlan == 'Free Access')) ? Colors.grey : brandColor,
                          shape: BoxShape.circle,
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearChat),
        content: Text(AppLocalizations.of(context)!.areYouSureYouWantToClearChat),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              _saveChatHistory();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.clear,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
