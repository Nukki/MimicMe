from django.conf import settings
from django.contrib.auth.models import User
from .models import Room
import numpy as np
import pickle
import tensorflow as tf
from .utils import delay
# issue with peramertizing Model file will port as two seperate files
# we can get around the inconveneince of this by having a dict of which module
# to select
import chat.model_0 as mod_0
# import chat.model_1 as mod_1

import asyncio
import os

from asgiref.sync import async_to_sync # to keep sync functions sync
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'


model = {
        "0": mod_0.pred,
        # "1": mod_1.pred,
    }

from channels.generic.websocket import JsonWebsocketConsumer

#TODO Look into options

# Consumer class is instantiated for every websocket connection
# 3 main functions (connect, receive_json, disconnect)
class MyConsumer(JsonWebsocketConsumer):


    # Called upon ws://chat/stream connection
    def connect(self):
        # print(self.scope["user"])
        # if self.scope["user"].is_anonymous:
        #     print("user not logged")
        #     # reject if user isnt logged in
        #     self.close()
        # else:
        #     print("user found")
        #     # accept
        #     self.accept()
        self.accept()


    # Called when a message is sent from client to the server
    def receive_json(self, content):
        print(content)
        # Get command to select routine
        command = content.get("command", None)

        if command == "join":
            self.join_room(content["room"], content["username"], content["uid"])

        elif command == "send":
            self.send_room(content["room"], content["message"])



    # called when the socket closes
    def disconnect(self,close_code):
        print('close')



    def join_room(self, roomId, uname, uid):

        room = Room.objects.get(pk=roomId) # "room" is the room id

        user = User.objects.get(username=uname)

        if user.id is not uid:
            print("User id not found")
            self.send_json({
                "status" : "Failed"
            })
            return


        # Add them to the group so they get room messages
        async_to_sync(self.channel_layer.group_add)(
            room.group_name,
            self.channel_name,
        )
        # Instruct their client to finish opening the room
        # Note: mobile apps may need different information
        self.send_json({
            "join": str(room.id),
            "name": room.name,
        })

    def send_room(self, roomId, message):
        room = Room.objects.get(pk=roomId)

        # send message to room
        async_to_sync(self.channel_layer.group_send)(room.group_name, {
            "type": "chat.message",
            "room_id" : roomId,
            "username": self.scope["user"].username,
            "message" : message,
        });

        # bot id's will be retreived from room object
        # formulate model response
        response =  model["0"](str(message))
        delay(message)
        # send that response to the room
        async_to_sync(self.channel_layer.group_send)(room.group_name, {
            "type": "chat.message",
            "room_id" : roomId,
            "username": "bot0",
            "message" : response,
        });

        # response =  mod_1.pred(str(message))
        #
        # async_to_sync(self.channel_layer.group_send)(room.group_name, {
        #     "type": "chat.message",
        #     "room_id" : roomId,
        #     "username": "bot1",
        #     "message" : response,
        # });


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
