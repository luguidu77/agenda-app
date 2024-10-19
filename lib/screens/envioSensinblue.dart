import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnvioSensinblue extends StatefulWidget {
  const EnvioSensinblue({super.key});

  @override
  State<EnvioSensinblue> createState() => _EnvioSensinblueState();
}

class _EnvioSensinblueState extends State<EnvioSensinblue> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      child: ElevatedButton(
        child: const Text('enviar email'),
        onPressed: () => sendEmail(),
      ),
    ));
  }

  Future<void> sendEmail() async {
    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');

    final response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'api-key':
            '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',
      },
      body: '''
      {
        "sender": {
          "name": "Sendinblue",
          "email": "luguidu77@gmail.com"
        },
        "to": [
          {
            "email": "luguidu77@gmail.com",
            "name":"John Doe"
          } 
        ],
        "subject": "Subject of the Email",
        "htmlContent": "<p>This is the <b>HTML</b> content of the email.</p>",
        "textContent": "This is the plain text content of the email."
      }
    ''',
    );

    if (response.statusCode == 201) {
      print('Email sent successfully');
    } else {
      print('Failed to send email. Error: ${response.body}');
    }
  }
}
