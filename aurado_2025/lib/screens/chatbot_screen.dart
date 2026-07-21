import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/ color_utils.dart';
import '../providers/preferences_provider.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      'sender': 'user',
      'text': 'Hi AuroBot, can you help me with my tasks?',
    },
    {
      'sender': 'bot',
      'text':
      'Of course! I’d love to help. Let’s start by listing your tasks. What would you like to do?',
    },
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _controller.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'bot', 'text': "I'm processing your request..."});
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('MMMM d, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    // ---- Responsive helpers ----
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTablet = width >= 600; // iPad / Android tablets
    final isSmallPhone = width < 360; // small older phones

    final horizontalPadding = width * 0.03; // ~3% of screen width
    final headerFontSize = isTablet ? 15.0 : (isSmallPhone ? 11.5 : 13.0);
    final greetingFontSize = isTablet ? 20.0 : (isSmallPhone ? 14.0 : 16.0);
    final bubbleFontSize = isTablet ? 16.0 : (isSmallPhone ? 13.0 : 14.0);
    final bubbleMaxWidth = isTablet ? width * 0.55 : width * 0.75;
    final maxContentWidth = isTablet ? 700.0 : double.infinity;

    return Scaffold(
      backgroundColor: fromHex(prefs.themeColor),
      // Keeps input field above the keyboard on both iOS & Android
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Scrollable area: header + greeting + messages ----
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFBEEE6),
                                  borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                child: Text(
                                  'Date: $day, $date | Time: $time PKT',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: headerFontSize,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 30 : 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '🌟 Hello, I’m AuroBot!\nYour peaceful little helper is here \nLet’s turn your tasks into calm, happy progress. 💖',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: greetingFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 20 : 12),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final msg = _messages[index];
                              final isUser = msg['sender'] == 'user';
                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(10),
                                  constraints:
                                  BoxConstraints(maxWidth: bubbleMaxWidth),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.lightBlue[200]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(isUser ? '👤 ' : '🤖 ',
                                          style: const TextStyle(fontSize: 16)),
                                      Flexible(
                                        child: Text(
                                          msg['text'] ?? '',
                                          style: TextStyle(
                                            fontSize: bubbleFontSize,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: _messages.length,
                          ),
                        ),
                        // little bottom breathing room so last bubble isn't glued to input bar
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      ],
                    ),
                  ),

                  // ---- Fixed input bar at the bottom ----
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey)),
                      color: Colors.white,
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              style: TextStyle(fontSize: bubbleFontSize),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                  const BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: _sendMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000),
                              padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 22 : 15,
                                  vertical: isTablet ? 14 : 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}