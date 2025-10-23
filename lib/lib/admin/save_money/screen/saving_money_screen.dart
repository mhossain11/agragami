import 'package:flutter/material.dart';

import '../../../auth/widgets/text_field.dart';
import '../../home/edit_data/screen/editdata_screen.dart';
import '../../home/service/adminhome_service.dart';
import '../../log/service/log_service.dart';
import '../model/usermodel.dart';
import '../service/saving_money_service.dart';

class SavingMoneyScreen extends StatefulWidget {
  const SavingMoneyScreen({super.key});

  @override
  State<SavingMoneyScreen> createState() => _SavingMoneyScreenState();
}

class _SavingMoneyScreenState extends State<SavingMoneyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final SavingMoneyService _savingMoneyService = SavingMoneyService();
  final AdminHomeService _adminHomeService = AdminHomeService();
  final LogService _logService = LogService();
  UserModel? _userData;
  String? currentAmount ;
  bool _isLoading = false;
  String? _error;
  bool visibleData = false;
  bool textVisible = false;
  bool editVisible = false;
  bool successful = false;

  Future<void> _searchUser() async {
    final userId = _searchController.text.trim();
    if (userId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _userData = null;
    });

    try {
      final user = await _savingMoneyService.searchUserById(userId);
      setState(() {
        if (user != null) {
          _userData = user;
        } else {
          _error = "No user found with ID: $userId";
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddMoney() async {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _savingMoneyService.addMoney(
        userId: _searchController.text,
        amount: double.parse(_amountController.text),
      );

      setState(() {
        successful= true;
      });
      setState(() {
        currentAmount = _amountController.text;
        print('Taka1:$currentAmount');
      });
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Money added successfully!')),
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
    if (_userData != null) {
      print('email: ${_userData!.email}');
      print('role: ${_userData!.role}');
    }
    return Scaffold(

      appBar: AppBar(
        title: Text('Saving Money'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                child: CustomTextField(
                  maxLength: 5,
                  controller: _searchController,
                  labelText: 'User Id',)),
            Container(
                padding:EdgeInsets.all(5),
                width: 110,
                child: ElevatedButton(onPressed: (){
                  _searchUser();
                  setState(() {
                    visibleData=true;
                  });
                },
                    child: Text('Search'))),

            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_userData != null)
                Visibility(
                  visible: visibleData,
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        textVisible= true;
                      });
                    },
                    child: Card(
                      color:successful ? Colors.green.shade300:Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(_userData!.name),
                        subtitle: Text(_userData!.email),
                        trailing: Text("ID: ${_userData!.userid}"),
                      ),
                    ),
                  ),
                ),

            Visibility(
              visible: textVisible,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    CustomTextField(controller: _amountController,
                      labelText: 'Taka',),

                    Container(
                        padding:EdgeInsets.all(5),
                        width: 200,
                        child: ElevatedButton(
                            onPressed: ()async{
                          _handleAddMoney();
                          _adminHomeService.getAllUsersTotalAmountStream();
                          await _logService.addLog(
                              name: _userData?.name ?? 'Unknown',
                              email: _userData?.email ?? 'N/A',
                              userid: _userData?.userid ?? 'N/A',
                              oldData: currentAmount ?? '0',
                              newData: _amountController.text,
                                note: 'Add Money'
                          );
                          setState(() {
                            visibleData=true;
                            editVisible = true;
                          });
                        },
                            child:  _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Add Money')),
                    ),
                    Visibility(
                      visible: editVisible,
                      child: Container(
                          padding:EdgeInsets.all(5),
                          width: 200,
                          child: ElevatedButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)
                            =>EditDataScreen(
                              name: _userData!.name,
                              email: _userData!.email,
                              userId: _userData!.userid,
                              money: currentAmount!,)));


                            _searchController.clear();
                            _amountController.clear();
                            setState(() {
                              visibleData= false;
                              editVisible = false;
                              textVisible=false;
                              successful=false;
                            });

                          },
                              child: const Text('Edit Money')),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
