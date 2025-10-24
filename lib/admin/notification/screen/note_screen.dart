
import 'package:flutter/material.dart';

import '../../../auth/widgets/text_field.dart';
import '../service/note_service.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  final NoteService _noteService = NoteService();
  bool _isLoading = false;
  bool successful = false;

  Future<void> _handleAddNote() async {
    if (titleController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _noteService.addNote(
        title: titleController.text,
        message: messageController.text,
      );

      setState(() {
        successful= true;
      });
      titleController.clear();
      messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice Board'),
        centerTitle: true,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(controller: titleController,labelText: 'Title',),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(
              controller: messageController,
              labelText: 'Message',
              maxLine: 3,),
          ),
          SizedBox(height: 10,),
          SizedBox(
            width: 300,
            child: ElevatedButton(onPressed: (){
              _handleAddNote();
            }, child:  _isLoading
    ? const CircularProgressIndicator(color: Colors.white)
        : Text('Submit')),
          )
        ],
      ),
    );
  }
}
