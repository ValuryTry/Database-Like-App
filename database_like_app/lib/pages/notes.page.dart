import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import '../services/dbhelper.service.dart';

class notesPage extends StatefulWidget {
  const notesPage({super.key, required this.title});
  final String title;

  @override
  State<notesPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<notesPage> {
  final db = DatabaseHelper();
  final TextEditingController _noteTextController = TextEditingController();
  final TextEditingController _noteDescController = TextEditingController();
  bool _showInputField = false;
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _addNote() async {
    if (_noteTextController.text.isNotEmpty &&
        _noteDescController.text.isNotEmpty) {
      await db.insertNote(_noteTextController.text, _noteDescController.text);
      await _loadNotes();
      setState(() {
        _noteTextController.clear();
        _noteDescController.clear();
        _showInputField = false;
      });
    }
  }

  Future<void> _deleteAllNotes() async {
    for (Map<String, dynamic> note in _notes) {
      _deleteNote(note['id']);
    }
    await _loadNotes();
  }

  Future<void> _deleteNote(int idNote) async {
    await db.deleteNote(idNote);
    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await db.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _toggleInputField() {
    setState(() {
      _showInputField = !_showInputField;
      if (!_showInputField) {
        _noteTextController.clear();
        _noteDescController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          if (_showInputField)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _noteTextController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your note title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteDescController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your note description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addNote,
                    child: const Text('Add Note'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child:
                        _notes.isNotEmpty
                            ? DataTable(
                              columnSpacing: 40,
                              dataRowMinHeight: 40,
                              dataRowMaxHeight: 60,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Content',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Desc',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Date',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                              rows:
                                  _notes.map((note) {
                                    return DataRow(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  "Delete Note",
                                                ),
                                                content: const Text(
                                                  "Do you really want to delete it?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await _deleteNote(
                                                        note['id'],
                                                      );
                                                    },
                                                    child: const Text("Delete"),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },

                                      cells: [
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 100,
                                            ),
                                            child: Text(
                                              note['content'] ?? '',
                                              style: TextStyle(fontSize: 14),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 100,
                                            ),
                                            child: Text(
                                              note['desc'] ?? '',
                                              style: TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: 80,
                                            ),
                                            child: Text(
                                              note['created_at']
                                                      ?.toString()
                                                      .split(' ')[0] ??
                                                  '',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            )
                            : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width, // Take full width
        child: Stack(
          children: [
            Positioned(
              left: 30,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Delete All Notes"),
                          content: const Text(
                            "Are you sure you want to delete all your notes?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                _notes.isNotEmpty
                                    ? await _deleteAllNotes()
                                    : showOkAlertDialog(
                                      context: context,
                                      title: "Oops",
                                      message: "there is nothing to delete",
                                    );
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                  );
                },
                tooltip: 'Delete All Notes',
                heroTag: 'deleteAll', // Important when using multiple FABs
                child: const Icon(Icons.delete),
              ),
            ),
            Positioned(
              right: 16, // Standard FAB position
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _toggleInputField,
                tooltip: 'Add Note',
                heroTag: 'addNote', // Important when using multiple FABs
                child: Icon(_showInputField ? Icons.close : Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
