import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final List<WorkoutDay> workoutDays = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('workouts').get();
    setState(() {
      workoutDays.clear();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        WorkoutDay workoutDay = WorkoutDay.fromMap(data);
        workoutDay.id = doc.id;
        workoutDays.add(workoutDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout Tracking",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: workoutDays.isEmpty
          ? const PlaceholderWidget()
          : ListView.builder(
              itemCount: workoutDays.length,
              itemBuilder: (context, index) {
                return WorkoutDayCard(
                  workoutDay: workoutDays[index],
                  onDelete: () => _deleteWorkoutDay(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDay,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewDay() async {
    WorkoutDay newWorkoutDay = WorkoutDay(date: DateTime.now(), exercises: []);
    DocumentReference docRef = await _firestore.collection('workouts').add(newWorkoutDay.toMap());
    newWorkoutDay.id = docRef.id;
    setState(() {
      workoutDays.add(newWorkoutDay);
    });
  }

  void _deleteWorkoutDay(int index) async {
    await _firestore.collection('workouts').doc(workoutDays[index].id).delete();
    setState(() {
      workoutDays.removeAt(index);
    });
  }
}

class WorkoutDay {
  String? id;
  final DateTime date;
  final List<Exercise> exercises;

  WorkoutDay({this.id, required this.date, required this.exercises});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  static WorkoutDay fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      date: DateTime.parse(map['date']),
      exercises: (map['exercises'] as List).map((e) => Exercise.fromMap(e)).toList(),
    );
  }
}

class Exercise {
  String name;
  int sets;
  int reps;
  double weight;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
    );
  }
}

class WorkoutDayCard extends StatefulWidget {
  final WorkoutDay workoutDay;
  final VoidCallback onDelete;

  const WorkoutDayCard({
    super.key,
    required this.workoutDay,
    required this.onDelete,
  });

  @override
  State<WorkoutDayCard> createState() => _WorkoutDayCardState();
}

class _WorkoutDayCardState extends State<WorkoutDayCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.workoutDay.date.toString().split(' ')[0],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.workoutDay.exercises.length,
            itemBuilder: (context, index) {
              return ExerciseItem(
                exercise: widget.workoutDay.exercises[index],
                onDelete: () => _deleteExercise(index),
              );
            },
          ),
          ElevatedButton(
            onPressed: _addNewExercise,
            child: const Text('Add Exercise'),
          ),
        ],
      ),
    );
  }

  void _addNewExercise() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        int sets = 0;
        int reps = 0;
        double weight = 0.0;

        return AlertDialog(
          title: const Text('Add New Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Exercise Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                onChanged: (value) => weight = double.tryParse(value) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Number of Reps'),
                keyboardType: TextInputType.number,
                onChanged: (value) => reps = int.tryParse(value) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Number of Sets'),
                keyboardType: TextInputType.number,
                onChanged: (value) => sets = int.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (name.isNotEmpty && sets > 0 && reps > 0) {
                  Exercise newExercise = Exercise(
                    name: name,
                    sets: sets,
                    reps: reps,
                    weight: weight,
                  );
                  setState(() {
                    widget.workoutDay.exercises.add(newExercise);
                  });
                  _updateWorkoutInFirestore();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise(int index) {
    setState(() {
      widget.workoutDay.exercises.removeAt(index);
    });
    _updateWorkoutInFirestore();
  }

  void _updateWorkoutInFirestore() {
    _firestore
        .collection('workouts')
        .doc(widget.workoutDay.id)
        .update(widget.workoutDay.toMap());
  }
}

class ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onDelete;

  const ExerciseItem({
    super.key,
    required this.exercise,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercise.name),
      subtitle: Text(
        '${exercise.weight} lbs x ${exercise.reps} reps x ${exercise.sets} sets',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Click the plus button below to start tracking!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}