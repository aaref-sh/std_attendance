import 'package:flutter/material.dart';
import 'package:std_attendance/models/session.dart';
import 'package:std_attendance/shared/functions/network_helper.dart';
import 'package:std_attendance/shared/settings.dart';

class SelectSession extends StatefulWidget {
  final bool fromRoot;
  const SelectSession({super.key, this.fromRoot = false});
  @override
  State<SelectSession> createState() => _SelectSessionState();
}

class _SelectSessionState extends State<SelectSession> {
  List<Session> sessions = [];

  Future<List<Session>?> loadSessions() async {
    if (sessions.isNotEmpty) return sessions;

    sessions = await fetchFromServer(
        action: 'GetSessions', fromJson: Session.fromJson);
    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('فشل تحميل البيانات'));
          }
          if (snapshot.hasData) {
            return snapshot.data!.isEmpty
                ? Row(
                    children: [
                      const Text('لا يوجد جلسات'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, 'scan');
                        },
                        child: const Text("المتابعة بدون جلسة"),
                      )
                    ],
                  )
                : Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          session = null;
                          Navigator.pushReplacementNamed(context, 'scan');
                        },
                        child: const Text("المتابعة بدون جلسة"),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var item = snapshot.data![index];
                              return ListTile(
                                title: Text(item.title),
                                trailing: Text(item.branch),
                                onTap: () {
                                  // show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('تأكيد'),
                                      content: const Text(
                                          'هل أنت متأكد من اختيار هذه الجلسة؟'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text('تأكيد'),
                                        ),
                                      ],
                                    ),
                                  ).then((v) {
                                    if (v == true) {
                                      session = snapshot.data![index];
                                      Navigator.pushReplacementNamed(
                                          context, 'scan');
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
