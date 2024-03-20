import "dart:core";
import 'dart:ffi';
import 'dart:math';

import 'package:dart_sip_parser/sip_message_headers.dart';
import 'package:dart_sip_parser/sip_message_types.dart';

import 'globals.dart';
//import "SipMessage.dart";
import "sip_client.dart";
import "Session.dart";
import 'dart:io';

import 'dart:convert';
//import 'SipMessageTypes.dart';
//import 'SipSdpMessage.dart';
import 'package:dart_sip_parser/sip.dart';

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

class ReqHandler {
  int _serverPort;
  Map<String, SipClient> _clients = {};

  Map<String, sockaddr_in> transactions = {};
  Map<String, Function(SipMessage)> handlers = {};
  void Function(sockaddr_in, dynamic)? _onHandled;
  String _serverIp;
  ReqHandler(String serverIp, int serverPort, RawDatagramSocket socket)
      : _serverIp = serverIp,
        _serverPort = serverPort,
        this.socket = socket {
    // SipMessageTypes.REGISTER,
    // SipMessageTypes.CANCEL,
    // SipMessageTypes.INVITE,
    // SipMessageTypes.TRYING,
    // SipMessageTypes.RINGING,
    //   SipMessageTypes.BUSY,
    //   SipMessageTypes.UNAVAIALBLE,
    //   SipMessageTypes.OK,
    //   SipMessageTypes.ACK,
    //   SipMessageTypes.BYE,
    //   SipMessageTypes.REQUEST_TERMINATED,

    handlers[SipMessageTypes.REGISTER.toLowerCase()] = OnRegister;
    handlers[SipMessageTypes.CANCEL.toLowerCase()] = OnCancel;
    handlers[SipMessageTypes.REQUEST_TERMINATED.toLowerCase()] =
        onReqTerminated;
    handlers[SipMessageTypes.INVITE.toLowerCase()] = OnInvite;
    handlers[SipMessageTypes.TRYING.toLowerCase()] = OnTrying;
    handlers[SipMessageTypes.RINGING.toLowerCase()] = OnRinging;
    handlers[SipMessageTypes.BUSY.toLowerCase()] = OnBusy;
    handlers[SipMessageTypes.UNAVAIALBLE.toLowerCase()] = OnUnavailable;
    handlers[SipMessageTypes.BYE.toLowerCase()] = OnBye;
    handlers[SipMessageTypes.OK.toLowerCase()] = OnOk;
    handlers[SipMessageTypes.ACK.toLowerCase()] = OnAck;

    _sessions = {};

    // print("listening for events from ION SFU");
    // webSocket!.listen((event) {
    //   print("From SFU: $event");
    // });
  }

  void handle(SipMessage request, sockaddr_in protocol) {
    // print(request.getType());
    // print(request.Req.Method);

    // ignore: curly_braces_in_flow_control_structures
    if (request.Req.Method != null) {
      if (handlers[request.Req.Method!.toLowerCase()] != null) {
        //print(request.src);
        //var lines = request.src!.split(SipMessageHeaders.HEADERS_DELIMETER);
        //var lines = request.src!.split(SipMessageHeaders.HEADERS_DELIMETER);
        // print("Lines length: ${lines[8]}");
        //handlers[request.Req.Method!.toLowerCase()]!(request);
        proxy(request);
      }
    }
  }

  void proxy(SipMessage msg) {
    //socket.send(buffer, address, port)
    print(msg.Req.Method);
    //print(msg.src);
    //print("Branch: ${msg.Via[0].Branch}");

    //print("Message from: ${msg.transport!.addr}");

    if (msg.transport!.addr != "10.43.0.55") {
      //print("Message to: ${msg.transport!.addr}");
      transactions[msg.Via[0].Branch!] = msg.transport!;
      socket.send(msg.src!.codeUnits, InternetAddress("10.43.0.55"), 5080);
    } else {
      print("Branch: ${transactions[msg.Via[0].Branch!]!.addr}");
      //   socket.send(msg.src!.codeUnits, InternetAddress(msg.transport!.addr),
      //       msg.transport!.port);
      //   print("Message to: ${msg.transport!.addr}");
    }
    //endHandle(destNumber, message)
  }

