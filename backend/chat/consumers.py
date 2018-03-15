from django.conf import settings
# from backend.auth_token import rest_token_user
from channels.generic.websocket import JsonWebsocketConsumer
from backend.auth_token import RestTokenConsumerMixin


class MyConsumer(RestTokenConsumerMixin,JsonWebsocketConsumer):
    groups = ["broadcast"]

    # @rest_token_user
    def connect(self):
        # Called on connection. Either call
        print("ooooo ",self.scope['headers'])
        # print("ooooo ",self.user)
        self.accept()
        # Or to reject the connection, call
        # self.close()
     

    def receive_json(self, content):

        message = content["message"]
        # print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  ", message)
        self.send_json({
            "type": "websocket.message",
            "message" : message + " works",
            })



    
 
    def disconnect(self,message):
        self.close()
        # Called when the socket closes
