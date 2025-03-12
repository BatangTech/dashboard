import 'package:flutter/material.dart';
import '../widgets/dashboard_widgets/age_chart.dart';
import '../widgets/dashboard_widgets/caution_info_card.dart';
import '../widgets/dashboard_widgets/ncds_chart.dart';
import '../widgets/dashboard_widgets/patient_list.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = "/dashboard"; // ✅ กำหนด routeName
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(), // ✅ ไม่มี Padding รอบ Sidebar แล้ว
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10, left: 16, right: 16), // ✅ เว้นขอบเฉพาะด้านซ้ายของเนื้อหา
              child: CustomScrollView(
                slivers: [
                  // ✅ ใช้ SliverPadding กับ Header
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: 20),
                    sliver: SliverToBoxAdapter(
                      child: Header(),
                    ),
                  ),
                  // ✅ ใช้ SliverGrid แทน GridView
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildListDelegate([
                        CautionInfoCard(),
                        NCDsChart(),
                        PatientList(),
                        AgeChart(),
                       
                      ]),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.5,
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
}
