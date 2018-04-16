from django.conf import settings
from .models import Room
import numpy as np
import pickle
import tensorflow as tf
import chat.model as mod
import os

from asgiref.sync import async_to_sync # to keep sync functions sync
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'



from channels.generic.websocket import JsonWebsocketConsumer

#TODO Look into options

# Consumer class is instantiated for every websocket connection
# 3 main functions (connect, receive_json, disconnect)
class MyConsumer(JsonWebsocketConsumer):
    # Called upon ws://chat/stream connection
    def connect(self):
        self.accept()
        # self.close()

    # Called when a message is sent from client to the server
    def receive_json(self, content):
        print(content)
        # Get command to select routine
        command = content.get("command", None)

        if command == "join":
            self.join_room(content["room"])

        elif command == "send":
            self.send_room(content["room"], content["message"])




    # called when the socket closes
    def disconnect(self,close_code):
        print('close')



    def join_room(self, roomId):

        room = Room.objects.get(pk=roomId) # "room" is the room id
        # print(room.name)
        # Add them to the group so they get room messages
        # link room to
        async_to_sync(self.channel_layer.group_add)(
            room.group_name,
            self.channel_name,
        )
        # Instruct their client to finish opening the room
        self.send_json({
            "join": str(room.id),
            "name": room.name,
        })

    def send_room(self, roomId, message):
        room = Room.objects.get(pk=roomId)

        async_to_sync(self.channel_layer.group_send)(room.group_name, {
            "type": "chat.message",
            "room_id" : roomId,
            "username": "human",
            "message" : message,
        });

        response =  mod.pred(str(message))

        async_to_sync(self.channel_layer.group_send)(room.group_name, {
            "type": "chat.message",
            "room_id" : roomId,
            "username": "bot",
            "message" : response,
        });




            ##### Handlers for messages sent over the channel layer

    # These helper methods are named by the types we send - so chat.join becomes chat_join
    def chat_join(self, event):

        # Called when someone has joined our chat.

        # Send a message down to the client
        self.send_json(
            {
                "room": event["room_id"],
                # "username": event["username"],
            },
        )

    def chat_leave(self, event):

        # Called when someone has left our chat.

        # Send a message down to the client
        self.send_json(
            {
                "room": event["room_id"],
                # "username": event["username"],
            },
        )

    def chat_message(self, event):

        # Called when someone has messaged our chat.

        # Send a message down to the client
        self.send_json(
            {
                # "msg_type": settings.MSG_TYPE_MESSAGE,
                "room": event["room_id"],
                "username": event["username"],
                "message": event["message"],
            },
        )
