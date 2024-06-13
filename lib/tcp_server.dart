import 'dart:async';
import 'dart:io';

class TcpSipServer {
  String tcpIp; // = env['WS_SERVER_ADDRESS']!;
  int tcpPort; // = int.parse(env['WS_SERVER_PORT']!);

  String udpServerIp;
  int udpServerPort;

  TcpSipServer(this.tcpIp, this.tcpPort, this.udpServerIp, this.udpServerPort) {
    connect();
  }
  void connect() {
    ServerSocket.bind(tcpIp, tcpPort).then((serverSocket) {
      print('Server listening on ${serverSocket.address}:${serverSocket.port}');

      serverSocket.listen((Socket clientSocket) async {
        print(
            'Client connected from ${clientSocket.remoteAddress}:${clientSocket.remotePort}');

        //SecureServerSocket.secureServer();

        // Handle data from the client
        clientSocket.listen((List<int> data) {
          final receivedData = String.fromCharCodes(data).trim();
          print('Received data: $receivedData');

          // Send a response back to the client
          //clientSocket.write('Hello from server!\n');
        }, onError: (error, stack) {
          print("{error: $error, stack: $stack}");
        });

        // Handle client disconnection
        clientSocket.done.then((_) {
          print('Client disconnected.');
        });
      });
    }).catchError((error) {
      print('Error creating server: $error');
    });
  }
}
