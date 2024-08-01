import 'package:flutter/material.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final List<WorkoutDay> workoutDays = [];

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

  void _addNewDay() {
    setState(() {
      workoutDays.add(WorkoutDay(date: DateTime.now(), exercises: []));
    });
  }

  void _deleteWorkoutDay(int index) {
    setState(() {
      workoutDays.removeAt(index);
    });
  }
}

class WorkoutDay {
  final DateTime date;
  final List<Exercise> exercises;

  WorkoutDay({required this.date, required this.exercises});
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
                  setState(() {
                    widget.workoutDay.exercises.add(
                      Exercise(
                        name: name,
                        sets: sets,
                        reps: reps,
                        weight: weight,
                      ),
                    );
                  });
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
