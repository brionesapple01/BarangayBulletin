import 'package:flutter/material.dart';
import 'screens/announcements_list_screen.dart';
import 'screens/reports_list_screen.dart';
import 'screens/archive_screen.dart';

void main() {
  runApp(const BarangayBulletinApp());
}

class BarangayBulletinApp extends StatelessWidget {
  const BarangayBulletinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Bulletin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 243, 33, 166),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  List<Map<String, String>> announcements = [
    {
      'title': 'Announcement 1',
      'body': 'This is the content for announcement 1.',
    },
    {
      'title': 'Announcement 2',
      'body': 'This is the content for announcement 2.',
    },
    {
      'title': 'Announcement 3',
      'body': 'This is the content for announcement 3.',
    },
  ];

  List<Map<String, String>> reports = [
    {
      'title': 'Report 1',
      'body': 'Details of report 1.',
      'status': 'Pending',
    },
    {
      'title': 'Report 2',
      'body': 'Details of report 2.',
      'status': 'In Progress',
    },
    {
      'title': 'Report 3',
      'body': 'Details of report 3.',
      'status': 'Resolved',
    },
  ];

  void addAnnouncement(Map<String, String> newAnnouncement) {
    setState(() {
      announcements.add(newAnnouncement);
    });
  }

  void updateAnnouncement(int index, Map<String, String> updatedAnnouncement) {
    setState(() {
      announcements[index] = updatedAnnouncement;
    });
  }

  void addReport(Map<String, String> newReport) {
    setState(() {
      reports.add(newReport);
    });
  }

  void updateReport(int index, Map<String, String> updatedReport) {
    setState(() {
      reports[index] = updatedReport;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barangay Bulletin'),
        backgroundColor: const Color.fromARGB(255, 243, 33, 138),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AnnouncementsListScreen(
            announcements: announcements,
            onAddAnnouncement: addAnnouncement,
            onUpdateAnnouncement: updateAnnouncement,
          ),
          ReportsListScreen(
            reports: reports,
            onAddReport: addReport,
            onUpdateReport: updateReport,
          ),
          const ArchiveScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color.fromARGB(255, 243, 33, 149),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
        ],
      ),
    );
  }
}