  bool OnRegister(SipMessage data) {
    //print(data.src);
    print(data.Exp.Value);
    bool isUnregisterReq = data.Exp.Value!.contains("expires=0");

    if (!isUnregisterReq) {
      //print("Number ${data.getFromNumber()}");
      SipClient newClient = SipClient(data.From.User!, data.transport!);
      registerClient(newClient);
    }

    //SipMessage response = SipMessage(data.src!, data.getSource());
    SipMessage response = SipMessage();
    var rspString = data.src!;
    //response.Parse(data.src!);
    var lines = data.src!.split('\r\n');
    lines[0] = SipMessageTypes.OK;
    //print(data.To.Src);
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
    response.Req.Src = SipMessageTypes.OK;
    response.Via[0].Src = response.Via[0].Src!.replaceFirst(
        response.Via[0].Src!,
        "${response.Via[0].Src!};received=$_serverIp"); // "${response.Via[0].Src!};received=$_serverIp";
    response.To.Src = response.To.Src!.replaceFirst(response.To.Src!,
        "${response.To.Src!};tag=${IDGen()}"); // ";tag=" + IDGen());

    response.Contact.Src =
        "<sip:${data.From.User!}@$_serverIp:$_serverPort;transport=UDP>";
    // print(response.toString());
    //endHandle(response.getFromNumber(), response);

    if (isUnregisterReq) {
      SipClient newClient = SipClient(data.From.User!, data.transport!);
      unregisterClient(newClient);
    }

    return true;
  }

  SipClient? findClient(String number) {
    return _clients[number];
  }

  void endHandle(String destNumber, SipMessage message) {
    //SipClient destClient = findClient(destNumber);
    SipClient? destClient = _clients[destNumber];
    //print(destClient.getNumber());
    // ignore: unnecessary_null_comparison
    if (destClient != null) {
      print("${destClient.getAddress().addr}:${destClient.getAddress().port}");

      //_onHandled!(destClient.getAddress(), message);
      //print(message.getType());
      socket.send(
          message.toString().codeUnits,
          InternetAddress(destClient.getAddress().addr),
          destClient.getAddress().port);
    } else {
      message.Req.Src = SipMessageTypes.NOT_FOUND;
      //sockaddr_in src = message.getSource();
      try {
        //_onHandled!(src, message);
        // socket.send(
        //     message.toString().codeUnits, InternetAddress(src.addr), src.port);
      } catch (error) {
        print(error);
      }

      socket.send(
          message.toString().codeUnits,
          InternetAddress(destClient!.getAddress().addr),
          destClient.getAddress().port);
    }
  }

  void unregisterClient(SipClient client) {
    print("unregister client:  ${client.getNumber()}");
    _clients.remove(client.getNumber());
  }

  bool registerClient(SipClient client) {
    if (_clients[client.getNumber()] == null) {
      //print("New Client: ${client.getNumber()}");
      _clients[client.getNumber()] = client;

      //print(client.getAddress().addr);
      return true;
    } else {
      _clients[client.getNumber()] = client;
      // print(
      //     "${_clients[client.getNumber()]!.getAddress().addr}:${_clients[client.getNumber()]!.getAddress().port}");
      return true;
    }
    return false;
  }

  Session? getSession(String callID) {
    return _sessions![callID];
  }

  bool OnCancel(dynamic data) {
    setCallState(data.getCallID(), State.Cancel);
    endHandle(data.getToNumber(), data);
    return true;
  }

  bool onReqTerminated(dynamic data) {
    endHandle(data.getFromNumber(), data);
    return true;
  }

