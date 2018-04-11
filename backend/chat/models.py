from mongoengine import *

#TODO assess character cap on messange length

# attributes
#   name
#   chat history
#   bot(?)
class Room(Document):
    name = StringField(max_length=20)
    history = ListField(StringField(max_length=200))
