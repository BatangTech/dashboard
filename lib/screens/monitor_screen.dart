import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/sidebar.dart';

class MonitorScreen extends StatefulWidget {
  @override
  _MonitorScreenState createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  void _showQuestionDialog(BuildContext context, String patientName, String status) {
    List<String> questions = List.filled(5, "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create a Question for $patientName"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return TextFormField(
                  decoration: InputDecoration(
                    labelText: "Question ${index + 1}",
                    hintText: "Enter question ${index + 1}",
                  ),
                  onChanged: (value) {
                    questions[index] = value;
                  },
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('questions')
                    .doc(patientName)
                    .collection(status)
                    .add({
                  'questions': questions,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                print("Questions for $patientName ($status): $questions");
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleDialog(BuildContext context, String patientName) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int numberOfTimes = 1;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Schedule Appointment for $patientName"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // เลือกวันที่
                  ListTile(
                    title: Text("Select Date"),
                    subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),

                  // เลือกเวลา
                  ListTile(
                    title: Text("Select Time"),
                    subtitle: Text("${selectedTime.format(context)}"),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                  ),

                  // กำหนดจำนวนครั้ง
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Number of Times",
                      hintText: "Enter the number of times",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        numberOfTimes = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .add({
                    'patientName': patientName,
                    'date': selectedDate,
                    'time': selectedTime.format(context),
                    'numberOfTimes': numberOfTimes,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  print("Appointment scheduled for $patientName on $selectedDate at ${selectedTime.format(context)}");
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Search by name",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      children: [
                        _buildPatientListPage("Critical"),
                        _buildPatientListPage("Stable"),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 2,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientListPage(String statusFilter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient List - $statusFilter",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 8, 64, 110),
              ),
            ),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 8, 64, 110)))),
                Expanded(flex: 1, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 8, 64, 110)))),
                Expanded(flex: 2, child: Text("Date and Time", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 8, 64, 110)))),
              ],
            ),
            Divider(),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('patients').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Error loading patient data");
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text("No patients available");
                  }

                  var patients = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      var doc = patients[index];

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('patients')
                            .doc(doc.id)
                            .collection('personal')
                            .snapshots(),
                        builder: (context, personalSnapshot) {
                          if (personalSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (personalSnapshot.hasError) {
                            return Text("Error loading personal data");
                          }
                          if (!personalSnapshot.hasData || personalSnapshot.data!.docs.isEmpty) {
                            return SizedBox();
                          }

                          var personalData = personalSnapshot.data!.docs
                              .map((doc) => doc.data() as Map<String, dynamic>)
                              .where((data) =>
                                  data['status'] == statusFilter &&
                                  (searchQuery.isEmpty || data['name'].toLowerCase().contains(searchQuery.toLowerCase())))
                              .toList();

                          if (personalData.isEmpty) {
                            return Center(child: Text("No $statusFilter patients available"));
                          }

                          return Column(
                            children: personalData.map((data) {
                              return Container(
                                width: double.infinity,
                                height: 40,
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(flex: 2, child: Text(data['name'] ?? 'Unknown')),

                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Icon(
                                            data['status'] == "Stable" ? Icons.check_circle : Icons.cancel,
                                            color: data['status'] == "Stable" ? Colors.green : Colors.red,
                                          ),
                                          SizedBox(width: 5),
                                          Text(data['status'] ?? 'No status'),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data['date']?.toDate().toString() ?? 'No date',
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          SizedBox(width: 20),

                                          Tooltip(
                                            message: "Schedule Appointment",
                                            child: IconButton(
                                              icon: Icon(Icons.schedule, color: Colors.indigo),
                                              onPressed: () {
                                                _showScheduleDialog(context, data['name']);
                                              },
                                            ),
                                          ),

                                          Tooltip(
                                            message: "Create a Question",
                                            child: IconButton(
                                              icon: Icon(Icons.question_mark, color: Colors.indigo),
                                              onPressed: () {
                                                _showQuestionDialog(context, data['name'], data['status']);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
