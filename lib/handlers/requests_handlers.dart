//import 'package:dart_pbx/sip/transport.dart';
import 'dart:math';

//import 'package:dart_pbx/services/location_server.dart';
import 'package:dart_pbx/services/models/location.dart';
import 'package:dart_pbx/transports/transport.dart';
import 'package:dart_sip_parser/sip.dart';
import 'package:dart_sip_parser/sip_message_types.dart';

String IDGen() {
  String out = "";
  String temp =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJK7LMNOPQRSTUVWXYZ0123456789";
  for (var x = 0; x < 9; x++) {
    var intValue = Random().nextInt(temp.length);
    out += temp[intValue % temp.length];
  }
  return out;
}

class RequestsHandler {
  Map<String, Function(SipMsg, {SipTransport? transport})> handlers = {};

  RequestsHandler() {
    handlers[SipMessageTypes.REGISTER.toLowerCase()] = onRegister;
    handlers[SipMessageTypes.CANCEL.toLowerCase()] = onCancel;
    handlers[SipMessageTypes.REQUEST_TERMINATED.toLowerCase()] =
        onReqTerminated;
    handlers[SipMessageTypes.INVITE.toLowerCase()] = onInvite;
    handlers[SipMessageTypes.TRYING.toLowerCase()] = onTrying;
    handlers[SipMessageTypes.RINGING.toLowerCase()] = onRinging;
    handlers[SipMessageTypes.BUSY.toLowerCase()] = onBusy;
    handlers[SipMessageTypes.UNAVAIALBLE.toLowerCase()] = onUnavailable;
    handlers[SipMessageTypes.BYE.toLowerCase()] = onBye;
    handlers[SipMessageTypes.OK.toLowerCase()] = onOk;
    handlers[SipMessageTypes.ACK.toLowerCase()] = onAck;
    handlers[SipMessageTypes.UNAUTHORIZED.toLowerCase()] = onUnauthorized;
  }

  void handle(String request, SipTransport transport) {
    SipMsg sipMsg = SipMsg();
    sipMsg.Parse(request);
    if (sipMsg.Req.Method != null) {
      print("request: ${sipMsg.Req.Method}");
      if (handlers[sipMsg.Req.Method!.toLowerCase()] != null) {
        print(transport.send);
        handlers[sipMsg.Req.Method!.toLowerCase()]!(sipMsg,
            transport: transport);
      }
    } else {
      print("Response: ${sipMsg.Req.StatusCode} ${sipMsg.Req.StatusDesc}");
    }
  }

  onRegister(SipMsg data, {SipTransport? transport}) {
    print("Registering user");

    List<String> finalLines = [];
    var lines = data.src!.split('\r\n');
    lines[0] = SipMessageTypes.OK;
    ////print(data.To.Src);
    // response.setVia(data.getVia() + ";received=" + _serverIp);
    // response.setTo(data.getTo() + ";tag=" + IDGen());
    // response.setContact("Contact: <sip:" +
    //     data.getFromNumber() +
    //     "@" +
    //     _serverIp +
    //     ":" +
    //     _serverPort.toString() +
    //     ";transport=UDP>");

    //response.setHeader(SipMessageTypes.OK);
    bool viaAdded = false;
    finalLines.add(SipMessageTypes.OK);

    bool toHeaderAdded = false;
    String toTag;
    ////print("Request: ${data.src}");
    String? contact_id;

    for (int x = 1; x < lines.length; x++) {
      if (lines[x].toLowerCase().contains("via") &&
          //viaAdded &&
          data.Via[0].Host == transport!.serverSocket.addr) {
        lines[x] = lines[x].replaceFirst(
            lines[x], "${lines[x]};received=${transport.serverSocket.addr}");
        // print("Checking via");
        // print(lines[x]);
        finalLines.add(lines[x]);

        viaAdded = true;
      } else if (lines[x].toLowerCase().contains("to")) {
        lines[x] =
            lines[x].replaceFirst(lines[x], "${lines[x]};tag=${IDGen()}");
        finalLines.add(lines[x]);
        toHeaderAdded = false;
        //print(lines[x]);
      } else if (lines[x].toLowerCase().contains("contact")) {
        lines[x] =
            "Contact: <sip:${data.From.User!}@${transport?.serverSocket.addr}:${transport?.serverSocket.port};transport=${transport?.serverSocket.transport.toUpperCase()}>";
        contact_id = lines[x];
        //print(lines[x]);
      } else {
        //print("Line: ${lines[x]}");
        finalLines.add(lines[x]);
      }
    }
    finalLines.add("\r\n");
    var response = finalLines.join("\r\n");
    locations[contact_id!] = Location(
        contact_id,
        data.From.User!,
        data.From.Host,
        contact_id,
        sockaddr_in(transport!.socket.addr, transport.socket.port,
            transport.socket.transport));
    //print(transport!.send);
    locations[contact_id]?.send = transport.send;
    transport.send(response);
  }

  onCancel(SipMsg data, {SipTransport? transport}) {}

  onReqTerminated(SipMsg data, {SipTransport? transport}) {}
  onInvite(SipMsg data, {SipTransport? transport}) {}
  onTrying(SipMsg data, {SipTransport? transport}) {}
  onRinging(SipMsg data, {SipTransport? transport}) {}
  onBusy(SipMsg data, {SipTransport? transport}) {}
  onUnavailable(SipMsg data, {SipTransport? transport}) {}
  onBye(SipMsg data, {SipTransport? transport}) {}
  onOk(SipMsg data, {SipTransport? transport}) {}
  onAck(SipMsg data, {SipTransport? transport}) {}
  onUnauthorized(SipMsg data, {SipTransport? transport}) {}
}
