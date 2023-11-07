import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/contact-helper.dart';
import 'dart:io';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({required this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  final _imagePicker = ImagePicker(); // Crie uma instância de ImagePicker

  bool _userEdited = false;

  late Contact _editedContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name ?? '';
      _emailController.text = _editedContact.email ?? '';
      _phoneController.text = _editedContact.phone ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestpop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_editedContact.name != null &&
                  _editedContact.name!.isNotEmpty) {
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.save),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img!))
                              : const AssetImage("images/person.png")
                                  as ImageProvider,
                          fit: BoxFit.cover),
                    ),
                  ),
                  onTap: () {
                    ImagePicker()
                        .pickImage(source: ImageSource.camera)
                        .then((file) {
                      if (file == null) return;
                      _editedContact.img = file.path;
                    });
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: const InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                )
              ],
            ),
          ),
        ));
  }

  Future<bool> _requestpop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descartar alterações?"),
            content: const Text("Se sair, as alterações serão perdidas."),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text("Sim"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
