import "dart:core";
import 'dart:ffi';
import 'dart:math';

import 'globals.dart';
//import "SipMessage.dart";
import "sip_client.dart";
import "Session.dart";
import 'dart:io';

import 'dart:convert';
import 'addr_port.dart';
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
  Map<String, Function(dynamic data)> handlers = {};
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

  void handle(dynamic request) {
    // print(request.getType());
    if (handlers[request.getType().toLowerCase()] != null) {
      // print(request.getType());
      try {
        handlers[request.getType().toLowerCase()]!(request);
      } catch (error) {
        // print(error);
      }
    }
  }

  bool OnRegister(dynamic data) {
    bool isUnregisterReq = data.getContact().indexOf("expires=0") != -1;

    if (!isUnregisterReq) {
      //print("Number ${data.getFromNumber()}");
      SipClient newClient = SipClient(data.getFromNumber(), data.getSource());
      registerClient(newClient);
    }

    SipMessage response = SipMessage(data.toString(), data.getSource());
    response.setHeader(SipMessageTypes.OK);
    response.setVia(data.getVia() + ";received=" + _serverIp);
    response.setTo(data.getTo() + ";tag=" + IDGen());
    response.setContact("Contact: <sip:" +
        data.getFromNumber() +
        "@" +
        _serverIp +
        ":" +
        _serverPort.toString() +
        ";transport=UDP>");

    // print(response.toString());
    endHandle(response.getFromNumber(), response);

    if (isUnregisterReq) {
      SipClient newClient = SipClient(data.getFromNumber(), data.getSource());
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
      print(message.getType());
      socket.send(
          message.toString().codeUnits,
          InternetAddress(destClient.getAddress().addr),
          destClient.getAddress().port);
    } else {
      message.setHeader(SipMessageTypes.NOT_FOUND);
      sockaddr_in src = message.getSource();
      try {
        //_onHandled!(src, message);
        socket.send(
            message.toString().codeUnits, InternetAddress(src.addr), src.port);
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
    String strMsg = data.toString();
    SipMessage trying = SipMessage(strMsg, data.getSource());

    trying.setHeader(SipMessageTypes.TRYING);
    endHandle(trying.getFromNumber(), trying);

    // print("Callee is: ");
    // print("Callee is: ${called.getNumber()}");

    // print(called.getNumber());
    if (called == null) {
      print("Callee is: ${data.getToNumber()} is not registered");
      //print(data.toString());

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

      // socket.send(data.toString().codeUnits,
      //     InternetAddress(caller.getAddress().addr), caller.getAddress().port);
      return true;
    }

    SipSdpMessage message = SipSdpMessage(data.toString(), data.getSource());
    if (!message.isValidMessage()) {
      print(
          "Couldn't get SDP from ${data.getFromNumber()}'s INVITE request."); //<< std::endl;
      return true;
    }
    print("Creating session");
    Session newSession =
        Session(data.getCallID(), caller, message.getRtpPort());
    _sessions?[data.getCallID()] = newSession;
    print("Session created");
    SipMessage response = SipMessage(data.toString(), caller.getAddress());
    print("Setting call dialog");
    response.setContact(
        "Contact: <sip:${caller.getNumber()}@$_serverIp:$_serverPort;transport=UDP>");

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

        SipSdpMessage sdpMessage =
            SipSdpMessage(data.toString(), data.getSource());
        if (!sdpMessage.isValidMessage()) {
          print("Coudn't get SDP from: ${client.getNumber()} 's OK message.");
          endCall(data.getCallID(), data.getFromNumber(), data.getToNumber(),
              "SDP parse error.");

          print("exiting ok");
          return true;
        }
        print("Performing last operation");
        session.setDest(client, sdpMessage.getRtpPort());
        session.setState(State.Connected);
        SipMessage response = SipMessage(data.toString(), client.getAddress());
        response.setContact("Contact: <sip:" +
            data.getToNumber() +
            "@" +
            _serverIp +
            ":" +
            _serverPort.toString() +
            ";transport=UDP>");

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
