import 'package:cmp_handbook/pages/variables.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../api/api_services.dart';

class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key});

  @override
  _ViewComplaintsState createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  late Future<List<dynamic>> _complaintsFuture;

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _complaintsFuture = apiService.fetchComplaints();
  }

  void _showToast(String message, ToastificationType type) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
      style: ToastificationStyle.fillColored,
      backgroundColor: Colors.green,
      primaryColor: Colors.green,
      type: type,
      alignment: Alignment.bottomCenter,
    );
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complaint Details', style: TextStyle(fontSize: 18),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User ID: ${complaint['user_id']}'),
              const SizedBox(height: 8),
              Text('Complaint: ${complaint['complaint_text']}'),
              const SizedBox(height: 8),
              Text('Status: ${complaint['status']}'),
              const SizedBox(height: 8),
              Text('Created At: ${DateTime.parse(complaint['created_at']).toLocal().toString().split(' ')[0]}'),
              // const SizedBox(height: 8),
              // Text('Updated At: ${DateTime.parse(complaint['updated_at']).toLocal()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.green),
            ),
            const Text(
              'ADMIN - View Complaints',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }

          final complaints = snapshot.data!;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return GestureDetector(
                onTap: () => _showComplaintDetails(context, complaint),
                child: Card(
                  color: colorGreen,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint['complaint_text'],
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${complaint['status']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Date: ${DateTime.parse(complaint['created_at']).toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
