import 'dart:convert';
import 'dart:io';

void main() async {
  // SecurityContext context = SecurityContext();
  // // Load the certificate chain and private key
  // context.useCertificateChain('path_to_certificate.crt');
  // context.usePrivateKey('path_to_private_key.key');
  int server_port = 5067;
  String server_address = "10.43.0.55";

  try {
    Socket socket = await SecureSocket.connect(server_address, server_port);

    socket.listen((List<int> data) {
      // Handle incoming data from the server
      print(utf8.decode(data));
    }, onDone: () {
      // Handle when the connection is closed
      print('Connection closed');
    }, onError: (error) {
      // Handle connection errors
      print('Error: $error');
    });

    // Send data to the server
    //socket.write('Hello, server!');
  } catch (e) {
    // Handle connection errors
    print('Failed to connect: $e');
  }
}
