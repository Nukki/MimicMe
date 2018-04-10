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


class MyConsumer(JsonWebsocketConsumer):
    # groups = ["broadcast"]

    def connect(self):


        # Called on connection. Either call
        self.accept()
        # Or to reject the connection, call
        # self.close()


    def receive_json(self, content):

        print(content)

        command = content.get("command", None)

        if command == "join":
            room = Room.objects(pk=content["room"])[0]
            print(room.name)
            # Add them to the group so they get room messages
            # link room to
            async_to_sync(self.channel_layer.group_add)(
                room.name,
                self.channel_name,
            )
            # Instruct their client to finish opening the room
            self.send_json({
                "join": content["room"],
                "title": room.name,
            })



        elif command == "send":
            room = Room.objects(pk=content["room"])[0]
            print("test")
            message = content["message"]

            async_to_sync(self.channel_layer.group_send)(room.name, {
                "type": "chat.message",
                "room_id" : content["room"],
                "username": "human",
                "message" : message,
            });

            response =  mod.pred(str(message))

            async_to_sync(self.channel_layer.group_send)(room.name, {
                "type": "chat.message",
                "room_id" : content["room"],
                "username": "bot",
                "message" : response,
            });






    def disconnect(self,close_code):
        print('close')
        # self.close()
        # Called when the socket closes




            ##### Handlers for messages sent over the channel layer

    # These helper methods are named by the types we send - so chat.join becomes chat_join
    def chat_join(self, event):
        """
        Called when someone has joined our chat.
        """
        # Send a message down to the client
        self.send_json(
            {
                "room": event["room_id"],
                # "username": event["username"],
            },
        )

    def chat_leave(self, event):
        """
        Called when someone has left our chat.
        """
        # Send a message down to the client
        self.send_json(
            {
                "room": event["room_id"],
                # "username": event["username"],
            },
        )

    def chat_message(self, event):
        """
        Called when someone has messaged our chat.
        """
        # Send a message down to the client
        self.send_json(
            {
                # "msg_type": settings.MSG_TYPE_MESSAGE,
                "room": event["room_id"],
                "username": event["username"],
                "message": event["message"],
            },
        )
