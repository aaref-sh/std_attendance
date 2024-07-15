import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:std_attendance/models/login.dart';
import 'package:std_attendance/models/user.dart';
import 'package:std_attendance/shared/settings.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, this.fromHome = false});
  final bool fromHome;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _loadingMessage = 'يتم التحقق من الجهاز';

  @override
  void initState() {
    if (user != null) {
      Navigator.pop(context, user);
    }
    super.initState();
    _validateDevice();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: deviceId)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text('تم النسخ!'))));
    });
  }

  Future<void> _validateDevice() async {
    if (deviceId.isEmpty) deviceId = await const AndroidId().getId() ?? '';

    var dio = Dio();
    try {
      final response = await dio.post(
        options: Options(headers: {'content-type': "application/json"}),
        '$host/Login',
        data: LoginModel(clientVersion: version, deviceId: deviceId),
      );
      if (response.statusCode == 200) {
        user = User.fromJson(response.data);
        if (mounted) {
          if (widget.fromHome) {

            Navigator.pushReplacementNamed(context, 'selectsession',arguments: true);
          } else {
            Navigator.pop(context, user);
          }
        }
      }
    } on DioException catch (e) {
      if ([406, 403].contains(e.response?.statusCode)) {
        setState(() => _loadingMessage = 'الجهاز غير مصرح');
      } else {
        Navigator.pushReplacementNamed(context, 'scan');
      }
    } catch (e) {
      setState(() => _loadingMessage = 'حدث خطأ ما');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if ([
            "تحميل معرف الجهاز ...",
            'يتم التحقق من الجهاز'
          ].contains(_loadingMessage)) ...[const CircularProgressIndicator()],
          const SizedBox(height: 24),
          Text(_loadingMessage),
          if (['الجهاز غير مصرح', 'فشل التحقق من الجهاز']
              .contains(_loadingMessage)) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(deviceId),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyToClipboard,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, 'scan'),
                child: const Text('العمل بدون اتصال'))
          ],
        ],
      ),
    );
  }
}
