from django.conf import settings

from channels.generic.websocket import JsonWebsocketConsumer


class MyConsumer(JsonWebsocketConsumer):
    groups = ["broadcast"]

    def connect(self):
        # Called on connection. Either call
        self.accept()
        # Or to reject the connection, call
        # self.close()
     

    def receive_json(self, content):

        message = content["message"]
        self.send_json({
            "type": "websocket.message",
            "message" : message + " works",
            })



    
 
    def disconnect(self):
        self.close()
        # Called when the socket closes
