import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  final List<String> _categories = ['All', 'Info', 'Event', 'Emergency', 'Health'];
  String _selectedCategory = 'All';
  late Box _box;
  
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('announcements');
    
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _box.watch().listen((event) {
      _listener();
    });
    
    if (_box.isEmpty) {
      _addSampleData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addSampleData() {
    final List<Map<String, dynamic>> sampleAnnouncements = [
      {
        'id': '1',
        'title': 'New Barangay Clearance Process',
        'body': 'The Barangay Office is pleased to announce that starting June 1, 2024, all barangay clearance applications will be processed through our new barangay system. Residents no longer need to fall in line at the barangay hall. Simply visit the barangay hall to schedule an appointment through the new kiosk. After scheduling, bring the following requirements on your chosen date: filled out application form, valid government ID, proof of residency such as utility bill or lease contract, and community tax certificate. Processing time is now only 15 minutes per applicant. For questions, contact Barangay Secretary Maria Santos at the barangay hotline number posted outside the hall.',
        'category': 'Info',
        'isPinned': false,
        'datePosted': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '2',
        'title': 'Senior Citizen Benefits Registration',
        'body': 'All senior citizens aged 60 years old and above who have not yet registered for the Barangay Senior Citizen Program are encouraged to visit the Barangay Health Center from Monday to Friday, 8:00 AM to 5:00 PM. The following benefits are available for registered senior citizens: monthly grocery package, free flu vaccination, birthday cash gift of Five Hundred Pesos, and death assistance benefit of Three Thousand Pesos. Requirements for registration include: birth certificate or any valid ID showing age, one piece 1x1 ID picture, and proof of residency in the barangay. Registration is free and open to all qualified residents.',
        'category': 'Info',
        'isPinned': true,
        'datePosted': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '3',
        'title': 'Blood Donation Drive',
        'body': 'The Barangay Health Center in partnership with the Philippine Red Cross will conduct a Blood Donation Drive on July 15, 2024 from 8:00 AM to 3:00 PM at the Barangay Hall Conference Room. Donors must be between 18 to 60 years old, weigh at least 50 kilograms, and be in good general health. Donors should have eaten a full meal within four hours before donation and should be well rested. Each donor will receive a free snack pack, a Red Cross T-shirt, and a certificate of appreciation. The blood collected will benefit residents who are scheduled for surgery, patients with dengue, and mothers experiencing childbirth complications. To pre-register, visit the Barangay Health Center and look for Nurse Janet. Walk-in donors are also welcome.',
        'category': 'Event',
        'isPinned': false,
        'datePosted': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '4',
        'title': 'Tree Planting Activity',
        'body': 'The Barangay Environment Committee invites all residents to join the Tree Planting Activity on June 25, 2024 at 7:00 AM. Assembly point is at the Barangay Plaza. Participants will be transported by barangay service vehicles to the planting site at the Upper Barangay Watershed Area. The goal is to plant five hundred native tree seedlings including Narra, Molave, and Mahogany. Participants are advised to wear old clothes and rubber boots. Please bring your own shovel, gloves, and drinking water. The barangay will provide the tree seedlings, fertilizer, and lunch packs. Each participant will receive a certificate of participation. Students can use this activity to fulfill their community service requirements.',
        'category': 'Event',
        'isPinned': true,
        'datePosted': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '5',
        'title': 'Road Closure Advisory',
        'body': 'The Department of Public Works and Highways has announced a full road closure of Maharlika Highway from Kilometer 15 to Kilometer 18 on June 10, 2024 from 6:00 AM to 6:00 PM. This closure is necessary for major road repair and asphalt resurfacing works. Motorists are advised to take the following alternate routes. Light vehicles may use the service road passing through Riverside Subdivision then exiting at the Petron Gas Station. Trucks and heavy vehicles must use the diversion road via the National Road passing through the neighboring town of San Isidro. Traffic enforcers will be stationed at all major intersections to assist motorists. Residents living along the affected area should expect heavy traffic and increased noise from construction equipment. Emergency vehicles will still be allowed passage with escort from traffic enforcers.',
        'category': 'Emergency',
        'isPinned': false,
        'datePosted': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '6',
        'title': 'Fire Safety Reminder',
        'body': 'With the onset of the dry season, the Barangay Fire Station reminds all residents to practice fire safety at all times. Check your gas tank connections regularly for leaks by applying soapy water to the hose and regulator. If bubbles appear, there is a leak. Have faulty electrical wiring inspected by a licensed electrician. Do not overload electrical outlets with multiple appliances. Unplug appliances when not in use. Never leave cooking unattended. Keep matches and lighters away from children. Each household should have a working fire extinguisher and know how to use the PASS method: Pull the pin, Aim at the base of the fire, Squeeze the handle, and Sweep from side to side. For grass fires, call the Barangay Fire Station immediately and do not attempt to put out large fires on your own.',
        'category': 'Emergency',
        'isPinned': true,
        'datePosted': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '7',
        'title': 'Dental Mission',
        'body': 'The Barangay Health Center in partnership with the Philippine Dental Association will hold a Free Dental Mission on June 20, 2024 from 8:00 AM to 4:00 PM at the Barangay Health Center Dental Clinic. Services offered include free tooth extraction, temporary filling, fluoride treatment for children, and dental check-up. The mission is open to children aged six to twelve years old and senior citizens aged sixty years old and above. Only fifty patients will be served on a first come first served basis due to time constraints. Patients for extraction must have eaten breakfast and have no existing fever or cough. Senior citizens with maintenance medicines for high blood pressure are advised to take their medication before coming. Please bring your own towel for the dental chair and a guardian for children under twelve years old.',
        'category': 'Health',
        'isPinned': false,
        'datePosted': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
     {
        'id': '8',
        'title': 'Dengue Prevention Campaign',
        'body': 'The Barangay Health Office announces the Fogging Operation scheduled on June 15, 2024 from 4:00 AM to 8:00 AM in all barangay puroks. This fogging operation aims to kill adult mosquitoes carrying the dengue virus. Residents are advised to cover all water containers, fish ponds, and aquariums. Remove all laundry and food from outside areas. Close all windows and doors during the fogging hours. Keep children and pets inside the house. For residents with asthma or respiratory conditions, they may request exemption from the fogging of their immediate area by informing the barangay health worker in advance. In addition to fogging, residents are reminded to practice the 4S strategy: Search and destroy mosquito breeding sites, Secure self-protection such as using mosquito repellent and wearing long sleeves, Seek early consultation if fever lasts for more than two days, and Support fogging in hotspot areas.',
        'category': 'Health',
        'isPinned': true,
        'datePosted': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
    ];

    for (var announcement in sampleAnnouncements) {
      _box.put(announcement['id'], announcement);
    }
  }

  List<Map<String, dynamic>> _getAnnouncements() {
    final List<Map<String, dynamic>> allAnnouncements = [];
    
    for (var key in _box.keys) {
      final item = _box.get(key);
      if (item != null && item['isDeleted'] == false) {
        allAnnouncements.add(Map<String, dynamic>.from(item));
      }
    }
    
    List<Map<String, dynamic>> filtered = List.from(allAnnouncements);
    if (_selectedCategory != 'All') {
      filtered = filtered.where((a) => a['category'] == _selectedCategory).toList();
    }
    
    filtered.sort((a, b) {
      if (a['isPinned'] != b['isPinned']) {
        return b['isPinned'] ? 1 : -1;
      }
      return DateTime.parse(b['datePosted']).compareTo(DateTime.parse(a['datePosted']));
    });
    
    return filtered;
  }

  void _addAnnouncement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnnouncementFormScreen(),
      ),
    );

    if (result != null) {
      await _box.put(result['id'], result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> announcements = _getAnnouncements();
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final String category = _categories[index];
                final bool isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color.fromARGB(255, 243, 33, 149),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: announcements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCategory == 'All' 
                              ? 'Tap the + button to create one'
                              : 'No announcements in this category',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> announcement = announcements[index];
                      return _buildAnnouncementCard(announcement);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnnouncement,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Row(
          children: [
            if (announcement['isPinned'] == true)
              const Icon(Icons.push_pin, size: 16, color: Colors.orange),
            if (announcement['isPinned'] == true) const SizedBox(width: 4),
            Expanded(
              child: Text(
                announcement['title'].toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              announcement['body'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(announcement['category'].toString()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement['category'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(announcement['datePosted'].toString())),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(
                announcementId: announcement['id'].toString(),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Info':
        return Colors.blue;
      case 'Event':
        return Colors.green;
      case 'Emergency':
        return Colors.red;
      case 'Health':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}