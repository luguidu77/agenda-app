import 'package:flutter/material.dart';
import 'package:flutter_sendinblue/flutter_sendinblue.dart';

import '../contact_detail_page.dart';

class UsuariosSendinblue extends StatefulWidget {
  const UsuariosSendinblue({super.key});

  @override
  State<UsuariosSendinblue> createState() => _UsuariosSendinblueState();
}

class _UsuariosSendinblueState extends State<UsuariosSendinblue> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Sendinblue.initialize(
      configuration: SendinblueConfiguration(
        apiKey:
            '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',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sendinblue Demo'),
      ),
      body: FutureBuilder<List<Contact>>(
        future: Sendinblue.instance.getAllContacts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final contacts = snapshot.data;
            if (contacts == null) {
              return const Center(
                child: Text('No contacts found'),
              );
            }
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = snapshot.data![index];
                return ListTile(
                  title: Text(
                    contact.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text('id: ${contact.id}'),
                  onTap: () =>
                      ContactDetailPage.navigateTo(context, contact.email),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
