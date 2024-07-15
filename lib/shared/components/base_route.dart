import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:std_attendance/shared/settings.dart';

class BaseRoute extends StatefulWidget {
  const BaseRoute(
      {super.key, this.routeName = '', required this.body, this.icon});
  final String routeName;
  final Widget body;
  final IconData? icon;
  @override
  State<BaseRoute> createState() => _BaseRouteState();
}

class _BaseRouteState extends State<BaseRoute> {
  @override
  void initState() {
    super.initState();
    if (deviceId.isEmpty) {
      const AndroidId().getId().then((v) => setState(() => deviceId = v ?? ''));
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: deviceId)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('تم النسخ!'))),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.routeName.isEmpty
          ? null
          : AppBar(
              title: Text(widget.routeName),
              actions: [
                Text(deviceId, style: const TextStyle(fontSize: 12)),
                IconButton(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy_outlined))
              ],
            ),
      body: Stack(
        children: [
          if (widget.icon != null)
            const Center(
                child: Opacity(
                    opacity: 0.1,
                    child: Image(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.fill,
                    ))),
          widget.body,
        ],
      ),
    );
  }
}
