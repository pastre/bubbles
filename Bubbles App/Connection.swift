////
////  Connection.swift
////  Bubbles App
////
////  Created by APPLE DEVELOPER ACADEMy on 17/04/19.
////  Copyright © 2019 pastre. All rights reserved.
////
//
//import Foundation
//import Socket
//
//protocol ConnectionDelegate{
//    func onMessageRecvd(message: Data)
//}
//
//class Connection{
//    var socket: Socket!
//    var delegate: ConnectionDelegate?
//    
//    init() {
//        do {
//            self.socket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
//        } catch let error {
//            print("Failed instantiating connection", error.localizedDescription)
//        }
//    }
//    
//    func connect(){
//        DispatchQueue.main.async {
//            self.doConnect()
//        }
//    }
//    
//    func listen(){
//        DispatchQueue.main.async {
//            self.doListen()
//        }
//    }
//    
//    func send(data: Data){
//        DispatchQueue.main.async {
//            self.doSend(data: data)
//        }
//    }
//    
//    func doConnect(){
//        repeat{
//            do{
//                try self.socket.connect(to: "", port: 1337)
//            }catch let error{
//                print("Failed on connection", error.localizedDescription)
//            }
//        }while !self.socket.isConnected
//    }
//    
//    func doSend(data: Data){
//        if !self.socket.isConnected {return}
//        do {
//            try self.socket.write(from: data)
//        } catch let error {
//            print("Error on sending", error.localizedDescription)
//        }
//    }
//    
//    func doListen(){
//        do {
//            try self.socket.listen(on: 1337)
//            repeat{
//                var data = Data(capacity: 1024)
//                let readSize = try socket.read(into: &data)
//                if readSize > 0{
//                    let asString = String(bytes: data, encoding: .utf8)
//                    print("Got data: ", asString)
//                    self.delegate?.onMessageRecvd(message: data)
//                }else{
//                    print("Sem dado, irmao")
//                    self.socket.close()
//                }
//            }while true
//        } catch let error {
//            print("Failed on listening", error.localizedDescription)
//        }
//        
//    }
//    
//    
//}
