import 'splash_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterTts tts = FlutterTts();

  String name = "";
  String id = "";
  String photo = "";
  String status = "Scan a QR Code";

  List<String> attendanceList = [];
  bool espConnected = false;
  Future<void> checkESP() async {
    try {
      final response =
      await http.get(Uri.parse("http://192.168.4.1/STATUS"));

      setState(() {
        espConnected = response.statusCode == 200;
      });
    } catch (e) {
      setState(() {
        espConnected = false;
      });
    }
  }
  double scanLinePosition = 0;

  @override
  void initState() {
    super.initState();
    checkESP();

    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 20));

      if (!mounted) return false;

      setState(() {
        scanLinePosition += 3;

        if (scanLinePosition > 250) {
          scanLinePosition = 0;
        }
      });

      return true;
    });
  }
    Future<void> authenticateUser(BuildContext context) async {
      try {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Fingerprint laga kar verify karein',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (authenticated) {
          await tts.setLanguage("en-US");
          await tts.setSpeechRate(0.4);
          await tts.setPitch(1.0);

          tts.speak(
              "Authentication Successful. Door Unlocked. Welcome, $name."
          );
          await http.get(
            Uri.parse("http://192.168.4.1/OPEN"),

          );
          setState(() {
            attendanceList.add(
                "$name - $id - ${DateTime.now()}"
            );
          });
          print("Added");
          print(attendanceList.length);


          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Access Granted"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Access Denied"),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
          ),
        );
      }
    }

    final Map<String, Map<String, String>> students = {
      "AMAN001": {
        "name": "AMAN",
        "id": "AMAN001",
        "photo": "assets/aman.jpeg",
      },
      "PRASHANT002": {
        "name": "PRASHANT",
        "id": "PRASHANT002",
        "photo": "assets/prashant.jpeg",
      },
      "ARPIT003": {
        "name": "ARPIT",
        "id": "ARPIT003",
        "photo": "assets/arpit.jpeg",
      },
      "VIRAT004": {
        "name": "VIRAT",
        "id": "VIRAT004",
        "photo": "assets/virat.jpeg",
      },
      "AKASH005": {
        "name": "AKASH",
        "id": "AKASH005",
        "photo": "assets/akash.jpeg",
      },
    };

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Aman Smart Door Lock"),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "attendance") {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: const Text("Attendance List"),
                          content: SizedBox(
                            width: 300,
                            height: 300,
                            child: ListView.builder(
                              itemCount: attendanceList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(attendanceList[index]),
                                );
                              },
                            ),
                          ),
                        ),
                  );
                }
              },
              itemBuilder: (context) =>
              [
                const PopupMenuItem(
                  value: "attendance",
                  child: Text("Attendance List"),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [

            const SizedBox(height: 10),

            ShaderMask(
              shaderCallback: (bounds) =>
                  const LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.blue,
                    ],
                  ).createShader(bounds),
              child: const Text(
                "WELCOME AMAN SMART DOOR LOCK",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 5),

        Text(
          espConnected ? "🟢 SERVO ONLINE" : "🔴 SERVO OFFLINE",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: espConnected ? Colors.green : Colors.red,
            shadows: [
              Shadow(
                color: espConnected ? Colors.green : Colors.red,
                blurRadius: 15,
              ),
            ],
          ),
        ),

            Expanded(
              flex: 2,
              child: Stack(
                children: [

                  MobileScanner(
                    onDetect: (capture) async {
                      final barcode = capture.barcodes.first;

                      String qrData = barcode.rawValue ?? "";

                      print("QR Data: $qrData");

                      if (students.containsKey(qrData)) {
                        setState(() {
                          name = students[qrData]!["name"]!;
                          id = students[qrData]!["id"]!;
                          photo = students[qrData]!["photo"]!;
                          status = "✅ Authorized";
                          //espConnected = true;
                        });
                      } else {
                        setState(() {
                          name = "";
                          id = "";
                          photo = "";
                          status = "⚠ No Record Found";
                          //espConnected = false;
                        });
                        await http.get(
                          Uri.parse("http://192.168.4.1/RED"),
                        );
                      }
                    },
                  ),
                  Positioned(
                    left: 55,
                    top: scanLinePosition,
                    child: Container(
                      width: 300,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                          width: 3,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status == "✅ Authorized" && photo.isNotEmpty)
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(photo),
                      ),

                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Text(
                      "Name : $name",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "ID : $id",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),

                    if (status == "✅ Authorized")
                      ElevatedButton(
                        onPressed: () async {
                          await authenticateUser(context);
                        },
                        child: const Text("VERIFY IDENTITY"),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
