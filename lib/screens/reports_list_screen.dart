import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final List<String> _statusFilters = ['All', 'Pending', 'In Progress', 'Resolved'];
  final List<String> _categoryFilters = ['All', 'Road', 'Power', 'Water', 'Safety', 'Other'];
  
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  late Box _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('reports');
    
    _box.watch().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    
    if (_box.isEmpty) {
      _addSampleData();
    }
  }

  void _addSampleData() {
    final List<Map<String, dynamic>> sampleReports = [
      {
        'id': '1',
        'title': 'Broken Traffic Light',
        'description': 'The traffic light at the main intersection of the national highway and barangay road has been completely non-functional for three days now. The intersection is a busy crossing used by students going to the high school, market vendors going to the public market, and vehicles entering the barangay from the highway. Without the traffic light, drivers do not know when to stop or go. There have already been two minor accidents at this intersection in the past three days. During morning and afternoon rush hours, traffic becomes extremely congested with vehicles blocking the intersection. Students are taking risks crossing the highway because there is no pedestrian signal. The traffic light posts are still standing but no lights are showing at all. This is a very dangerous situation that needs immediate attention from the appropriate government agency responsible for traffic lights.',
        'category': 'Road',
        'status': 'Pending',
        'dateReported': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '2',
        'title': 'Unfinished Road Construction',
        'description': 'The road construction project on Santos Street has been left unfinished for the past two weeks. The construction crew dug up the entire stretch of Santos Street to replace old water pipes. However, after completing the pipe replacement, they left without refilling the trenches or repaving the road. Currently, there is a two foot deep open trench running along the entire length of Santos Street for about two hundred meters. Residents cannot drive their cars into their own garages because the trench blocks the driveway. Tricycles and jeepneys cannot enter Santos Street, forcing residents to walk from the main road. The construction site has no warning lights at night, making it very dangerous. Several residents have already tripped and fallen into the trench while walking at night. We request that the contractor be required to complete the work immediately or at least put back the soil and gravel so the road can be used while waiting for full repaving.',
        'category': 'Road',
        'status': 'In Progress',
        'dateReported': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '3',
        'title': 'Fallen Electric Post',
        'description': 'During last night''s heavy storm with strong winds, a wooden electric post fell down on Santos Street. The post is located near the corner of Santos Street and Rizal Avenue. It fell across the road, completely blocking both lanes of traffic. The post is carrying several thick electrical wires and cable television wires. Some wires appear to be broken and hanging low near the ground. This is a very dangerous situation because the wires may still be live with electricity. Residents have been warned not to go near the fallen post and to stay inside their homes. However, this means residents cannot leave or enter Santos Street using vehicles. Students cannot go to school. Workers cannot go to their jobs. Delivery trucks cannot enter. The electric post needs to be replaced and the wires need to be properly reattached or replaced. We request that the electric company respond to this emergency immediately.',
        'category': 'Power',
        'status': 'Resolved',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '4',
        'title': 'Sparking Transformer',
        'description': 'The electrical transformer mounted on the electric post at the corner of Luna Street and Mabini Street has been making unusual loud buzzing noises for three days. Yesterday and today, residents have seen sparks coming from the transformer, especially when it rains or when it is very hot outside. The sparks appear as small blue flashes and are accompanied by popping sounds. The transformer also smells like something is burning or melting inside. The ground underneath the post sometimes feels warm. This is a serious fire hazard and safety risk for residents living nearby. There are several houses within ten meters of this transformer. If the transformer catches fire, it could cause a fire that spreads to nearby homes or cause a serious electrical accident. We request that the electric company send a crew to inspect this transformer immediately, before it causes a fire or a complete failure that would cause a power outage.',
        'category': 'Power',
        'status': 'Pending',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '5',
        'title': 'No Water Supply for Three Days',
        'description': 'Residents of Phase 2 have had absolutely no water coming out of their faucets for the past three days. The water supply completely stopped on Monday morning and has not returned as of today. There is zero water pressure at all times of day and night, not even a small trickle. The affected area includes approximately fifty households. Residents have been forced to buy bottled water for drinking and cooking. For bathing, washing dishes, and flushing toilets, residents have been using water fetched from a neighbor''s deep well which is located one kilometer away. The elderly and persons with disabilities are struggling to carry heavy buckets of water from the well to their homes. Several families have left their homes to stay with relatives in other barangays because it is impossible to live without running water. The barangay water district office has been contacted multiple times but no crew has been sent to investigate the problem. We request emergency water delivery and immediate repair of whatever is causing this total loss of water supply.',
        'category': 'Water',
        'status': 'In Progress',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '6',
        'title': 'Leaking Water Pipe',
        'description': 'A water pipe burst on Rizal Street near the intersection with Jose Street. This happened two days ago but has not been repaired yet. The burst pipe is located underground but the water is forcing its way up through the road surface, creating a fountain of water approximately one foot high. The water has been flowing continuously for forty eight hours, creating a small river that runs down the street and into the drainage canal. This is a huge waste of precious treated water. The area around the leak has become muddy and slippery, causing one elderly resident to slip and fall yesterday. The water flow is strong enough that it is eroding the soil under the road, which may cause the road surface to collapse in the future. The water district was notified immediately when the burst first happened, but no repair crew has arrived. We request that a repair crew be sent to fix this leak today to stop the water wastage and prevent further damage.',
        'category': 'Water',
        'status': 'Resolved',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
     {
        'id': '7',
        'title': 'Suspicious Persons Loitering at Night',
        'description': 'Residents of Purok Three have reported seeing suspicious persons loitering near their houses between midnight and dawn for the past several nights. The suspicious persons are described as two young men wearing hoodies and dark clothing. They walk slowly past houses, stop and look at windows and doors, and then move to the next house. They do not appear to be residents of this area because no one recognizes them. Last night, one resident saw these men attempting to open the gate of a house where the family is away on vacation. The resident yelled at them and they ran away. The homeowner was contacted and confirmed that no one was supposed to be at their house. The police were notified but the men were not found. Residents are afraid to sleep at night. We request that the barangay increase nighttime patrols in this area and consider installing additional street lights and security cameras.',
        'category': 'Safety',
        'status': 'Pending',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '8',
        'title': 'Dark and Unsafe Alleyways',
        'description': 'The alleyways located behind the Barangay Hall are completely dark at night because there are no working street lights installed in this area. These alleyways are used by residents as shortcuts to reach the main road. Many women use these alleyways when walking home from work or from the market. However, because the alleyways are so dark, women feel unsafe walking alone. There have been reports of men hiding in the dark corners and making catcalls at women passing by. Last week, a woman was followed by a man through the alleyway until she started running. The police were called but the man could not be identified because it was too dark. There are many residents living in the area behind the barangay hall including several families with children. We request that the barangay install street lights in these alleyways immediately to improve safety for all residents, especially women and children who walk through this area.',
        'category': 'Safety',
        'status': 'In Progress',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '9',
        'title': 'Garbage Not Collected for Two Weeks',
        'description': 'The garbage truck has not passed through our area to collect trash for the past two weeks. The normal collection schedule is every Monday and Thursday at 7:00 AM. However, for the past two Mondays and two Thursdays, no garbage truck has arrived. Residents have continued to put their trash bags outside on the scheduled days, but the bags remain uncollected. Now the street corners are piled high with dozens of trash bags. The bags are breaking open and garbage is spilling onto the street. There is a terrible smell of rotting food waste. Rats and cockroaches have increased in the area. Stray dogs and cats are tearing open the bags and scattering garbage everywhere. Residents are afraid that this situation will cause a disease outbreak. We have called the garbage collection contractor many times but they give excuses about broken trucks. We request that the barangay intervene with the contractor or find an alternative solution for garbage collection immediately.',
        'category': 'Other',
        'status': 'Resolved',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '10',
        'title': 'Business Operating Without Barangay Permit',
        'description': 'A new sari-sari store opened last month at House Number 8 on Santos Street. The store sells not only typical sari-sari store items but also cigarettes, alcoholic beverages, and even prepaid load cards for mobile phones. However, the store owner has not applied for or received a barangay business permit. The store has no permit displayed on its wall as required by barangay ordinance. The store also does not have a sanitary permit from the health office. The store operates from 6:00 AM to 11:00 PM, even on Sundays. The neighbors have complained that the store attracts customers who loiter outside, smoke cigarettes, and leave their empty bottles and cigarette butts on the street. When asked about the permit, the store owner said she does not need one because the store is small. This is incorrect because all businesses, regardless of size, need a barangay permit to operate. We request that the barangay investigate and require the store owner to obtain the proper permits or close the store.',
        'category': 'Other',
        'status': 'Pending',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
    ];

    for (var report in sampleReports) {
      _box.put(report['id'], report);
    }
  }

  List<Map<String, dynamic>> _getReports() {
    final List<Map<String, dynamic>> allReports = [];
    
    for (var key in _box.keys) {
      final item = _box.get(key);
      if (item != null && item['isDeleted'] == false) {
        allReports.add(Map<String, dynamic>.from(item));
      }
    }
    
    List<Map<String, dynamic>> filtered = List.from(allReports);
    if (_selectedStatus != 'All') {
      filtered = filtered.where((r) => r['status'] == _selectedStatus).toList();
    }
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((r) => r['category'] == _selectedCategory).toList();
    }
    
    filtered.sort((a, b) {
      return DateTime.parse(b['dateReported']).compareTo(DateTime.parse(a['dateReported']));
    });
    
    return filtered;
  }

  void _addReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportFormScreen(),
      ),
    );

    if (result != null) {
      await _box.put(result['id'], result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reports = _getReports();
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final String status = _statusFilters[index];
                      final bool isSelected = _selectedStatus == status;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: _getStatusColor(status),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Category:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _categoryFilters.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          Expanded(
            child: reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report_problem,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to submit a report',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> report = reports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReport,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          report['title'].toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report['description'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report['status'].toString()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['status'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['category'].toString(),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(report['dateReported'].toString())),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(
                reportId: report['id'].toString(),
              ),
            ),
          );
          setState(() {});
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}