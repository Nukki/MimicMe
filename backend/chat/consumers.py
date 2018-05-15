from django.conf import settings
from django.contrib.auth.models import User
from .models import Room
import numpy as np
import pickle
import tensorflow as tf
from .utils import *

import asyncio
import os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

#TODO remove global variable for numbots and make part of room model


from channels.generic.websocket import AsyncJsonWebsocketConsumer

#TODO Look into options

# Consumer class is instantiated for every websocket connection
# Consumers connect to other consumers through the group_add over the
# Channel layer
class ChatConsumer(AsyncJsonWebsocketConsumer):


    # Called upon ws://chat/stream connection
    async def connect(self):
        await self.accept()


    # Called when a message is sent from client to the server
    #
    async def receive_json(self, content):
        # Get command to select routine
        print(content)
        command = content.get("command", None)

        if command == "join":
            await self.join_room(content["room"], content["username"], content["uid"])

        elif command == "send":
            await self.send_room(content["room"], content["message"], content["username"])



    # called when the socket closes
    async def disconnect(self,close_code):
        print('close')



    async def join_room(self, roomId, uname, uid):

        room = Room.objects.get(pk=roomId) # "room" is the room id

        if not room:
            print("Room not found")
            await self.send_json({
                "status": "Failed"
            })
            await self.close()
            return

        user = User.objects.get(username=uname)
        self.user = user
        if user.id is not uid:
            print("User id not found")
            await self.send_json({
                "status": "Failed"
            })
            await self.close()
            return

        # TODO what do with async_to_sync
        # Add them to the group so they get room messages
        await self.channel_layer.group_add(
            room.group_name,
            self.channel_name,
        )
        # Instruct their client to finish opening the room
        # Note: mobile apps may need different information
        await self.send_json({
            "join": room.id,
            "name": room.name,
        })

    async def send_room(self, roomId, message, username):
        room = Room.objects.get(pk=roomId)


        await self.self_send(roomId, username, message)
        # send message to room
        await self.channel_layer.group_send(
            room.group_name,
            {
            "type": "chat.message",
            "room_id": roomId,
            "username": username,
            "message": message,
            "origin" : username,
            }
        );

        # Create list of all predicted responses
        response = []
        totallen = 0
        for i in range(numbots):
            msg = model[str(i)](str(message))
            response.append((len(msg), msg))
            totallen += len(msg)



        #sort responses based on length
        response.sort(reverse=True)
        i = 1
        while totallen > 0:
            msg = response.pop()
            await asyncio.sleep(msg[0]*.05)
            print(msg)

            await self.self_send(roomId, "bot"+str(i), msg[1])
            await self.channel_layer.group_send(
                room.group_name,
                {
                "type": "chat.message",
                "room_id": roomId,
                "username": "bot" + str(i),
                "message": msg[1],
                "origin": username,
                }
            );
            i +=1
            totallen -= msg[0]


    async def self_send(self, roomId, username, message):
        await self.send_json(
            {
                # "msg_type": settings.MSG_TYPE_MESSAGE,
                "room": roomId,
                "username": username,
                "message": message,
            },
        )

            ##### Handlers for messages sent over the channel layer

    # These helper methods are named by the types we send - so chat.join becomes chat_join
    async def chat_join(self, event):

        # Called when someone has joined our chat.

        # Send a message down to the client
        await self.send_json(
            {
                "room": event["room_id"],
                # "username": event["username"],
            },
        )

    async def chat_leave(self, event):

        # Called when someone has left a chat room.

        # Send a message down to the client
        await self.send_json(
            {
                "room": event["room_id"],
                # "username": event["username"],
            },
        )

    async def chat_message(self, event):

        # Called when someone has messaged our chat.

        # Send a message down to the client
        if event["origin"] == self.user.username:
            return
        else:
            print(event["message"])
            await self.send_json(
                {
                    # "msg_type": settings.MSG_TYPE_MESSAGE,
                    "room": event["room_id"],
                    "username": event["username"],
                    "message": event["message"],
                },
            )
