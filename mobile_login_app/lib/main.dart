import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path; // Alias for path package
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// Home Page Implementation
class HomePage extends StatelessWidget {
  final String userDisplayName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.userDisplayName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, $userDisplayName!",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              "Email: $userEmail",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

// Login Page Implementation
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // SQLite Database setup
  Future<Database> initializeDatabase() async {
    String dbPath = await getDatabasesPath();
    String fullPath = path.join(dbPath, 'app.db'); // Use alias for path package

    return openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_code TEXT,
            display_name TEXT,
            email TEXT
          )
        ''');
      },
    );
  }

  // Function to insert user data into SQLite
  Future<void> insertUser(Map<String, dynamic> user) async {
    final Database db = await initializeDatabase();
    await db.insert('user', user);
  }

  // Function to handle login
  Future<void> login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    const String apiUrl =
        'https://api.ezuite.com/api/External_Api/Mobile_Api/Invoke';

    final body = jsonEncode({
      "API_Body": [
        {"Unique_Id": "", "Pw": password}
      ],
      "Api_Action": "GetUserData",
      "Company_Code": username,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['Status_Code'] == 200) {
          final user = jsonResponse['Response_Body'][0];
          await insertUser({
            'user_code': user['User_Code'],
            'display_name': user['User_Display_Name'],
            'email': user['Email'],

          });

          // Navigate to the HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userDisplayName: user['User_Display_Name'],
                userEmail: user['Email'],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: ${jsonResponse['Message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
