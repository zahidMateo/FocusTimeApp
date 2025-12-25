import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_theme.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';
import 'package:pomodoro_app/services/notification_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// TASKS SCREEN - GESTIÓN MINIMALISTA DE TAREAS
// ═══════════════════════════════════════════════════════════════════════════════════

class TaskCollection {
  String name;
  Color color;

  TaskCollection({
    required this.name,
    this.color = AppColors.sky, // Azul pastel por defecto
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.value,
      };

  factory TaskCollection.fromJson(Map<String, dynamic> json) => TaskCollection(
        name: json['name'],
        color: json['color'] != null
            ? Color(json['color'])
            : AppColors.sky,
      );
}

class Subtask {
  String id;
  String title;
  bool isCompleted;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'] ?? false,
      );
}

class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime createdAt; // Fecha de creación de la tarea
  DateTime? scheduledFor; // Fecha y hora opcional
  bool hasNotification;
  TimeOfDay? scheduledTime; // Hora de la rutina (sin fecha específica)
  List<int> repeatDays; // Días de repetición (1=Lunes, 7=Domingo). Vacío = no repite
  String? collection; // Colección a la que pertenece (null = sin colección)
  List<Subtask> subtasks; // Lista de subtareas

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    this.scheduledFor,
    this.hasNotification = false,
    this.scheduledTime,
    this.repeatDays = const [],
    this.collection,
    this.subtasks = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'scheduledFor': scheduledFor?.toIso8601String(),
        'hasNotification': hasNotification,
        'scheduledTime': scheduledTime != null
            ? {'hour': scheduledTime!.hour, 'minute': scheduledTime!.minute}
            : null,
        'repeatDays': repeatDays,
        'collection': collection,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        scheduledFor: json['scheduledFor'] != null
            ? DateTime.parse(json['scheduledFor'])
            : null,
        hasNotification: json['hasNotification'] ?? false,
        scheduledTime: json['scheduledTime'] != null
            ? TimeOfDay(
                hour: json['scheduledTime']['hour'],
                minute: json['scheduledTime']['minute'],
              )
            : null,
        repeatDays: json['repeatDays'] != null
            ? List<int>.from(json['repeatDays'])
            : [],
        collection: json['collection'],
        subtasks: json['subtasks'] != null
            ? (json['subtasks'] as List)
                .map((s) => Subtask.fromJson(s))
                .toList()
            : [],
      );
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  List<TaskCollection> _collections = [];
  String? _selectedCollection; // null = todas las tareas
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate; // null = todas las tareas, no null = tareas de ese día
  final TextEditingController _taskController = TextEditingController();
  late PageController _weekPageController;
  int _currentWeekPage = 1000; // Empezar en el medio para permitir scroll infinito

  @override
  void initState() {
    super.initState();
    _weekPageController = PageController(initialPage: _currentWeekPage);
    _loadTasks();
    _loadCollections();
    _cleanOldTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _weekPageController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString('tasks');

      if (tasksJson != null) {
        final List<dynamic> tasksList = json.decode(tasksJson);
        setState(() {
          _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error al cargar tareas: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tasksJson =
          json.encode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      debugPrint('Error al guardar tareas: $e');
    }
  }

  Future<void> _loadCollections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? collectionsJson = prefs.getString('collections');

      if (collectionsJson != null) {
        final List<dynamic> collectionsList = json.decode(collectionsJson);
        setState(() {
          _collections = collectionsList.map((c) => TaskCollection.fromJson(c)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error al cargar colecciones: $e');
    }
  }

  Future<void> _saveCollections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String collectionsJson = json.encode(_collections.map((c) => c.toJson()).toList());
      await prefs.setString('collections', collectionsJson);
    } catch (e) {
      debugPrint('Error al guardar colecciones: $e');
    }
  }

  void _cleanOldTasks() async {
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    setState(() {
      _tasks.removeWhere((task) {
        // Solo eliminar tareas que tienen fecha programada y son antiguas
        if (task.scheduledFor != null) {
          return task.scheduledFor!.isBefore(oneMonthAgo);
        }
        return false; // No eliminar tareas sin fecha
      });
    });

    _saveTasks();
  }

  void _addTask() async {
    if (_taskController.text.trim().isEmpty) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Usar solo los últimos 8 dígitos para mantener ID pequeño
    final shortId = (timestamp % 100000000).toString();
    final taskTitle = _taskController.text.trim();

    // Limpiar el campo ANTES de abrir el diálogo
    _taskController.clear();

    // Mostrar selector de colección
    final selectedCollection = await _showCollectionSelectorForTask();

    if (!mounted) return;

    setState(() {
      _tasks.insert(
        0,
        Task(
          id: shortId,
          title: taskTitle,
          collection: selectedCollection,
          subtasks: [],
        ),
      );
    });

    _saveTasks();

    // Abrir automáticamente el menú de configuración
    await _scheduleTask(0);
  }

  Future<String?> _showCollectionSelectorForTask() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar Colección', style: AppTypography.heading2),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opción "Sin colección"
              ListTile(
                leading: Icon(Icons.inbox_outlined, color: context.colors.textSecondary),
                title: Text('Sin colección'),
                subtitle: Text('No asignar a ninguna colección'),
                onTap: () => Navigator.pop(context, null),
              ),
              Divider(),
              // Colecciones existentes
              if (_collections.isNotEmpty) ...[
                ..._collections.map((collection) => ListTile(
                  leading: Icon(Icons.folder_outlined, color: collection.color),
                  title: Text(collection.name),
                  onTap: () => Navigator.pop(context, collection.name),
                )),
                Divider(),
              ],
              // Opción crear nueva colección
              ListTile(
                leading: Icon(Icons.add_circle_outline, color: context.colors.accent),
                title: Text('Crear nueva colección'),
                onTap: () async {
                  Navigator.pop(context, 'CREATE_NEW');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );

    // Si el usuario seleccionó crear nueva colección
    if (result == 'CREATE_NEW') {
      return await _createNewCollectionFromTask();
    }

    return result;
  }

  Future<String?> _createNewCollectionFromTask() async {
    final TextEditingController controller = TextEditingController();
    final collectionName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Colección', style: AppTypography.heading2),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nombre de la colección',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text('Crear'),
          ),
        ],
      ),
    );

    if (collectionName != null && collectionName.isNotEmpty) {
      // Mostrar selector de color
      final selectedColor = await _showQuickColorPicker();

      if (mounted) {
        setState(() {
          _collections.add(TaskCollection(
            name: collectionName,
            color: selectedColor ?? const Color(0xFFB8D4E8),
          ));
        });
        _saveCollections();
        return collectionName;
      }
    }

    return null;
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    // Cancelar notificación(es) si existen
    if (_tasks[index].hasNotification) {
      final baseId = int.parse(_tasks[index].id);

      if (_tasks[index].repeatDays.isNotEmpty) {
        // Cancelar notificaciones de cada día
        for (final day in _tasks[index].repeatDays) {
          NotificationService.cancelTaskNotification(baseId + day);
        }
      } else {
        // Cancelar notificación única
        NotificationService.cancelTaskNotification(baseId);
      }
    }

    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _addCollection() async {
    final TextEditingController controller = TextEditingController();
    final collectionName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Colección', style: AppTypography.heading2),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nombre de la colección',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text('Crear'),
          ),
        ],
      ),
    );

    if (collectionName != null && collectionName.isNotEmpty) {
      // Mostrar selector de color
      final selectedColor = await _showQuickColorPicker();

      setState(() {
        _collections.add(TaskCollection(
          name: collectionName,
          color: selectedColor ?? const Color(0xFFB8D4E8),
        ));
      });
      _saveCollections();
    }
  }

  void _deleteCollection(String collectionName) {
    // Mostrar confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Colección', style: AppTypography.heading2),
        content: Text('¿Eliminar "$collectionName"? Las tareas se moverán a "Todas".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // Remover la colección de todas las tareas
                for (var task in _tasks) {
                  if (task.collection == collectionName) {
                    task.collection = null;
                  }
                }
                _collections.removeWhere((c) => c.name == collectionName);
                if (_selectedCollection == collectionName) {
                  _selectedCollection = null;
                }
              });
              _saveTasks();
              _saveCollections();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.destructive,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _addSubtask(int taskIndex) async {
    final TextEditingController controller = TextEditingController();
    final subtaskTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Subtarea', style: AppTypography.heading2),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Título de la subtarea',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text('Agregar'),
          ),
        ],
      ),
    );

    if (subtaskTitle != null && subtaskTitle.isNotEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final shortId = (timestamp % 100000000).toString();

      setState(() {
        _tasks[taskIndex].subtasks = [
          ..._tasks[taskIndex].subtasks,
          Subtask(id: shortId, title: subtaskTitle),
        ];
      });
      _saveTasks();
    }
  }

  void _toggleSubtask(int taskIndex, int subtaskIndex) {
    setState(() {
      _tasks[taskIndex].subtasks[subtaskIndex].isCompleted =
          !_tasks[taskIndex].subtasks[subtaskIndex].isCompleted;
    });
    _saveTasks();
  }

  void _deleteSubtask(int taskIndex, int subtaskIndex) {
    setState(() {
      _tasks[taskIndex].subtasks = [
        ..._tasks[taskIndex].subtasks.sublist(0, subtaskIndex),
        ..._tasks[taskIndex].subtasks.sublist(subtaskIndex + 1),
      ];
    });
    _saveTasks();
  }

  void _editSubtask(int taskIndex, int subtaskIndex) async {
    final TextEditingController controller = TextEditingController(
      text: _tasks[taskIndex].subtasks[subtaskIndex].title,
    );

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Subtarea', style: AppTypography.heading2),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Título de la subtarea',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        _tasks[taskIndex].subtasks[subtaskIndex].title = newTitle;
      });
      _saveTasks();
    }
  }

  Future<void> _scheduleTask(int index) async {
    // Mostrar diálogo para elegir: fecha única o repetir días
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configurar tarea', style: AppTypography.heading2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.event, color: context.colors.accent),
              title: Text('Fecha específica'),
              subtitle: Text('Programar para un día en particular'),
              onTap: () => Navigator.pop(context, 'date'),
            ),
            ListTile(
              leading: Icon(Icons.repeat, color: context.colors.accent),
              title: Text('Repetir cada semana'),
              subtitle: Text('Programar para varios días'),
              onTap: () => Navigator.pop(context, 'repeat'),
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: context.colors.textSecondary),
              title: Text('Cancelar'),
              onTap: () => Navigator.pop(context, 'cancel'),
            ),
          ],
        ),
      ),
    );

    if (choice == null || choice == 'cancel' || !mounted) return;

    // Elegir hora
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _tasks[index].scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.accent,
              onPrimary: Colors.white,
              onSurface: context.colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    if (choice == 'date') {
      // Modo fecha específica
      await _scheduleForDate(index, pickedTime);
    } else {
      // Modo repetir días
      await _scheduleForRepeat(index, pickedTime);
    }
  }

  Future<void> _scheduleForDate(int index, TimeOfDay pickedTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.accent,
              onPrimary: Colors.white,
              onSurface: context.colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final scheduledDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final notificationTime = scheduledDateTime.subtract(Duration(hours: 1));
    bool notificationScheduled = false;

    // Intentar programar la notificación si es posible
    if (notificationTime.isAfter(DateTime.now())) {
      await NotificationService.scheduleTaskNotification(
        taskId: int.parse(_tasks[index].id),
        title: 'Recordatorio de tarea',
        body: '${_tasks[index].title} - en 1 hora',
        scheduledTime: notificationTime,
      );
      notificationScheduled = true;
    }

    // Guardar la fecha programada SIEMPRE, independientemente de la notificación
    setState(() {
      _tasks[index].scheduledFor = scheduledDateTime;
      _tasks[index].scheduledTime = null;
      _tasks[index].repeatDays = [];
      _tasks[index].hasNotification = notificationScheduled;
    });

    _saveTasks();

    // Mostrar mensaje apropiado
    if (mounted) {
      if (notificationScheduled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Tarea programada con recordatorio 1 hora antes'),
            backgroundColor: context.colors.accent,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Tarea programada (sin notificación)'),
            backgroundColor: context.colors.accent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _scheduleForRepeat(int index, TimeOfDay pickedTime) async {
    // Mostrar diálogo de selección de días
    final selectedDays = await _showDaySelector();

    if (selectedDays == null || selectedDays.isEmpty || !mounted) return;

    // Programar notificaciones para cada día seleccionado
    final notificationScheduled = await _scheduleRepeatingNotifications(index, pickedTime, selectedDays);

    // Guardar la tarea con días repetidos SIEMPRE, independientemente de las notificaciones
    setState(() {
      _tasks[index].scheduledTime = pickedTime;
      _tasks[index].repeatDays = selectedDays;
      _tasks[index].scheduledFor = null;
      _tasks[index].hasNotification = notificationScheduled;
    });

    _saveTasks();

    if (mounted) {
      if (notificationScheduled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Rutina programada con recordatorios'),
            backgroundColor: context.colors.accent,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Rutina programada (sin notificaciones)'),
            backgroundColor: context.colors.accent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<List<int>?> _showDaySelector() async {
    final selected = <int>[];

    return showDialog<List<int>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Selecciona los días', style: AppTypography.heading2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDayChip('L', 1, selected, setDialogState),
              _buildDayChip('M', 2, selected, setDialogState),
              _buildDayChip('Mi', 3, selected, setDialogState),
              _buildDayChip('J', 4, selected, setDialogState),
              _buildDayChip('V', 5, selected, setDialogState),
              _buildDayChip('S', 6, selected, setDialogState),
              _buildDayChip('D', 7, selected, setDialogState),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(context, selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.accent,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(
      String label, int day, List<int> selected, StateSetter setState) {
    final isSelected = selected.contains(day);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              selected.remove(day);
            } else {
              selected.add(day);
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.accent : context.colors.appBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? context.colors.accent : context.colors.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.white : context.colors.textSecondary,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                _getDayName(day),
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  Future<Color?> _showQuickColorPicker() async {
    final colors = [
      Color(0xFFB8D4E8), // Azul pastel
      Color(0xFFD4C5F9), // Lavanda pastel
      Color(0xFFC8E6D0), // Mint pastel
      Color(0xFFFFC4D6), // Rosa pastel
      Color(0xFFFFE0B3), // Melocotón pastel
    ];

    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Elige un color', style: AppTypography.heading2),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colors.map((color) {
            return InkWell(
              onTap: () => Navigator.pop(context, color),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<bool> _scheduleRepeatingNotifications(
      int index, TimeOfDay time, List<int> days) async {
    final baseId = int.parse(_tasks[index].id);
    bool anyNotificationScheduled = false;

    for (final day in days) {
      // Calcular la próxima ocurrencia de este día
      final now = DateTime.now();
      DateTime nextOccurrence = _getNextOccurrence(day, time);

      // Verificar si la notificación (1 hora antes) es en el futuro
      final notificationTime = nextOccurrence.subtract(Duration(hours: 1));

      if (notificationTime.isAfter(now)) {
        // Usar ID único para cada día: baseId + día de semana
        final notificationId = baseId + day;

        await NotificationService.scheduleTaskNotification(
          taskId: notificationId,
          title: 'Recordatorio de tarea',
          body: '${_tasks[index].title} - en 1 hora',
          scheduledTime: notificationTime,
        );
        anyNotificationScheduled = true;
      }
    }

    return anyNotificationScheduled;
  }

  DateTime _getNextOccurrence(int targetDay, TimeOfDay time) {
    final now = DateTime.now();
    final currentDay = now.weekday; // 1=Lunes, 7=Domingo

    int daysUntilTarget = targetDay - currentDay;

    // Si es el día actual, verificar si la hora ya pasó
    if (daysUntilTarget == 0) {
      final targetTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Si la hora ya pasó hoy, programar para la próxima semana
      if (targetTime.isBefore(now)) {
        daysUntilTarget = 7;
      }
    } else if (daysUntilTarget < 0) {
      // Si el día ya pasó esta semana, programar para la próxima semana
      daysUntilTarget += 7;
    }

    return DateTime(
      now.year,
      now.month,
      now.day + daysUntilTarget,
      time.hour,
      time.minute,
    );
  }

  void _removeSchedule(int index) {
    if (_tasks[index].hasNotification) {
      final baseId = int.parse(_tasks[index].id);

      if (_tasks[index].repeatDays.isNotEmpty) {
        // Cancelar notificaciones de cada día
        for (final day in _tasks[index].repeatDays) {
          NotificationService.cancelTaskNotification(baseId + day);
        }
      } else {
        // Cancelar notificación única
        NotificationService.cancelTaskNotification(baseId);
      }
    }

    setState(() {
      _tasks[index].scheduledFor = null;
      _tasks[index].scheduledTime = null;
      _tasks[index].repeatDays = [];
      _tasks[index].hasNotification = false;
    });
    _saveTasks();
  }

  List<Task> get _filteredTasks {
    var filtered = _tasks;

    // Filtrar por colección
    if (_selectedCollection != null) {
      filtered = filtered.where((t) => t.collection == _selectedCollection).toList();
    }

    // Filtrar por fecha seleccionada
    if (_selectedDate != null) {
      final selectedDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      filtered = filtered.where((t) {
        // Mostrar si está programada para ese día exacto
        if (t.scheduledFor != null) {
          final scheduledDay = DateTime(t.scheduledFor!.year, t.scheduledFor!.month, t.scheduledFor!.day);
          return scheduledDay.year == selectedDay.year &&
                 scheduledDay.month == selectedDay.month &&
                 scheduledDay.day == selectedDay.day;
        }

        // Mostrar si es una tarea repetitiva y corresponde a ese día de la semana
        if (t.repeatDays.isNotEmpty && t.scheduledTime != null) {
          final dayOfWeek = _selectedDate!.weekday; // 1=Lunes, 7=Domingo
          return t.repeatDays.contains(dayOfWeek);
        }

        return false;
      }).toList();
    }

    return filtered;
  }

  Color _getTaskColor(Task task) {
    if (task.collection == null) {
      return context.colors.accent; // Color por defecto para tareas sin colección
    }
    final collection = _collections.firstWhere(
      (c) => c.name == task.collection,
      orElse: () => TaskCollection(name: '', color: context.colors.accent),
    );
    return collection.color;
  }

  Widget _buildWeeklyCalendar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Column(
        children: [
          // Header del calendario con navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: context.colors.accent),
                onPressed: () {
                  _weekPageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: context.colors.accent,
                            onPrimary: Colors.white,
                            onSurface: context.colors.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedMonth = picked;
                    });
                  }
                },
                child: Text(
                  '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: context.colors.accent),
                onPressed: () {
                  _weekPageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Encabezados de días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8),
          // PageView para deslizar entre semanas
          SizedBox(
            height: 40,
            child: PageView.builder(
              controller: _weekPageController,
              onPageChanged: (page) {
                setState(() {
                  _currentWeekPage = page;
                  // Actualizar el mes mostrado en el header
                  final weekOffset = page - 1000;
                  final now = DateTime.now();
                  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                  final targetWeek = startOfWeek.add(Duration(days: weekOffset * 7));
                  _selectedMonth = DateTime(targetWeek.year, targetWeek.month);
                });
              },
              itemBuilder: (context, pageIndex) {
                // Calcular qué semana mostrar basándose en el índice de página
                final weekOffset = pageIndex - 1000; // Offset desde la semana actual
                final now = DateTime.now();
                final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                final targetStartOfWeek = startOfWeek.add(Duration(days: weekOffset * 7));
                final daysOfWeek = List.generate(7, (i) => targetStartOfWeek.add(Duration(days: i)));

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: daysOfWeek.map((day) {
                    final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
                    final isSelected = _selectedDate != null &&
                                       day.day == _selectedDate!.day &&
                                       day.month == _selectedDate!.month &&
                                       day.year == _selectedDate!.year;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedDate = null;
                            } else {
                              _selectedDate = day;
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.colors.accent
                                : (isToday ? context.colors.accent.withOpacity(0.3) : Colors.transparent),
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(color: context.colors.accent, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isSelected ? Colors.white : context.colors.textPrimary,
                                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }

  String _getDayShort(int weekday) {
    const days = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  Widget _buildCollectionsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de colecciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Colecciones',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: _addCollection,
                icon: Icon(Icons.add, size: 16, color: context.colors.accent),
                label: Text('Nueva', style: TextStyle(color: context.colors.accent)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Lista de colecciones
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Opción "Todas"
                _buildCollectionChip('Todas', null, context.colors.accent),
                SizedBox(width: 8),
                // Colecciones creadas
                ..._collections.map((collection) => Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: _buildCollectionChip(collection.name, collection.name, collection.color),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionChip(String label, String? collection, Color color) {
    final isSelected = _selectedCollection == collection;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCollection = collection;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : context.colors.appBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : context.colors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (collection != null) ...[
              Icon(
                Icons.folder_outlined,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : context.colors.textPrimary,
              ),
            ),
            if (collection != null && isSelected) ...[
              SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  _deleteCollection(collection);
                },
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    final completedCount = filteredTasks.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor: context.colors.appBackground,
      appBar: AppBar(
        title: Text('Tareas'),
        backgroundColor: context.colors.cardBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════════════════
          // CALENDARIO SEMANAL
          // ═══════════════════════════════════════════════════════════════════════════
          SizedBox(height: AppConstants.paddingMedium),
          _buildWeeklyCalendar(),

          SizedBox(height: AppConstants.paddingMedium),

          // ═══════════════════════════════════════════════════════════════════════════
          // COLECCIONES
          // ═══════════════════════════════════════════════════════════════════════════
          _buildCollectionsSection(),

          SizedBox(height: AppConstants.paddingMedium),

          // ═══════════════════════════════════════════════════════════════════════════
          // CAMPO PARA AGREGAR TAREA
          // ═══════════════════════════════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Nueva tarea...',
                      hintStyle: TextStyle(color: context.colors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    ),
                    style: AppTypography.bodyMedium,
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: context.colors.accent),
                  onPressed: _addTask,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // ═══════════════════════════════════════════════════════════════════════════
          // LISTA DE TAREAS
          // ═══════════════════════════════════════════════════════════════════════════
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: context.colors.textSecondary.withOpacity(0.5),
                        ),
                        SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'Sin tareas',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: 0,
                    ),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final originalIndex = _tasks.indexOf(task);
                      final isScheduled =
                          task.scheduledFor != null || task.repeatDays.isNotEmpty;
                      final taskColor = _getTaskColor(task);

                      return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: EdgeInsets.only(bottom: 6),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: context.colors.destructive,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteTask(originalIndex),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 6),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: taskColor,
                                  width: 2,
                                ),
                              ),
                              color: taskColor.withOpacity(0.08),
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _scheduleTask(originalIndex),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Checkbox
                                        Checkbox(
                                          value: task.isCompleted,
                                          onChanged: (_) => _toggleTask(originalIndex),
                                          activeColor: taskColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // Contenido
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: AppTypography.bodyMedium.copyWith(
                                                  decoration: task.isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                  color: task.isCompleted
                                                      ? context.colors.textSecondary
                                                      : context.colors.textPrimary,
                                                ),
                                              ),
                                              if (isScheduled) ...[
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      task.repeatDays.isNotEmpty
                                                          ? Icons.repeat
                                                          : Icons.schedule,
                                                      size: 14,
                                                      color: taskColor,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        _formatSchedule(task),
                                                        style:
                                                            AppTypography.bodySmall.copyWith(
                                                          color: taskColor,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        // Botón de eliminar
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, size: 20),
                                          color: context.colors.destructive,
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          onPressed: () => _deleteTask(originalIndex),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Subtareas
                                if (task.subtasks.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.only(left: 58, right: 10, bottom: 4),
                                    child: Column(
                                      children: task.subtasks.asMap().entries.map((entry) {
                                        final subtaskIndex = entry.key;
                                        final subtask = entry.value;
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              // Punto indicador
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: taskColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              // Checkbox de subtarea
                                              Transform.scale(
                                                scale: 0.8,
                                                child: Checkbox(
                                                  value: subtask.isCompleted,
                                                  onChanged: (_) => _toggleSubtask(originalIndex, subtaskIndex),
                                                  activeColor: taskColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                              ),
                                              // Título de subtarea
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => _editSubtask(originalIndex, subtaskIndex),
                                                  child: Text(
                                                    subtask.title,
                                                    style: AppTypography.bodySmall.copyWith(
                                                      decoration: subtask.isCompleted
                                                          ? TextDecoration.lineThrough
                                                          : null,
                                                      color: subtask.isCompleted
                                                          ? context.colors.textSecondary
                                                          : context.colors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Botón eliminar subtarea
                                              IconButton(
                                                icon: Icon(Icons.close, size: 14),
                                                color: context.colors.textSecondary,
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 24,
                                                ),
                                                onPressed: () => _deleteSubtask(originalIndex, subtaskIndex),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                                // Botón agregar subtarea
                                Padding(
                                  padding: EdgeInsets.only(left: 58, bottom: 8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () => _addSubtask(originalIndex),
                                      icon: Icon(Icons.add, size: 16, color: taskColor),
                                      label: Text(
                                        'Subtarea',
                                        style: TextStyle(color: taskColor, fontSize: 12),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatSchedule(Task task) {
    if (task.repeatDays.isNotEmpty && task.scheduledTime != null) {
      // Tarea repetida: mostrar días y hora
      final hour = task.scheduledTime!.hour.toString().padLeft(2, '0');
      final minute = task.scheduledTime!.minute.toString().padLeft(2, '0');
      final daysStr = _formatRepeatDays(task.repeatDays);
      return '$daysStr a las $hour:$minute';
    } else if (task.scheduledFor != null) {
      // Tarea única: mostrar fecha y hora
      return _formatScheduledTime(task.scheduledFor!);
    }
    return '';
  }

  String _formatRepeatDays(List<int> days) {
    final dayNames = {
      1: 'L',
      2: 'M',
      3: 'Mi',
      4: 'J',
      5: 'V',
      6: 'S',
      7: 'D',
    };

    final sorted = List<int>.from(days)..sort();
    return sorted.map((d) => dayNames[d]).join(', ');
  }

  String _formatScheduledTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (taskDate == today) {
      dateStr = 'Hoy';
    } else if (taskDate == tomorrow) {
      dateStr = 'Mañana';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr $hour:$minute';
  }
}
