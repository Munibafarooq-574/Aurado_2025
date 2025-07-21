import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'create_a_task_screen.dart';
import '../models/chart_data.dart';


class Task {
  final String title;
  final String category; // Work, Personal, etc.
  final String status;   // Today, Upcoming, Completed, Missed

  Task({
    required this.title,
    required this.category,
    required this.status,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final String _username = 'Muniba';

  // Sample tasks list
  final List<Task> tasks = [
    Task(title: 'Email Client', category: 'Work', status: 'Today'),
    Task(title: 'Yoga', category: 'Health', status: 'Completed'),
    Task(title: 'Buy Groceries', category: 'Shopping', status: 'Missed'),
    Task(title: 'Read Book', category: 'Personal', status: 'Upcoming'),
    Task(title: 'Walk', category: 'Habit', status: 'Today'),
    Task(title: 'Project Report', category: 'Work', status: 'Completed'),
    Task(title: 'Meditate', category: 'Habit', status: 'Upcoming'),
    Task(title: 'Doctor Appointment', category: 'Health', status: 'Upcoming'),
    Task(title: 'Laundry', category: 'Personal', status: 'Missed'),
    Task(title: 'Order Supplies', category: 'Shopping', status: 'Today'),
  ];

  // Calculate category counts for Bar Chart
  Map<String, int> getCategoryCounts(List<Task> tasks) {
    final categories = ['Work', 'Personal', 'Shopping', 'Health', 'Habit'];
    return {
      for (var category in categories)
        category: tasks.where((task) => task.category == category).length
    };
  }

  // Calculate status percentages for Pie Chart
  Map<String, double> getStatusPercentages(List<Task> tasks) {
    final statusLabels = ['Today', 'Upcoming', 'Completed', 'Missed'];
    int total = tasks.length;
    return {
      for (var status in statusLabels)
        status: total == 0 ? 0 : (tasks.where((task) => task.status == status).length / total) * 100
    };
  }

  Widget _buildDashboard() {
    // Prepare chart data dynamically
    final categoryCounts = getCategoryCounts(tasks);
    final barChartData = categoryCounts.entries
        .map((e) => ChartData(e.key, e.value.toDouble())) // convert int to double
        .toList();

    final statusPercentages = getStatusPercentages(tasks);
    final pieData = statusPercentages.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();

    String initial = _username.isNotEmpty ? _username[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(color: Color(0xFF800000), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF800000),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$_username 🌸',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                        builder: (context) => const CreateTaskScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: 14),
                  ),
                  child: Text('Create a Task'),
                ),

              ],
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Task Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
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
            SizedBox(height: 16),
            Text('Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTaskCard('Today', 'assets/Today.png'),
                  SizedBox(width: 8),
                  _buildTaskCard('Upcoming', 'assets/Upcoming.png'),
                  SizedBox(width: 8),
                  _buildTaskCard('Completed', 'assets/completed.png'),
                  SizedBox(width: 8),
                  _buildTaskCard('Missed', 'assets/Missed.png'),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Pie Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: pieData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Bar Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                    dataSource: barChartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Color(0xFF800000),
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbot() => Center(child: Text('Chatbot Screen'));
  Widget _buildNotifications() => Center(child: Text('Notifications Screen'));
  Widget _buildAccount() => Center(child: Text('Account Screen'));

  late final List<Widget> _screens = [
    _buildDashboard(),
    _buildChatbot(),
    _buildNotifications(),
    _buildAccount(),
  ];

  Widget _buildCategoryIcon(String label, String assetPath) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF800000), width: 2),
          ),
          child: ClipOval(
            child: Image.asset(assetPath, width: 40, height: 40, fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTaskCard(String title, String assetPath) {
    Color backgroundColor;
    if (title == 'Completed') {
      backgroundColor = Color(0xFFFFD700);
    } else if (title == 'Upcoming') {
      backgroundColor = Color(0xFFD560B8);
    } else if (title == 'Missed') {
      backgroundColor = Color(0xFF60D591);
    } else {
      backgroundColor = Color(0xFF9F60D5);
    }

    return Container(
      width: 124,
      height: 155,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(64), offset: Offset(0, 4), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 65, height: 65, decoration: BoxDecoration(color: Color(0x76C4C4C4), shape: BoxShape.circle)),
              Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              Image.asset(assetPath, width: 40, height: 40, fit: BoxFit.contain),
            ],
          ),
          SizedBox(height: 22),
          SizedBox(
            width: 100,
            height: 30,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(64), offset: Offset(0, 4), blurRadius: 4)],
              ),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Color(0x80C4C4C4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Dashboard'
              : _selectedIndex == 1
              ? 'Chatbot'
              : _selectedIndex == 2
              ? 'Notifications'
              : 'Account',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black,
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
    );
  }
}
