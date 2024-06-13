import 'package:dart_sip_parser/sip.dart';

class SipTransport {
  sockaddr_in socket;
  Function(String) send;
  sockaddr_in serverSocket;

  SipTransport(this.socket, this.serverSocket, this.send);
}
