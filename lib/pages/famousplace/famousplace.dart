import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FamousPlaces extends StatefulWidget {
  const FamousPlaces({Key? key}) : super(key: key);

  @override
  State<FamousPlaces> createState() => _FamousPlacesState();
}

class _FamousPlacesState extends State<FamousPlaces> {
  List<List<String>> _famousPlaces = [];
  String _source = '';
  String _destination = '';
  bool _isLoading = false;

  Future<void> _getFamousPlaces() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey =
        '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'; // Replace with your actual API key
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'user',
          'content':
              "I'm creating a travel app. I need a list of famous places with descriptions for locations between $_source and $_destination. \n\nProvide the output as a list of lists in this format:\n\n[ \n  [\"Place Name 1\", \"Description of Place 1\"], \n  [\"Place Name 2\", \"Description of Place 2\"], \n  ... \n]"
        }
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final places = data['choices'][0]['message']['content'];

        // Parse the string response into a List<List<String>>
        final parsedPlaces = jsonDecode(places) as List;
        setState(() {
          _famousPlaces = parsedPlaces
              .map((place) =>
                  (place as List).map((item) => item.toString()).toList())
              .toList();
        });
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
        print(response.body);
        // You might want to show a snackbar or dialog to the user here.
      }
    } catch (e) {
      // Handle exception
      print('Exception: $e');
      // You might want to show a snackbar or dialog to the user here.
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Famous Places'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Source'),
              onChanged: (value) {
                _source = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Destination'),
              onChanged: (value) {
                _destination = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getFamousPlaces,
              child: const Text('Get Famous Places'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_famousPlaces.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _famousPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _famousPlaces[index];
                    return ListTile(
                      title: Text(place[0]),
                      subtitle: Text(place[1]),
                    );
                  },
                ),
              )
            else
              const Center(child: Text('No famous places found.')),
          ],
        ),
      ),
    );
  }
}