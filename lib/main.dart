import 'package:dashboard_2/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patient_screen.dart';
import 'screens/monitor_screen.dart';  // ✅ นำเข้า MonitorScreen
import 'styles/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAWITsvGyYGmkIJ_u8slYYX7cyz2Yq2emg",
        authDomain: "dashboard-1b93e.firebaseapp.com",
        projectId: "dashboard-1b93e",
        storageBucket: "dashboard-1b93e.firebasestorage.app",
        messagingSenderId: "445766836629",
        appId: "1:445766836629:web:821522b81c14204a7d169c",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // ✅ หน้าเริ่มต้น
      routes: {
        '/login':(context)=>LoginPage(),
        '/dashboard': (context) => DashboardScreen(),
        '/patient': (context) => PatientScreen(),
        '/monitor': (context) => MonitorScreen(),  // ✅ เพิ่มหน้า Monitor
        '/logout': (context) => LoginPage(),  // ✅ เพิ่มหน้า Monitor
      },
    );
  }
}
