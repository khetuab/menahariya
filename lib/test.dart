import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';

class TestConnectionScreen extends StatelessWidget {
  const TestConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = SocketService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Socket')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
              'Socket Connected: ${socketService.isConnected}',
              style: const TextStyle(fontSize: 18),
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await socketService.connect();
              },
              child: const Text('Connect Socket'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                socketService.disconnect();
              },
              child: const Text('Disconnect Socket'),
            ),
          ],
        ),
      ),
    );
  }
}