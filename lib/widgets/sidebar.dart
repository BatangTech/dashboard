import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/patient_screen.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int? _selectedIndex;
  int? _hoveredIndex; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    setState(() {
      if (currentRoute == DashboardScreen.routeName) {
        _selectedIndex = 0;
      } else if (currentRoute == '/monitor') {
        _selectedIndex = 1;
      } else if (currentRoute == PatientScreen.routeName) {
        _selectedIndex = 2;
      } else if (currentRoute == '/logout') {
        _selectedIndex = 3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, 
      height: MediaQuery.of(context).size.height, 
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10), 
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ ปรับ padding ให้น้อยลง
         Container(
            alignment: Alignment.centerLeft, // ✅ เปลี่ยนให้ชิดซ้าย
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 16), // ✅ เพิ่ม padding ซ้าย
            child: Text(
              "ADMIN NCDs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 8, 64, 110),
              ),
              textAlign: TextAlign.left, // ✅ เปลี่ยนเป็นชิดซ้าย
            ),
          ),

          // ✅ รายการเมนู Sidebar
          _buildSidebarItem(0, Icons.dashboard, "Dashboard", DashboardScreen.routeName),
          _buildSidebarItem(1, Icons.monitor_heart, "Monitor", '/monitor'),
          _buildSidebarItem(2, Icons.person, "Patient", PatientScreen.routeName),
          _buildSidebarItem(3, Icons.logout_rounded, "Sign Out", '/logout'),
        ], 
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title, String? routeName) {
    bool isSelected = _selectedIndex == index;
    bool isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: InkWell(
        onTap: () {
          if (routeName != null) {
            setState(() => _selectedIndex = index);
            _navigateToPage(routeName);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.indigo[50]
                : isHovered
                    ? Colors.indigo.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.indigo : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.indigo : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }
}