  bool OnInvite(dynamic data) {
    // Check if the caller is registered
    //SipClient caller = findClient(data.getFromNumber());
    SipClient? caller = _clients[data.getFromNumber()];

    if (caller == null) return true;

    // print("Caller is: ${caller.getNumber()}");

    // if (caller.getNumber() == "") {
    //   //print("Caller is: ${caller.getNumber()}");
    //   print("Caller not registered");
    //   return true;
    // } else {
    //   print("Caller is: ${caller.getNumber()}");
    // }

    //print("Callee is: ${data.getToNumber()}");
    // Check if the called is registered
    //SipClient called = findClient(data.getToNumber());
    SipClient? called = _clients[data.getToNumber()];
    String strMsg = data.src!;
    // SipMessage trying = SipMessage(strMsg, data.getSource());
    SipMessage trying = SipMessage();
    trying.Parse(strMsg);

    trying.Req.Src = SipMessageTypes.TRYING;
    //trying.setHeader(SipMessageTypes.TRYING);
    //endHandle(trying.getFromNumber(), trying);

    // print("Callee is: ");
    // print("Callee is: ${called.getNumber()}");

    // print(called.getNumber());
    if (called == null) {
      print("Callee is: ${data.getToNumber()} is not registered");
      //print(data.src!);

      int sdpDelimitor = strMsg.indexOf(SipMessageHeaders.HEADERS_DELIMETER +
          SipMessageHeaders.HEADERS_DELIMETER);
      //print("Sdp delimiter: $sdpDelimitor");
      String sdp = strMsg.substring(sdpDelimitor + 4);
      //print(sdp);

      // var jsonRpcReq = {
      //   "jsonrpc": "2.0",
      //   "method": "request",
      //   "params": {
      //     "sid": "defaultroom",
      //     "offer": {"type": "offer", "sdp": sdp}
      //   }
      // };
      var jsonRpcReq = {
        "jsonrpc": "2.0",
        "method": "join",
        "params": {
          "sid": "defaultroom",
          "offer": {"type": "offer", "sdp": sdp}
          //"offer": sdp
        },
        "id": 1
      };
      print("Sending offer to sfu");
      webSocket!.add(jsonEncode(jsonRpcReq));
      // print(jsonRpcReq);

      //ion_sfu.add(jsonEncode(jsonRpcReq));
      // Send "SIP/2.0 404 Not Found"
      data.setHeader(SipMessageTypes.NOT_FOUND);
      data.setContact(
          "Contact: <sip: ${caller.getNumber()}@ _serverIp + :$_serverPort;transport=UDP>");

      print(data.getType());
      endHandle(data.getFromNumber(), data);

      // socket.send(data.src!.codeUnits,
      //     InternetAddress(caller.getAddress().addr), caller.getAddress().port);
      return true;
    }

    //SipSdpMessage message = SipSdpMessage(data.src!, data.getSource());
    SipMessage message = SipMessage();
    //if (!message.isValidMessage()) {
    // print(
    //    "Couldn't get SDP from ${data.getFromNumber()}'s INVITE request."); //<< std::endl;
    //return true;
    //}
    print("Creating session");
    // Session newSession =
    //     Session(data.getCallID(), caller, message.getRtpPort());
    // _sessions?[data.getCallID()] = newSession;
    print("Session created");
    //SipMessage response = SipMessage(data.src!, caller.getAddress());
    SipMessage response = SipMessage();
    response.Parse(data.src!);
    print("Setting call dialog");
    // response.setContact(
    //     "Contact: <sip:${caller.getNumber()}@$_serverIp:$_serverPort;transport=UDP>");

    response.Contact.Src =
        "Contact: <sip:${caller.getNumber()}@$_serverIp:$_serverPort;transport=UDP>";

    print("Setting call dialog after response");
    endHandle(data.getToNumber(), response);

    return true;
  }

  bool OnTrying(dynamic data) {
    endHandle(data.getFromNumber(), data);
    return true;
  }

  bool OnRinging(dynamic data) {
    endHandle(data.getFromNumber(), data);
    return true;
  }

  bool OnBusy(dynamic data) {
    setCallState(data.getCallID(), State.Busy);
    endHandle(data.getFromNumber(), data);

    return true;
  }

