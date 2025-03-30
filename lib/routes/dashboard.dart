import 'package:flutter/material.dart';
import 'package:waterplant/routes/contacts.dart';
import 'package:waterplant/routes/etp.dart';
import 'package:waterplant/routes/stp.dart';
import 'package:waterplant/routes/wtp.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
            drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9),
              ),
              child: Text(
                'NAME SURNAME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
             ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
                ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Contacts'),
              onTap: () => _navigateTo(context, const TeamPage()),

            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Terms and Conditions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
            body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              title: 'ETP',
              color: const Color(0xFFFFD1DC), // Pastel Pink
             // icon: Icons.notification_important,
              onTap: () => _navigateTo(context, const Etp()),
            ),
            _buildDashboardCard(
              title: 'STP',
              color: const Color(0xFFB3E5FC), // Pastel Blue
           //   icon: Icons.location_on,
              onTap: () => _navigateTo(context, const Stp()),
            ),
            _buildDashboardCard(
              title: 'WTP',
              color: const Color(0xFFFFF9C4), // Pastel Yellow
            //  icon: Icons.sensors,
              onTap: () => _navigateTo(context, const Wtp()),
            ),
            
          ],
        ),
      ),

    );
  }




  Widget _buildDashboardCard({
    required String title,
    required Color color,
    //required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          //  Icon(icon, size: 48, color: Colors.black87),
           // const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
