import 'package:dart_pbx/sip_parser/sip.dart';

class SipTransport {
  sockaddr_in socket;
  Function send;
  sockaddr_in serverSocket;

  SipTransport(this.socket, this.serverSocket, this.send);
}
