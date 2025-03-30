import 'package:flutter/material.dart';

class Etp extends StatefulWidget {
  const Etp({super.key});

  @override
  State<Etp> createState() => _EtpState();
}

class _EtpState extends State<Etp> {
  final List<String> _plantNames = ['PLANT 1', 'PLANT 2', 'PLANT 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Name')),
      body: ListView.builder(
        itemCount: _plantNames.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(_plantNames[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetails(plantName: _plantNames[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PlantDetails extends StatelessWidget {
  final String plantName;

  const PlantDetails({super.key, required this.plantName});

  // Mimicking backend data as a static list
  static final List<Map<String, String>> _plantData = [
    {
      'name': 'PLANT 1',
      'description': 'NO ',
    },
    {
      'name': 'PLANT 2',
      'description': 'Plant 2 thrives in bright light and needs watering every few days.',
    },
    {
      'name': 'PLANT 3',
      'description': 'Plant 3 is a beautiful flowering plant, perfect for home decoration.',
    },
  ];

  // Function to fetch plant details from the list
  Map<String, String>? _getPlantData(String name) {
    return _plantData.firstWhere((plant) => plant['name'] == name, orElse: () => {});
  }

  @override
  Widget build(BuildContext context) {
    final plantData = _getPlantData(plantName);

    if (plantData!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(plantName)),
        body: const Center(child: Text('No details found for this plant')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(plantData['name']!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           // Image.network(plantData['image']!),
            const SizedBox(height: 10),
            Text(
              plantData['name']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              plantData['description']!,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
