import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textContrroller = TextEditingController();

  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  void checkHabit(bool? isCompleted, Habit habit) {
    if (isCompleted != null) {
      context.read<HabitDatabase>().updateHabitCompletion(
        habit.id,
        isCompleted,
      );
    }
  }

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Habit'),
        content: TextField(controller: textContrroller),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textContrroller.clear();
            },
            child: Text('Cancel'),
          ),

          MaterialButton(
            onPressed: () {
              final newHabit = textContrroller.text;
              context.read<HabitDatabase>().addHabit(newHabit);

              Navigator.pop(context);
              textContrroller.clear();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  bool isHabitCompletedToday(List<DateTime> completedDays) {
    final today = DateTime.now();
    return completedDays.any(
      (date) =>
          date.day == today.day &&
          date.month == today.month &&
          date.year == today.year,
    );
  }

  void editHabit(Habit habit) {
    textContrroller.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Habit'),
        content: TextField(controller: textContrroller),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textContrroller.clear();
            },
            child: Text('Cancel'),
          ),

          MaterialButton(
            onPressed: () {
              final newHabit = textContrroller.text;
              context.read<HabitDatabase>().updateHabitName(habit.id, newHabit);

              Navigator.pop(context);
              textContrroller.clear();
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  void deleteHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Habit'),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textContrroller.clear();
            },
            child: Text('Cancel'),
          ),

          MaterialButton(
            onPressed: () {
              context.read<HabitDatabase>().deleteHabit(habit.id);

              Navigator.pop(context);
              textContrroller.clear();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
    Map<DateTime, int> dataset = {};

    for (var habit in habits) {
      for (var date in habit.completedDays) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        if (dataset.containsKey(normalizedDate)) {
          dataset[normalizedDate] = dataset[normalizedDate]! + 1;
        } else {
          dataset[normalizedDate] = 1;
        }
      }
    }

    return dataset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'), centerTitle: true),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        onPressed: createNewHabit,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(children: [_buildHeatMap(), _buildHabitList()]),
    );
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final habit = currentHabits[index];
        bool isCompleted = isHabitCompletedToday(habit.completedDays);

        return MyHabitTile(
          habit: habit,
          isCompleted: isCompleted,
          onChanged: (value) => checkHabit(value, habit),
          onEditHabit: (context) => editHabit(habit),
          onDeleteHabit: (context) => deleteHabit(habit),
        );
      },
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataset(currentHabits),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
