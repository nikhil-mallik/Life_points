import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/activity.dart';
import '../../providers/activity_provider.dart';

class AddActivityScreen extends StatefulWidget {
  final ActivityType activityType;
  
  const AddActivityScreen({
    Key? key,
    required this.activityType,
  }) : super(key: key);

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }
  
  void _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final points = int.parse(_pointsController.text.trim());
    
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description.isNotEmpty ? description : null,
      points: points,
      type: widget.activityType,
      createdAt: DateTime.now(),
    );
    
    await Provider.of<ActivityProvider>(context, listen: false)
        .addActivity(activity);
    
    if (!mounted) return;
    
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    String title;
    Color appBarColor;
    bool isPositive;
    
    switch (widget.activityType) {
      case ActivityType.positive:
      case ActivityType.daily:
      case ActivityType.weekly:
      case ActivityType.custom:
        title = 'Add Positive Activity';
        appBarColor = Colors.green;
        isPositive = true;
        break;
      case ActivityType.negative:
      case ActivityType.spend:
        title = 'Add Reward';
        appBarColor = Colors.red;
        isPositive = false;
        break;
      case ActivityType.earn:
      default:
        title = 'Add Activity';
        appBarColor = Colors.blue;
        isPositive = true;
        break;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appBarColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: isPositive ? 'Activity Name' : 'Reward Name',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _pointsController,
              decoration: InputDecoration(
                labelText: isPositive ? 'Points to Earn' : 'Points to Spend',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter points';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _saveActivity,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: isPositive ? Colors.green : Colors.blue,
              ),
              child: Text(
                isPositive ? 'Add Activity' : 'Add Reward',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (isPositive) ...[
              const SizedBox(height: 32.0),
              Text(
                'Suggested Activities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              _buildSuggestedActivities(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestedActivities() {
    // These would come from the user's selected goal in a real app
    final suggestedActivities = [
      'Complete 30 minutes of focused study',
      'Take a 20-minute walk',
      'Drink 8 glasses of water',
      'Read for 15 minutes',
      'Meditate for 10 minutes',
      'Do 20 push-ups',
    ];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestedActivities.length,
      itemBuilder: (context, index) {
        final activity = suggestedActivities[index];
        
        return Card(
          child: ListTile(
            title: Text(activity),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                _nameController.text = activity;
                _pointsController.text = '10'; // Default points
                
                // Scroll to top to show the form
                Scrollable.ensureVisible(
                  _formKey.currentContext!,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
          ),
        );
      },
    );
  }
}