  bool OnUnavailable(dynamic data) {
    setCallState(data.getCallID(), State.Unavailable);
    endHandle(data.getFromNumber(), data);

    return true;
  }

  bool OnBye(dynamic data) {
    setCallState(data.getCallID(), State.Bye);
    endHandle(data.getToNumber(), data);
    return true;
  }

  bool OnOk(dynamic data) {
    print("Get ok");
    Session? session = getSession(data.getCallID());

    if (session != null) {
      print("Getting state...");
      State? state = session.getState();

      if (state != null) {
        print("Session state: $state");
      } else {
        print("Sate is null");
      }

      print("State gotten");
      if (state == State.Cancel) {
        endHandle(data.getFromNumber(), data);

        print("exiting ok");
        return true;
      }
      print("Test session");
      if (data.getCSeq().indexOf(SipMessageTypes.INVITE) != -1) {
        SipClient? client = findClient(data.getToNumber());
        if (client == null) {
          print("No client");
          return true;
        }

        // SipMessage sdpMessage =
        //     SipSdpMessage(data.src!, data.getSource());

        SipMessage sdpMessage = SipMessage();
        sdpMessage.Parse(data.src!);

        // if (!sdpMessage.isValidMessage()) {
        //   print("Coudn't get SDP from: ${client.getNumber()} 's OK message.");
        //   endCall(data.getCallID(), data.getFromNumber(), data.getToNumber(),
        //       "SDP parse error.");

        //   print("exiting ok");
        //   return true;
        // }
        print("Performing last operation");
        //session.setDest(client, sdpMessage.getRtpPort());
        session.setState(State.Connected);
        SipMessage response = SipMessage();
        response.Parse(
            data.toString()); //= SipMessage(data.src!, client.getAddress());
        // response.setContact("Contact: <sip:" +
        //     data.getToNumber() +
        //     "@" +
        //     _serverIp +
        //     ":" +
        //     _serverPort.toString() +
        //     ";transport=UDP>");

        response.ContType.Src = "Contact: <sip:" +
            data.getToNumber() +
            "@" +
            _serverIp +
            ":" +
            _serverPort.toString() +
            ";transport=UDP>";

        print("exiting ok");
        endHandle(data.getFromNumber(), response);
        return true;
      }

      if (session.getState() == State.Bye) {
        endHandle(data.getFromNumber(), data);
        endCall(data.getCallID(), data.getToNumber(), data.getFromNumber(),
            State.Bye as String);
      }
    }
    print("end of ok");
    return true;
  }

  void OnAck(dynamic data) {
    Session? session = getSession(data.getCallID());
    if (session != null) {
      return;
    }

    endHandle(data.getToNumber(), data);

    State? sessionState = session!.getState();
    String endReason;
    if (sessionState == State.Busy) {
      endReason = data.getToNumber() + " is busy.";
      endCall(data.getCallID(), data.getFromNumber(), data.getToNumber(),
          endReason);
      return;
    }

    if (sessionState == State.Unavailable) {
      endReason = data.getToNumber() + " is unavailable.";
      endCall(data.getCallID(), data.getFromNumber(), data.getToNumber(),
          endReason);
      return;
    }

    if (sessionState == State.Cancel) {
      endReason = data.getFromNumber() + " canceled the session.";
      endCall(data.getCallID(), data.getFromNumber(), data.getToNumber(),
          endReason);
      return;
    }
  }

  bool setCallState(String callID, State state) {
    Session? session = getSession(callID);
    if (session != null) {
      session.setState(state);
      return true;
    }

    return false;
  }

  void endCall(
      String callID, String srcNumber, String destNumber, String reason) {
    _sessions!.remove(callID);
    // _sessions.remove(callID)
    // {
    String message =
        "Session has been disconnected between $srcNumber and $destNumber";
    if (reason.isNotEmpty) {
      message += " because $reason";
    }
    // print(message);
    //}
  }

  RawDatagramSocket socket;
  Map<String, Session>? _sessions;
  //WebSocket ion_sfu;
}
