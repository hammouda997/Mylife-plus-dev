import 'package:flutter/material.dart';
import '../widgets/memoryHeaderSection.dart';
import '../widgets/newMemoryForm.dart';

class MemoryAddScreen extends StatelessWidget {
  const MemoryAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0, 
        automaticallyImplyLeading: false,
        toolbarHeight: 17,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.amber,
            child: const HeaderSection(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0), 

              child: MemoryForm(), 
            ),
          ),
        ],
      ),
      backgroundColor: Colors.amber,
    );
  }
}
