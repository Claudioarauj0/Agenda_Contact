import 'dart:io';
import 'package:agenda_de_contatos/helpers/contact-helper.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrdenOptions { orderaz, ordeza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CONTATOS"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry<OrdenOptions>>[
              const PopupMenuItem(
                value: OrdenOptions.orderaz,
                child: Text("ordernar de A-Z"),
              ),
              const PopupMenuItem(
                value: OrdenOptions.ordeza,
                child: Text("ordernar de Z-A"),
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img!))
                          : const AssetImage("images/person.png")
                              as ImageProvider,
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? "",
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: const Text(
                      "Ligar",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse("tel:${contacts[index].phone}"));
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "Editar",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: contacts[index]);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "Excluir",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                    onPressed: () {
                      helper.deleteContact(contacts[index].id!);
                      setState(() {
                        Navigator.pop(context);
                        contacts.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          },
          onClosing: () {},
        );
      },
    );
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact ?? Contact()),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  Future<void> _getAllContacts() async {
    var c = await helper.getAllContacts();

    setState(() {
      contacts = c;
    });
  }

  void _orderList(OrdenOptions result) {
    switch (result) {
      case OrdenOptions.orderaz:
        contacts.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case OrdenOptions.ordeza:
        contacts.sort((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }
    setState(() {});
  } //fecha o _orderList
}
