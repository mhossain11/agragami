
import 'package:flutter/material.dart';

import '../../../auth/widgets/text_field.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../../cachehelper/toast.dart';
import '../../log/service/log_service.dart';
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
  final LogService _logService = LogService();
  bool _isLoading = false;
  bool successful = false;
  String name='';
  String DocId='';
  String email='';
  String adminId='';


  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<String?> getName() async {
    name =  (await CacheHelper().getString('names'))!;
    DocId =  (await CacheHelper().getString('userDocId'))!;
    adminId =  (await CacheHelper().getString('adminId'))!;
    email =  (await CacheHelper().getString('email'))!;
    if (name == null || name.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }if (adminId == null ||adminId.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }

    if (DocId == null || DocId.isEmpty) {
      debugPrint('Error: UserDocId not found in cache!');
      return null;
    }
    if (email == null || email.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }
    setState(() {
      name = name;
      DocId = DocId;
      email = email;
      adminId = adminId;
    });
  }

  Future<void> _handleAddNote() async {
    if (titleController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _noteService.addNote(
        title: titleController.text,
        message: messageController.text,
      );


      await _logService.addLog(
          name:  name,
          email: email,
          userid:  adminId,
          oldData:  titleController.text,
          newData: messageController.text,
          note: 'Admin Note create'
      );
      setState(() {
        successful= true;
      });
      titleController.clear();
      messageController.clear();
      CustomToast().showToast(context, 'Note added successfully!', Colors.green);
    } catch (e) {
      CustomToast().showToast(context, 'Error: $e', Colors.red);
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
