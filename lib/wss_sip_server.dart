import 'dart:io';

class WssSipServer {
  WssSipServer(String ip, int port, String udpServerIp, int udpServerPort,
      this.path_to_certificate_file, this.path_to_private_key_file)
      : this.ip = ip,
        this.port = port,
        this.udpServerIp = udpServerIp,
        this.udpServerPort = udpServerPort {
    SecurityContext serverContext = SecurityContext();
    serverContext.useCertificateChain(path_to_certificate_file);
    serverContext.usePrivateKey(path_to_private_key_file);

    HttpServer.bindSecure(ip, port, serverContext).then((server) async {
      print('Listening on wss://${server.address.address}:${server.port}');

      await for (HttpRequest request in server) {
        request.response.headers.set("Sec-WebSocket-Protocol", "sip");
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then(handleWebSocket);
        } else {
          request.response
            ..statusCode = HttpStatus.forbidden
            ..close();
        }
      }
    });
  }

  void handleWebSocket(WebSocket socket) async {
    RawDatagramSocket udpClient =
        await RawDatagramSocket.bind(InternetAddress(udpServerIp), 0);
    //   .then((RawDatagramSocket socket) {
    //print('UDP client ready to receive');
    //print('${udpClient.address.address}:${udpClient.port}');

    //handler = ReqHandler(socket.address.address, socket.port, socket);

    onNewMessageFromWS(String data) {
      // //print(data);
      udpClient.send(data.toString().codeUnits, InternetAddress(udpServerIp),
          udpServerPort);
    }

    onNewMessageFromSipServer(String data) {
      socket.add(data);
    }

    socket.listen(
      (data) {
        //print('Received: $data');
        onNewMessageFromWS(data);
        //socket.add('Echo: ${json.encode(resp)}');
      },
      onDone: () {
        //print('Connection closed');
      },
      onError: (error) {
        //print('Error: $error');
      },
    );

    udpClient.listen((RawSocketEvent e) {
      Datagram? d = udpClient.receive();
      if (d != null) {
        String message = String.fromCharCodes(d.data);
        ////print(
        //    'Datagram from ${d.address.address}:${d.port}: ${message.trim()}');

        onNewMessageFromSipServer(message);
      }
    });
  }

  String ip;
  int port;
  String udpServerIp;
  int udpServerPort;
  String path_to_certificate_file;
  String path_to_private_key_file;
}
