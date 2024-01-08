import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:dotted_border/dotted_border.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _image = [];

  Future getImage(ImageSource source) async{
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null){
        _image.add(File(pickedFile.path));
      } else {
        print('No image slected');
      }
    });
  }

  Future<void> createPDF() async{
    for (var img in _image) {
      print("checking...");
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ));
    }
  }

  void showPrintedMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: Duration(seconds: 3),
      icon: Icon(
        Icons.save_alt_outlined,
        color: Colors.blue,
      ),
    )..show(context);
  }

  Future<void> savePDF() async {
    try {
    await  createPDF();

      var downloadsDir = Directory("");
      if(Platform.isAndroid)
        {
          downloadsDir =  Directory("/storage/emulated/0/Download");
        }
      else
        {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
  print(downloadsDir);
      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/${DateTime
            .now()
            .microsecondsSinceEpoch}.pdf');
        await file.writeAsBytes(await pdf.save());

        print(file);
        showPrintedMessage('Success','Saved to Download folder $file');
      }else{
        showPrintedMessage('Erroe','Unable to access Downloads folder');
      }
    }
    catch (e)
    {
        showPrintedMessage('Error',e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.restart_alt_rounded),
          onPressed:(){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
            );
          }
        ),
        centerTitle: true,
        title: Text('Image to PDF'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              savePDF();
            },
          )
        ],
        backgroundColor: Colors.pinkAccent[400],
      ),
      body: _image.isNotEmpty
      ? ListView.builder(
        itemCount: _image.length,
        itemBuilder: (context, index) => Container(
          height: 400,
          width: double.infinity,
          margin: EdgeInsets.all(8),
          child: Image.file(
            _image[index],
            fit: BoxFit.cover,
          ),
        ),
      )
       :Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child:
            DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(20),
              dashPattern: [10, 10],
              color: Colors.black,
              strokeWidth: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.pink[50]
                  ),
                  height: 520,
                  width: 350,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library,size: 60,
                      color: Colors.pinkAccent[400],),
                      SizedBox(
                        height: 20,
                      ),
                      Text('No image is Selected',style: TextStyle(
                        fontSize: 17
                      ),)
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [


          FloatingActionButton(
            backgroundColor: Colors.redAccent[400],
            onPressed: ()=> getImage(ImageSource.gallery),

            child: Icon(Icons.photo_library),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: Colors.redAccent[400],
            onPressed: ()=> getImage(ImageSource.camera),

            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
