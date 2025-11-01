import 'package:agragami/cachehelper/toast.dart';
import 'package:flutter/material.dart';

import '../../../auth/widgets/text_field.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../edit_data/screen/editdata_screen.dart';
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
  String _selectedMethod ='Cache Money'; // dropdown value
  final List<String> _methods = ['Nogod', 'Bkash', 'Cache Money', 'cheque','Upay'];
  final LogService _logService = LogService();
  UserModel? _userData;
  String? currentAmount ;
  String adminName='';
  String adminDocId='';
  String adminId='';
  String adminEmail='';
  bool _isLoading = false;
  String? _error;
  bool visibleData = false;
  bool textVisible = false;
  bool editVisible = false;
  bool successful = false;

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<String?> getName() async {
    final userName =  await CacheHelper().getString('names');
    final userDocId =  await CacheHelper().getString('userDocId');
    var Id =  await CacheHelper().getString('adminId');
    final email =  await CacheHelper().getString('email');


    if (userName == null || userName.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }

    if (userDocId == null || userDocId.isEmpty) {
      debugPrint('Error: UserDocId not found in cache!');
      return null;
    }

    if (Id == null || Id.isEmpty) {
      debugPrint('Error: Id not found in cache!');
      return null;
    }

    if (email == null || email.isEmpty) {
      debugPrint('Error: email not found in cache!');
      return null;
    }
    setState(() {
      adminName = userName;
      adminDocId = userDocId;
      adminId = Id;
      adminEmail = email  ;
    });
    return null;
  }

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
        paymentMethod: _selectedMethod,
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
      CustomToast().showToast(context, 'Money added successfully!', Colors.green);
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
        title: Text('Saving Money'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                child: CustomTextField(
                  maxLength: 10,
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
                      labelText: 'Amount',),
                    const SizedBox(height: 20),

                    // 🔹 Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMethod,
                      hint: const Text('Select Payment Method'),
                      items: _methods
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    Container(
                        padding:EdgeInsets.all(5),
                        width: 200,
                        child: ElevatedButton(
                            onPressed: ()async{
                          _handleAddMoney();
                          await _logService.addLog(
                              name: adminName ?? 'Unknown',
                              email: adminEmail ?? 'N/A',
                              userid: adminId ?? 'N/A',
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
