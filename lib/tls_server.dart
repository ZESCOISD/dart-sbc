import 'dart:async';
import 'dart:io';

class TlsSipServer {
  String tcpIp; // = env['WS_SERVER_ADDRESS']!;
  int tcpPort; // = int.parse(env['WS_SERVER_PORT']!);
  String path_to_certificate_file;
  String path_to_private_key_file;

  TlsSipServer(this.tcpIp, this.tcpPort, this.path_to_certificate_file,
      this.path_to_private_key_file) {
    connect();
  }
  void connect() {
    SecurityContext serverContext = SecurityContext();
    serverContext.useCertificateChain(path_to_certificate_file);
    serverContext.usePrivateKey(path_to_private_key_file);

    ServerSocket.bind(tcpIp, tcpPort).then((serverSocket) {
      print('Server listening on ${serverSocket.address}:${serverSocket.port}');

      serverSocket.listen((Socket clientSocket) async {
        print(
            'Client connected from ${clientSocket.remoteAddress}:${clientSocket.remotePort}');

        //SecureServerSocket.secureServer();
        final secureSocket =
            await SecureSocket.secure(clientSocket, context: serverContext);

        // Handle data from the client
        secureSocket.listen((List<int> data) {
          final receivedData = String.fromCharCodes(data).trim();
          print('Received data: $receivedData');

          // Send a response back to the client
          secureSocket.write('Hello from server!\n');
        });

        // Handle client disconnection
        secureSocket.done.then((_) {
          print('Client disconnected.');
        });
      });
    }).catchError((error) {
      print('Error creating server: $error');
    });
  }
}
