import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:std_attendance/models/session.dart';
import 'package:std_attendance/models/uploaded_exam.dart';
import 'package:std_attendance/models/user.dart';
import 'package:std_attendance/routes/login.dart';
import 'package:std_attendance/routes/select_session.dart';
import 'package:std_attendance/shared/components/scan_line.dart';
import 'package:std_attendance/shared/functions/network_helper.dart';
import 'package:std_attendance/shared/functions/shared_preference.dart';
import 'package:std_attendance/shared/settings.dart';
import 'package:intl/intl.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

DateFormat format = DateFormat("yyyy/MM/dd");

class _ScanState extends State<Scan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  late QRViewController controller;
  int lastScan = 0;
  bool scanning = true;
  int syncd = 0;
  int sync = 0;
  String message = '';

  var sessionResult = <String>[];

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller.pauseCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (DateTime.now().millisecondsSinceEpoch - lastScan < 1500) return;
      lastScan = DateTime.now().millisecondsSinceEpoch;

      await pauseCamera();
      await beep();

      var trimmed = scanData.code?.trim() ?? '';
      if (trimmed.length >= 4 && int.tryParse(trimmed) != null) {
        var isOnline = await checkInternetConnection();
        if (isOnline && session != null) {
          var obj = ApiCheckInModel(studentId: trimmed, sessionId: session!.id);
          try {
            var resoponse = await sendPost(obj, action: 'CheckIn');
            var std = Student.fromJson(resoponse.data);
            message = '$trimmed - تم تسجيل حضور ${std.fullName}';
          } on DioException catch (e) {
            message = "$trimmed - ${e.response?.data.toString()}";
          }
        } else {
          setState(() => ids.add(trimmed));
          await setValue('ids', ids.toList());
          message = trimmed;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('تم إضافة $trimmed')));
        }
        setState(() {
          if (message.isNotEmpty) sessionResult.add(message);
        });
      }
    });
  }

  Future<void> pauseCamera() async {
    await controller.pauseCamera();
    scanning = false;
  }

  Future<void> beep() async {
    await FlutterBeep.playSysSound(13);
    await Future.delayed(const Duration(milliseconds: 100));
    await FlutterBeep.beep();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  HashSet<String> ids = HashSet<String>();
  String date = format.format(DateTime.now());
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    initSharedPreferences().then((v) {
      setState(() {
        (getValue('ids') as List<Object?>?)
            ?.forEach((x) => x == null ? "" : ids.add(x.toString()));
        date = getValue('date') as String? ?? format.format(DateTime.now());

        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return !loaded
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('يتم تحميل العناصر'),
              ],
            ),
          )
        : Center(
            child: Column(
              children: [
                session == null
                    ? Row(
                        children: [
                          const Text('وضع العمل بدون اتصال'),
                          TextButton(
                              onPressed: () => user == null
                                  ? Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const LoadingScreen(
                                                  fromHome: true)))
                                  : Navigator.pushReplacementNamed(
                                      context, "selectsession"),
                              child: const Text("اتصل مجددا")),
                        ],
                      )
                    : Row(
                        children: [
                          Text('الجلسة الحالية: ${session?.title ?? ''}'),
                          TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, 'selectsession'),
                              child: const Text("تغيير"))
                        ],
                      ),
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        formatsAllowed: const [BarcodeFormat.code39],
                        overlay: QrScannerOverlayShape(
                          borderColor: Colors.red,
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 250,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                          width: MediaQuery.sizeOf(context).width / 2,
                          margin: const EdgeInsets.only(top: 100),
                          child: const ColorChangingLine()),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                          onPressed: () async => await controller.toggleFlash(),
                          icon:
                              const Icon(Icons.flash_on, color: Colors.white)),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: IconButton(
                          onPressed: tougleCamera,
                          icon: Icon(
                            scanning
                                ? Icons.pause_outlined
                                : Icons.play_arrow_outlined,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("عدد العناصر: ${ids.length + sessionResult.length}"),
                      Text('التاريخ: $date'),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                bool erase = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text('تأكيد'),
                                          content: const Text(
                                              'سيتم مسح كافة البيانات الحالية'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("إلغاء")),
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text("موافق")),
                                          ],
                                        ));
                                if (erase) {
                                  await reset();
                                }
                              },
                              tooltip: "جلسة جديدة",
                              icon: const Icon(Icons.description_outlined)),
                          IconButton(
                              tooltip: "عرض",
                              onPressed: () {
                                // view sessionResult items in a listview inside popup
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('نتائج الجلسة'),
                                    content: ListView.builder(
                                      itemCount: sessionResult.length,
                                      itemBuilder: (context, index) {
                                        return Text(
                                            sessionResult[index].toString());
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('تم'))
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_red_eye_outlined)),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("عناصر المزامنة: $sync"),
                      Text('تم تسجيلها: $syncd'),
                      IconButton(
                        tooltip: 'مزامنة',
                        onPressed: () async {
                          if (ids.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('لا يوجد عناصر للمزامنة')));
                            return;
                          }

                          await loadUser(context);
                          await selectSession(context);
                          setState(() {});
                          if (session != null) {
                            var sessionId = session!.id;
                            var model =
                                SessionStudents(sessionId, ids.toList());
                            try {
                              // show loading dialog
                              showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                    content: Center(
                                        child: CircularProgressIndicator())),
                              );
                              sync = ids.length;
                              var x =
                                  await sendPost(model, action: 'BulkCheckIn');
                              // hide loading dialog
                              Navigator.pop(context);
                              var res = UploadedExam.fromJson(x.data);
                              setState(() {
                                syncd = res.students
                                    .where((s) => s.status == 'حضور')
                                    .length;
                              });
                              // showDialog
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    var succeeded = res.students
                                        .where((x) => x.status == "حضور")
                                        .toList();

                                    var failed = res.students
                                        .where((x) => x.status != "حضور")
                                        .toList();
                                    sessionResult.addAll(succeeded.map((e) =>
                                        "${e.studentId} - تم تسجيل حضور الطالب ${e.fullName}"));
                                    sessionResult
                                        .addAll(failed.map((e) => e.status));
                                    if (failed.isEmpty) reset();

                                    return AlertDialog(
                                      title: const Text('نجاح المزامنة'),
                                      icon: const Icon(Icons.check),
                                      content: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: succeeded.length,
                                                itemBuilder:
                                                    (itemBuilder, index) {
                                                  var s = succeeded[index];
                                                  return Row(
                                                    children: [
                                                      Text(s.fullName),
                                                      const SizedBox(width: 8),
                                                      Text(s.father),
                                                    ],
                                                  );
                                                }),
                                          ),
                                          SizedBox(
                                            height: 200,
                                            child: ListView.builder(
                                                itemCount: failed.length,
                                                itemBuilder: (itemBuilder,
                                                        index) =>
                                                    Text(failed[index].status)),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('تم'))
                                      ],
                                    );
                                  });
                            } on DioException catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('فشل المزامنة')));
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("فشل"),
                                      content: Text(
                                          e.response?.data.toString() ??
                                              'فشل المزامنة'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('إغلاق'))
                                      ],
                                    );
                                  });
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('فشل المزامنة')));
                            }
                          }
                        },
                        icon: const Icon(Icons.sync_outlined),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(message),
                ),
              ],
            ),
          );
  }

  Future<void> reset() async {
    ids.clear();
    date = format.format(DateTime.now());
    sync = syncd = 0;
    await setValue('ids', <String>[]);
    await setValue('date', date);
    setState(() {});
  }

  Future<void> selectSession(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => const AlertDialog(content: SelectSession()));
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('فشل تحديد العنصر او الحصول على البيانات')));
    }
  }

  Future<void> loadUser(BuildContext context) async {
    user = (await showDialog(
            context: context,
            builder: (context) => const AlertDialog(content: LoadingScreen())))
        as User;
  }

  void tougleCamera() async {
    scanning ? await controller.pauseCamera() : await controller.resumeCamera();
    setState(() {
      scanning = !scanning;
    });
  }
}
