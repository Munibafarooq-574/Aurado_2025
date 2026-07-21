import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/ color_utils.dart';
import '../providers/preferences_provider.dart';
import 'package:aurado_2025/task_manager.dart';
import 'package:aurado_2025/controller/chat_controller.dart';
import '../models/task.dart';


// Free key: https://console.groq.com/keys
const String _kGroqApiKey = '';
const String _kGroqModel = 'llama-3.3-70b-versatile';

const List<String> _kValidCategories = [
  'Work',
  'Personal',
  'Shopping',
  'Health',
  'Habit'
];

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 🔁 Backed by the singleton so chat history survives leaving/returning
  // to this screen, and only resets when the app itself restarts.
  final List<Map<String, String>> _messages = ChatController().messages;

  bool _isBotTyping = false;

  // ---- Tool / function definitions sent to the AI ----
  static final List<Map<String, dynamic>> _tools = [
    {
      'type': 'function',
      'function': {
        'name': 'add_task',
        'description': 'Add a new task to the user\'s task list.',
        'parameters': {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
            'description': {
              'type': 'string',
              'description': 'Optional short description, empty string if none'
            },
            'category': {
              'type': 'string',
              'enum': ['Work', 'Personal', 'Shopping', 'Health', 'Habit'],
            },
            'priority': {
              'type': 'string',
              'enum': ['High', 'Medium', 'Low'],
            },
            'due_date': {
              'type': 'string',
              'description': 'YYYY-MM-DD (resolve "today"/"tomorrow" to real dates)'
            },
            'due_time': {
              'type': 'string',
              'description': '24-hour HH:MM, default 09:00 if user does not say'
            },
          },
          'required': ['title', 'category', 'due_date'],
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'complete_task',
        'description': 'Mark an existing task as completed, matched by title keyword.',
        'parameters': {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
          },
          'required': ['title'],
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'delete_task',
        'description': 'Delete an existing task, matched by title keyword.',
        'parameters': {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
          },
          'required': ['title'],
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'set_reminder',
        'description': 'Reschedule an existing task\'s due date/time, matched by title keyword.',
        'parameters': {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
            'due_date': {'type': 'string', 'description': 'YYYY-MM-DD'},
            'due_time': {'type': 'string', 'description': '24-hour HH:MM, default 09:00'},
          },
          'required': ['title', 'due_date'],
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'list_tasks',
        'description': 'List the user\'s tasks, optionally filtered by status and/or category.',
        'parameters': {
          'type': 'object',
          'properties': {
            'filter': {
              'type': 'string',
              'enum': ['today', 'upcoming', 'completed', 'missed', 'all'],
            },
            'category': {
              'type': 'string',
              'enum': ['Work', 'Personal', 'Shopping', 'Health', 'Habit', 'any'],
            },
          },
          'required': ['filter'],
        },
      },
    },
  ];

  List<Map<String, dynamic>> get _chatHistoryForApi => _messages
      .where((m) => m['text'] != '…typing')
      .map((m) => {
    'role': m['sender'] == 'user' ? 'user' : 'assistant',
    'content': m['text'] ?? '',
  })
      .toList();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isBotTyping) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _controller.clear();
      _isBotTyping = true;
      _messages.add({'sender': 'bot', 'text': '…typing'});
    });
    _scrollToBottom();

    try {
      final taskManager = Provider.of<TaskManager>(context, listen: false);
      final reply = await _getGroqReply(taskManager, text);
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add({'sender': 'bot', 'text': reply});
      });
    } catch (e) {
      print('❌ CHATBOT ERROR: $e');
      if (!mounted) return;
      final isEnglish = _isEnglishMessage(text);
      setState(() {
        _messages.removeLast();
        _messages.add({
          'sender': 'bot',
          'text': isEnglish
              ? 'Sorry, something went wrong. Please check your internet and try again.'
              : 'Sorry, kuch masla ho gaya. Internet check karein ya dobara koshish karein.'
        });
      });
    } finally {
      if (mounted) setState(() => _isBotTyping = false);
      _scrollToBottom();
    }
  }
  String? _getOfflineFaq(String userText) {
    final lower = userText.toLowerCase().trim();

    // Greetings
    if (lower == "hi" ||
        lower == "hello" ||
        lower == "hey" ||
        lower.contains("good morning") ||
        lower.contains("good afternoon") ||
        lower.contains("good evening")) {
      return "Hello! 👋 I'm AuroBot. How can I help you today?";
    }

    // About AuraDo
    if (lower.contains("what is aurado") ||
        lower.contains("what is aura do") ||
        lower.contains("about aurado") ||
        lower.contains("about this app") ||
        lower.contains("what is this app") ||
        lower.contains("tell me about aurado")) {
      return "AuraDo is a task management app that helps you organize tasks, set reminders, manage categories, track completed tasks, and stay productive using AuroBot.";
    }

    // How AuraDo works
    if (lower.contains("how does this app work") ||
        lower.contains("how this app works") ||
        lower.contains("how does aurado work")) {
      return "AuraDo lets you create tasks, set reminders, organize them into categories, mark them complete, and manage everything with AuroBot.";
    }

    // Add Task
    if (lower.contains("how to add task") ||
        lower.contains("how do i add task") ||
        lower.contains("create task") ||
        lower.contains("new task")) {
      return "Open the Add Task screen, enter the task details, choose category, date and time, then tap Save. You can also ask me 'Add a shopping task tomorrow at 5 PM'.";
    }

    // Delete Task
    if (lower.contains("how to delete task") ||
        lower.contains("remove task")) {
      return "Open the task list and delete the task, or simply ask me 'Delete my shopping task'.";
    }

    // Complete Task
    if (lower.contains("how to complete task") ||
        lower.contains("complete task") ||
        lower.contains("finish task") ||
        lower.contains("mark task complete")) {
      return "Open the task and mark it as completed, or ask me 'Complete my homework task'.";
    }

    // Edit Task
    if (lower.contains("how to edit task") ||
        lower.contains("edit task") ||
        lower.contains("update task")) {
      return "Open the task, update its information, and save the changes.";
    }

    // Reminder
    if (lower.contains("set reminder") ||
        lower.contains("reminder")) {
      return "Every task can have a reminder. Select the due date and time while creating or editing a task.";
    }

    // Features
    if (lower.contains("what can you do") ||
        lower.contains("your features") ||
        lower.contains("features") ||
        lower.contains("how can you help")) {
      return "I can:\n\n"
          "• Add tasks\n"
          "• Delete tasks\n"
          "• Complete tasks\n"
          "• Edit reminders\n"
          "• Show your tasks\n"
          "• Answer questions about AuraDo";
    }

    // Categories
    if (lower.contains("category") ||
        lower.contains("categories")) {
      return "AuraDo supports these categories:\n\n"
          "• Work\n"
          "• Personal\n"
          "• Shopping\n"
          "• Health\n"
          "• Habit";
    }

    // Today's Tasks
    if (lower.contains("today tasks") ||
        lower.contains("today's tasks")) {
      return "You can simply ask me:\nShow my today's tasks.";
    }

    // Upcoming Tasks
    if (lower.contains("upcoming tasks")) {
      return "Upcoming tasks are tasks scheduled for future dates.";
    }

    // Completed Tasks
    if (lower.contains("completed tasks")) {
      return "Completed tasks contain all tasks that you have finished.";
    }

    // Missed Tasks
    if (lower.contains("missed tasks") ||
        lower.contains("overdue")) {
      return "Missed tasks are tasks whose due date has passed but are not completed.";
    }

    // Notifications
    if (lower.contains("notification") ||
        lower.contains("notifications")) {
      return "AuraDo can send reminders before your tasks are due if notifications are enabled.";
    }

    // Theme
    if (lower.contains("theme") ||
        lower.contains("dark mode") ||
        lower.contains("light mode") ||
        lower.contains("color")) {
      return "You can customize the app theme and colors from the Settings screen.";
    }

    // Productivity Tips
    if (lower.contains("productivity") ||
        lower.contains("tips")) {
      return "💡 Productivity Tip:\nBreak large tasks into smaller tasks and set realistic deadlines to stay organized.";
    }

    // Who are you
    if (lower.contains("who are you") ||
        lower.contains("what is chatbot") ||
        lower.contains("what are you") ||
        lower.contains("who made you")) {
      return "I am AuroBot, your AI assistant inside AuraDo. I help you manage tasks and answer questions about the app.";
    }

    // Thanks
    if (lower.contains("thank")) {
      return "You're welcome! 😊";
    }

    // Bye
    if (lower == "bye" ||
        lower.contains("goodbye") ||
        lower.contains("see you")) {
      return "Goodbye! 👋 Have a productive day.";
    }

    // Purpose of the app
    if (lower.contains("why should i use aurado") ||
        lower.contains("why use aurado") ||
        lower.contains("purpose of aurado")) {
      return "AuraDo helps you organize your daily tasks, manage reminders, and improve productivity in one place.";
    }

    // Save task
    if (lower.contains("how to save task") ||
        lower.contains("save task")) {
      return "After entering the task details, tap the Save button to store your task.";
    }

    // Due date
    if (lower.contains("due date")) {
      return "The due date is the deadline for completing your task. You can choose it while creating or editing a task.";
    }

    // Priority
    if (lower.contains("priority")) {
      return "AuraDo supports High, Medium, and Low priority tasks to help you organize your work.";
    }

    // Search
    if (lower.contains("search task")) {
      return "You can search tasks by their title to quickly find what you're looking for.";
    }

    // Multiple tasks
    if (lower.contains("multiple tasks")) {
      return "Yes, AuraDo allows you to create and manage as many tasks as you need.";
    }

    // Internet
    if (lower.contains("internet") ||
        lower.contains("offline")) {
      return "Basic task management works offline. AI responses require an internet connection.";
    }

    // Login
    if (lower.contains("login")) {
      return "Use your registered email and password to log into your AuraDo account.";
    }

    // Signup
    if (lower.contains("sign up") ||
        lower.contains("signup") ||
        lower.contains("register")) {
      return "Create a new account using your email and password from the Sign Up screen.";
    }

    // Forgot password
    if (lower.contains("forgot password") ||
        lower.contains("reset password")) {
      return "Use the Forgot Password option on the login screen to reset your password.";
    }

    // AI chatbot
    if (lower.contains("ai") ||
        lower.contains("chatbot") ||
        lower.contains("aurobot")) {
      return "AuroBot is the AI assistant inside AuraDo. It can manage tasks and answer questions about the app.";
    }

    // Data safety
    if (lower.contains("data") ||
        lower.contains("privacy")) {
      return "Your task information stays within your AuraDo account and is used only to provide app functionality.";
    }

    // Time format
    if (lower.contains("time format")) {
      return "AuraDo uses a 24-hour time format internally while displaying user-friendly time in the app.";
    }

    // Date format
    if (lower.contains("date format")) {
      return "AuraDo stores dates in YYYY-MM-DD format.";
    }

    // Motivation
    if (lower.contains("motivate me") ||
        lower.contains("motivation")) {
      return "🌟 Small progress every day leads to big achievements. Stay focused and keep going!";
    }

    // Productivity quote
    if (lower.contains("quote")) {
      return "💡 'Success is the sum of small efforts repeated day after day.'";
    }

    // Help
    if (lower == "help") {
      return "I can help you:\n\n"
          "• Add tasks\n"
          "• Delete tasks\n"
          "• Complete tasks\n"
          "• Edit reminders\n"
          "• List tasks\n"
          "• Explain AuraDo features";
    }

    // Version
    if (lower.contains("version")) {
      return "You're using the AuraDo task management application.";
    }

    // Developer
    if (lower.contains("developer") ||
        lower.contains("developed")) {
      return "AuraDo was developed as a smart AI-powered task management application.";
    }

    // Thank you
    if (lower.contains("thanks") ||
        lower.contains("thank you")) {
      return "You're most welcome! 😊 Happy to help.";
    }

    // Nice / Great
    if (lower.contains("nice") ||
        lower.contains("great") ||
        lower.contains("awesome")) {
      return "😊 Thank you! I'm glad you like it.";
    }

    // Good night
    if (lower.contains("good night")) {
      return "Good night! 🌙 Have a peaceful sleep and a productive tomorrow.";
    }

    // Good luck
    if (lower.contains("wish me luck")) {
      return "🍀 Good luck! You've got this!";
    }
    // ===============================
    // SMALL TALK
    // ===============================

    if (lower.contains("how are you")) {
      return "I'm doing great! 😊 How can I help you today?";
    }

    if (lower.contains("what's up") ||
        lower.contains("whats up")) {
      return "Not much! I'm here and ready to help you manage your tasks.";
    }

    if (lower.contains("are you real")) {
      return "I'm an AI assistant built to help you inside AuraDo.";
    }

    if (lower.contains("can you talk")) {
      return "I communicate through chat and I'm always happy to help.";
    }

    if (lower.contains("do you sleep")) {
      return "No 😄 I'm always available whenever you need me.";
    }

    // ===============================
    // APP INFORMATION
    // ===============================

    if (lower.contains("why use aurado") ||
        lower.contains("purpose of aurado")) {
      return "AuraDo is designed to help you stay organized, productive, and never miss important tasks.";
    }

    if (lower.contains("is aurado free")) {
      return "Yes, AuraDo can be used for managing your daily tasks.";
    }

    if (lower.contains("who developed aurado") ||
        lower.contains("developer")) {
      return "AuraDo is an AI-powered task management application.";
    }

    if (lower.contains("latest version")) {
      return "You're currently using AuraDo Task Manager.";
    }

    // ===============================
    // LOGIN
    // ===============================

    if (lower.contains("login")) {
      return "Use your registered email and password to log in.";
    }

    if (lower.contains("signup") ||
        lower.contains("sign up") ||
        lower.contains("register")) {
      return "Create an account from the Sign Up screen using your email and password.";
    }

    if (lower.contains("forgot password") ||
        lower.contains("reset password")) {
      return "Use the Forgot Password option on the login screen.";
    }

    // ===============================
    // TASKS
    // ===============================

    if (lower.contains("save task")) {
      return "Fill in the task details and press Save.";
    }

    if (lower.contains("maximum tasks")) {
      return "AuraDo lets you manage multiple tasks efficiently.";
    }

    if (lower.contains("task categories")) {
      return "Available categories are Work, Personal, Shopping, Health and Habit.";
    }

    if (lower.contains("priority")) {
      return "Task priorities are High, Medium and Low.";
    }

    if (lower.contains("due date")) {
      return "The due date is the deadline for completing a task.";
    }

    if (lower.contains("due time")) {
      return "The due time specifies when your reminder or deadline occurs.";
    }

    if (lower.contains("search task")) {
      return "Search your tasks using the task title.";
    }

    // ===============================
    // REMINDERS
    // ===============================

    if (lower.contains("notification")) {
      return "Enable notifications to receive task reminders.";
    }

    if (lower.contains("alarm")) {
      return "AuraDo reminders notify you before your task is due.";
    }

    // ===============================
    // SETTINGS
    // ===============================

    if (lower.contains("settings")) {
      return "You can customize your preferences from the Settings screen.";
    }

    if (lower.contains("theme")) {
      return "AuraDo supports customizable themes.";
    }

    if (lower.contains("dark mode")) {
      return "Dark mode can be enabled from Settings if available.";
    }

    if (lower.contains("change color")) {
      return "You can personalize the app theme color from Settings.";
    }

    // ===============================
    // OFFLINE
    // ===============================

    if (lower.contains("offline")) {
      return "Basic task management works offline. AI chat requires internet.";
    }

    if (lower.contains("internet")) {
      return "Internet is required only for AI chatbot responses.";
    }

    // ===============================
    // PRODUCTIVITY
    // ===============================

    if (lower.contains("productivity")) {
      return "Break large tasks into smaller ones and complete them one by one.";
    }

    if (lower.contains("study tips")) {
      return "Study consistently, avoid distractions, and complete one task at a time.";
    }

    if (lower.contains("work tips")) {
      return "Prioritize important tasks before less important ones.";
    }

    // ===============================
    // MOTIVATION
    // ===============================

    if (lower.contains("motivate me")) {
      return "🌟 Every small step today brings you closer to your goals.";
    }

    if (lower.contains("quote")) {
      return "💡 Success comes from consistent effort, not perfection.";
    }

    if (lower.contains("wish me luck")) {
      return "🍀 Best of luck! You've got this!";
    }

    // ===============================
    // POLITE RESPONSES
    // ===============================

    if (lower.contains("thanks") ||
        lower.contains("thank you")) {
      return "You're welcome! 😊";
    }

    if (lower.contains("good job")) {
      return "😊 Thank you! That means a lot.";
    }

    if (lower.contains("awesome") ||
        lower.contains("great") ||
        lower.contains("nice")) {
      return "😊 I'm glad you liked it!";
    }

    if (lower.contains("sorry")) {
      return "No worries! 😊";
    }

    // ===============================
    // GOODBYE
    // ===============================

    if (lower.contains("bye")) {
      return "Goodbye! 👋 Have a productive day.";
    }

    if (lower.contains("see you")) {
      return "See you soon! 👋";
    }

    if (lower.contains("good night")) {
      return "🌙 Good night! Rest well.";
    }

    if (lower.contains("good morning")) {
      return "☀️ Good morning! Have a productive day.";
    }

    if (lower.contains("good evening")) {
      return "🌇 Good evening! Hope you're having a great day.";
    }

    // ===============================
    // HELP
    // ===============================

    if (lower == "help") {
      return "I can help you with:\n\n"
          "• Add Tasks\n"
          "• Delete Tasks\n"
          "• Complete Tasks\n"
          "• Set Reminders\n"
          "• Show Tasks\n"
          "• Explain AuraDo Features\n"
          "• General Questions";
    }
    return null;
  }

  /// Very small heuristic: if the user's message contains common Roman-Urdu
  /// words, treat it as Urdu; otherwise treat it as English. Used only for
  /// the hardcoded confirmation strings below (add/complete/delete/list),
  /// since those are NOT generated by the AI and wouldn't otherwise follow
  /// the language rule in the system prompt.
  bool _isEnglishMessage(String text) {
    final lower = text.toLowerCase();
    const urduMarkers = [
      'hai', 'hy', 'kal', 'aaj', 'kar', 'karo', 'kro', 'krdo', 'mera', 'meri',
      'mujhe', 'wala', 'wali', 'bata', 'dikhao', 'dikha', 'ap ', 'aap',
      'kya', 'nahi', 'nhi', 'krna', 'karna', 'abhi', 'sara', 'saare',
      ' ka ', ' ki ', ' ko ', ' se ', 'plz kro', 'theek', 'thk', 'acha',
    ];
    for (final marker in urduMarkers) {
      if (lower.contains(marker)) return false;
    }
    return true;
  }

  Future<String> _getGroqReply(TaskManager taskManager, String userText) async {

    // ===============================
// OFFLINE FAQ CHECK
// ===============================
    final offlineReply = _getOfflineFaq(userText);

    if (offlineReply != null) {
      return offlineReply;
    }
    final isEnglish = _isEnglishMessage(userText);



    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_kGroqApiKey',
      },
      body: jsonEncode({
        'model': _kGroqModel,
        'messages': [
          {
            'role': 'system',
            'content':
            'You are AuroBot, a calm task-assistant chatbot inside a task management app. '
                'Today\'s date is $today. '
                'Categories available: Work, Personal, Shopping, Health, Habit (exact capitalization). '
                'When the user asks to add/complete/delete a task, set a reminder, or explicitly asks to '
                'see/list their tasks, ALWAYS call the matching function instead of just replying with text. '
                'For casual greetings or small talk (e.g. "hi", "hello", "kya hal hai") that do NOT request '
                'a task action, just reply with a short friendly text message — do NOT call list_tasks or '
                'any other function unless the user actually asked for it. '
                '\n\nLANGUAGE RULE (very important): Look ONLY at the user\'s most recent message to decide '
                'the reply language. '
                'If that message is written in English, reply ENTIRELY in English — no Urdu words. '
                'If that message is written in Roman Urdu (Urdu words spelled in English letters) or Urdu script, '
                'reply ENTIRELY in Roman Urdu — no English sentences. '
                'If the user mixes both languages in one message, you may mirror that same mix back. '
                'Never default to a mixed style on your own; always match the user\'s latest message.'
          },
          ..._chatHistoryForApi,
        ],
        'tools': _tools,
        'tool_choice': 'auto',
        'max_tokens': 400,
        'temperature': 0.4,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final message = data['choices'][0]['message'];
    final toolCalls = message['tool_calls'] as List?;

    if (toolCalls != null && toolCalls.isNotEmpty) {
      final results = <String>[];
      for (final call in toolCalls) {
        final fnName = call['function']['name'] as String;
        final argsRaw = call['function']['arguments'] as String;
        final args = jsonDecode(argsRaw) as Map<String, dynamic>;
        results.add(_executeTool(fnName, args, taskManager, isEnglish));
      }
      return results.join('\n');
    }

    return (message['content'] as String?)?.trim() ??
        'Samajh gaya, lekin thoda aur bata dein.';
  }

  /// Runs the actual action against the real TaskManager singleton and
  /// returns a human-friendly confirmation message.
  String _executeTool(String fnName, Map<String, dynamic> args,
      TaskManager manager, bool isEnglish) {
    switch (fnName) {
      case 'add_task':
        final title = (args['title'] as String?)?.trim();
        if (title == null || title.isEmpty) {
          return isEnglish
              ? '❓ I didn\'t catch the task title, please try again.'
              : '❓ Task ka title samajh nahi aaya, dobara batayein.';
        }
        final category = _normalizeCategory(args['category'] as String?);
        final priority = args['priority'] as String?;
        final description = (args['description'] as String?) ?? '';
        final dueDateTime = _parseDateTime(
          args['due_date'] as String?,
          args['due_time'] as String?,
        );

        final task = TaskModel(
          title: title,
          description: description,
          category: category,
          priority: priority,
          dueDateTime: dueDateTime,
          minutesBefore: 10,
          notification: true,
        );
        manager.addTask(task);
        final formattedDate =
        DateFormat('MMM d, hh:mm a').format(dueDateTime);
        return isEnglish
            ? '✅ Task added: "$title" ($category, $formattedDate)'
            : '✅ Task add ho gaya: "$title" ($category, $formattedDate)';

      case 'complete_task':
        final title = args['title'] as String? ?? '';
        final task = manager.findByTitle(title);
        if (task == null) {
          return isEnglish
              ? '❓ I couldn\'t find a task named "$title".'
              : '❓ Mujhe "$title" naam ka task nahi mila.';
        }
        manager.markTaskAsCompleted(task);
        return isEnglish
            ? '🎉 "${task.title}" marked as complete!'
            : '🎉 "${task.title}" complete mark kar diya!';

      case 'delete_task':
        final title = args['title'] as String? ?? '';
        final task = manager.findByTitle(title);
        if (task == null) {
          return isEnglish
              ? '❓ I couldn\'t find a task named "$title".'
              : '❓ Mujhe "$title" naam ka task nahi mila.';
        }
        manager.removeTask(task);
        return isEnglish
            ? '🗑️ "${task.title}" deleted.'
            : '🗑️ "${task.title}" delete kar diya.';

      case 'set_reminder':
        final title = args['title'] as String? ?? '';
        final task = manager.findByTitle(title);
        if (task == null) {
          return isEnglish
              ? '❓ I couldn\'t find a task named "$title".'
              : '❓ Mujhe "$title" naam ka task nahi mila.';
        }
        final newDateTime = _parseDateTime(
          args['due_date'] as String?,
          args['due_time'] as String?,
        );
        final updated = task.copyWith(dueDateTime: newDateTime);
        manager.updateTask(task, updated);
        final formattedDate =
        DateFormat('MMM d, hh:mm a').format(newDateTime);
        return isEnglish
            ? '⏰ Reminder for "${task.title}" set to $formattedDate.'
            : '⏰ "${task.title}" ka reminder $formattedDate par set kar diya.';

      case 'list_tasks':
        final filter = args['filter'] as String? ?? 'all';
        final category = args['category'] as String?;
        return _formatTaskList(filter, category, manager, isEnglish);

      default:
        return isEnglish
            ? 'This action isn\'t supported yet.'
            : 'Ye action abhi supported nahi hai.';
    }
  }

  String _formatTaskList(String filter, String? category, TaskManager manager,
      bool isEnglish) {
    List<TaskModel> tasks;
    switch (filter) {
      case 'today':
        tasks = manager.getTodayTasks();
        break;
      case 'upcoming':
        tasks = manager.getUpcomingTasks();
        break;
      case 'completed':
        tasks = manager.getCompletedTasks();
        break;
      case 'missed':
        tasks = manager.getMissedTasks();
        break;
      default:
        tasks = manager.tasks;
    }

    if (category != null && category != 'any') {
      final normalized = _normalizeCategory(category);
      tasks = tasks.where((t) => t.category == normalized).toList();
    }

    if (tasks.isEmpty) {
      return isEnglish
          ? 'No tasks found for this filter. 📭'
          : 'Is filter me abhi koi task nahi hai. 📭';
    }

    final buffer = StringBuffer(isEnglish
        ? '📋 Your tasks ($filter):\n'
        : '📋 Aapke tasks ($filter):\n');
    for (final t in tasks) {
      final categoryLabel =
          t.category ?? (isEnglish ? 'No category' : 'No category');
      buffer.writeln('• ${t.title} ($categoryLabel)');
    }
    return buffer.toString().trim();
  }

  String? _normalizeCategory(String? raw) {
    if (raw == null) return null;
    for (final c in _kValidCategories) {
      if (c.toLowerCase() == raw.toLowerCase()) return c;
    }
    return raw;
  }

  DateTime _parseDateTime(String? dateRaw, String? timeRaw) {
    DateTime date;
    try {
      date = dateRaw == null || dateRaw.isEmpty
          ? DateTime.now()
          : DateFormat('yyyy-MM-dd').parse(dateRaw);
    } catch (_) {
      date = DateTime.now();
    }

    int hour = 9;
    int minute = 0;
    if (timeRaw != null && timeRaw.contains(':')) {
      try {
        final parts = timeRaw.split(':');
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      } catch (_) {
        // keep defaults
      }
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
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

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTablet = width >= 600;
    final isSmallPhone = width < 360;

    final horizontalPadding = width * 0.03;
    final headerFontSize = isTablet ? 15.0 : (isSmallPhone ? 11.5 : 13.0);
    final greetingFontSize = isTablet ? 20.0 : (isSmallPhone ? 14.0 : 16.0);
    final bubbleFontSize = isTablet ? 16.0 : (isSmallPhone ? 13.0 : 14.0);
    final bubbleMaxWidth = isTablet ? width * 0.55 : width * 0.75;
    final maxContentWidth = isTablet ? 700.0 : double.infinity;

    return Scaffold(
      backgroundColor: fromHex(prefs.themeColor),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      ],
                    ),
                  ),
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
                                hintText: 'e.g. "Kal shopping task add karo"',
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