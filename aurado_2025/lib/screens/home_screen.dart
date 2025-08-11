import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'create_a_task_screen.dart';
import 'notification_test_screen.dart';
import 'chatbot_screen.dart';
import 'account_screen.dart';
import 'today_screen.dart';
import 'UpcomingScreen.dart';
import 'CompletedScreen.dart';
import 'missed_screen.dart';
import 'work_screen.dart';
import 'PersonalScreen.dart';
import 'HealthScreen.dart';
import 'ShoppingScreen.dart';
import 'HabitScreen.dart';
import '../widgets/progress_chart.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../models/chart_data.dart';
import 'package:aurado_2025/task_manager.dart';
import '../providers/user_provider.dart';  // Import UserProvider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Timer? _timer;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Periodic rebuild
      setState(() {});
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, int> getCategoryCounts(List<TaskModel> tasks) {
    final categories = ['Work', 'Personal', 'Shopping', 'Health', 'Habit'];
    return {
      for (var category in categories)
        category: tasks.where((task) => task.category == category).length
    };
  }

  String _getInitials(String fullName) {
    List<String> parts = fullName.split(' ');
    String initials = '';
    if (parts.isNotEmpty) initials += parts[0][0].toUpperCase();
    if (parts.length > 1) initials += parts[1][0].toUpperCase();
    return initials.isNotEmpty ? initials : '?';
  }

  Widget _buildDashboard(BuildContext context, User user) {
    return Consumer<TaskManager>(
      builder: (context, taskManager, child) {
        final tasks = taskManager.tasks;

        // Filter tasks based on search query
        final filteredTasks = _searchQuery.isEmpty
            ? tasks
            : tasks.where((task) =>
        (task.title?.toLowerCase() ?? '')
            .contains(_searchQuery.toLowerCase()) ||
            (task.description?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase()))
            .toList();

        final categoryCounts = getCategoryCounts(tasks);
        final barChartData = categoryCounts.entries
            .map((e) => ChartData(e.key, e.value.toDouble()))
            .toList();

        final username = user.username;
        String initial = username.isNotEmpty ? _getInitials(username) : 'U';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile + Welcome + Create Task Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Color(0xFF800000),
                          backgroundImage: user.profileImage != null
                              ? FileImage(user.profileImage!)
                              : null,
                          child: user.profileImage == null
                              ? Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                              : null,
                        ),

                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$username 🌸',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateTaskScreen(
                              onTaskCreated: (TaskModel newTask) {
                                Provider.of<TaskManager>(context, listen: false).addTask(newTask);
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: const Text('Create a Task'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Tasks',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Search Results
                if (_searchQuery.isNotEmpty) ...[
                  const Text('Search Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  filteredTasks.isEmpty
                      ? const Center(
                    child: Text(
                      'No tasks found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(task.title ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(task.description ?? ''),
                          trailing: Text(task.category ?? ''),
                          onTap: () {
                            switch (task.category) {
                              case 'Work':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => WorkScreen()));
                                break;
                              case 'Personal':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => PersonalScreen()));
                                break;
                              case 'Health':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => HealthScreen()));
                                break;
                              case 'Shopping':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ShoppingScreen()));
                                break;
                              case 'Habit':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => HabitScreen()));
                                break;
                            }
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Category Icons
                const Text('Task Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryIcon('Work', 'assets/work.png'),
                    _buildCategoryIcon('Personal', 'assets/personal.png'),
                    _buildCategoryIcon('Health', 'assets/health.png'),
                    _buildCategoryIcon('Shopping', 'assets/shopping.png'),
                    _buildCategoryIcon('Habit', 'assets/Habit.png'),
                  ],
                ),

                const SizedBox(height: 16),

                // Task Cards
                const Text('Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTaskCard('Today', 'assets/Today.png'),
                      const SizedBox(width: 8),
                      _buildTaskCard('Upcoming', 'assets/Upcoming.png'),
                      const SizedBox(width: 8),
                      _buildTaskCard('Completed', 'assets/completed.png'),
                      const SizedBox(width: 8),
                      _buildTaskCard('Missed', 'assets/Missed.png'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bar Chart
                const Text('Bar Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<ChartData, String>(
                        dataSource: barChartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        color: const Color(0xFF800000),
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Progress Chart
                const Text('Tasks Status Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ProgressChart(tasks: tasks),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(String label, String assetPath) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Work':
            Navigator.push(context, MaterialPageRoute(builder: (_) => WorkScreen()));
            break;
          case 'Personal':
            Navigator.push(context, MaterialPageRoute(builder: (_) => PersonalScreen()));
            break;
          case 'Health':
            Navigator.push(context, MaterialPageRoute(builder: (_) => HealthScreen()));
            break;
          case 'Shopping':
            Navigator.push(context, MaterialPageRoute(builder: (_) => ShoppingScreen()));
            break;
          case 'Habit':
            Navigator.push(context, MaterialPageRoute(builder: (_) => HabitScreen()));
            break;
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF800000), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(assetPath, width: 40, height: 40, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String assetPath) {
    Color backgroundColor;
    if (title == 'Completed') {
      backgroundColor = const Color(0xFFFFD700);
    } else if (title == 'Upcoming') {
      backgroundColor = const Color(0xFFD560B8);
    } else if (title == 'Missed') {
      backgroundColor = const Color(0xFF60D591);
    } else {
      backgroundColor = const Color(0xFF9F60D5);
    }

    return Container(
      width: 124,
      height: 155,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 65, height: 65, decoration: const BoxDecoration(color: Color(0x76C4C4C4), shape: BoxShape.circle)),
              Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              Image.asset(assetPath, width: 40, height: 40, fit: BoxFit.contain),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 100,
            height: 30,
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4)],
              ),
              child: TextButton(
                onPressed: () {
                  switch (title) {
                    case 'Today':
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TodayScreen()));
                      break;
                    case 'Upcoming':
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UpcomingScreen()));
                      break;
                    case 'Completed':
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CompletedScreen()));
                      break;
                    case 'Missed':
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MissedScreen()));
                      break;
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0x80C4C4C4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Main build method
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user; // Get current user

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Dashboard'
              : _selectedIndex == 1
              ? 'AuraBot'
              : _selectedIndex == 2
              ? 'Notifications'
              : 'Account',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: [
        _buildDashboard(context, user), // Pass username to dashboard
         ChatbotScreen(),
          NotificationScreen(),
        const AccountScreen(),
      ][_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade400, // color of the box's top border
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, -1), // shadow above the nav bar
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0, // keep elevation 0 because container has shadow
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // already set on container
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chatbot'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
          ],
        ),
      ),


    );
  }
}
