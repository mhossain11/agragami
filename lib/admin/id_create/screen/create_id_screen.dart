import 'package:agragami/admin/id_create/service/create_id_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../auth/widgets/text_field.dart';
import '../../../cachehelper/toast.dart';
import 'edit_id_screen.dart';

class CreateIdScreen extends StatefulWidget {
  const CreateIdScreen({super.key});

  @override
  State<CreateIdScreen> createState() => _CreateIdScreenState();
}

class _CreateIdScreenState extends State<CreateIdScreen> {
  TextEditingController useridController = TextEditingController();
  CreateIdService _createIdService = CreateIdService();
  bool isLoadingId = false;
  String selectedRole = 'user';
  bool editView = false;
  String DocId ='';

  Future<void> _create() async {
    setState(() => isLoadingId = true);
    final newDocId = await _createIdService.addUserId(
      role: selectedRole,
      userId: useridController.text,
    );
    setState(() {
     isLoadingId = false;
     editView = true;
     DocId = newDocId;
    });
    CustomToast().showToast(context,"✅ $selectedRole added successfully!",Colors.green);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create User id'),
        centerTitle: true,
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextField(controller: useridController,
              labelText: 'User_ID',),
          ),
          SizedBox(height: 10,),

          // 🔹 Dropdown for Role Selection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(),
              ),
              items: const [
               // DropdownMenuItem(value: 'admin', child: Text("Admin")),
                DropdownMenuItem(value: 'user', child: Text("User")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
          ),
          SizedBox(height: 10,),

          isLoadingId? Center(child: CircularProgressIndicator(),):
         SizedBox(
            width: 250,
            child: ElevatedButton(
                onPressed:_create,
                child: Text('Create Id')),),
          SizedBox(height: 10,),
          Visibility(
            visible: editView,
            child: SizedBox(
              width: 250,
              child: ElevatedButton(
                  onPressed:(){
                    debugPrint('DocId: $DocId');
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>EditIdScreen(
                          userId: useridController.text,
                          docId: DocId,
                          selectedRole: selectedRole,)));
                  },
                  child: Text('Edit Create Id')),),
          )

        ],
      ),
    );
  }
}
