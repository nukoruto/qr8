import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestStoragePermission();
  runApp(MyApp());
}

Future<bool> requestStoragePermission() async {
  // ストレージ権限のステータスを確認
  var status = await Permission.storage.status;

  // 権限が拒否されている場合、リクエストを表示
  if (status.isDenied || status.isRestricted) {
    status = await Permission.storage.request();
  }

  // 権限が許可されている場合は true を返す
  if (status.isGranted) {
    return true;
  }

  // 権限が永続的に拒否されている場合の処理
  if (status.isPermanentlyDenied) {
    // アプリ設定画面を開く
    await openAppSettings();
    return false;
  }

  // 権限が拒否された場合は false を返す
  return false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tenken App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
