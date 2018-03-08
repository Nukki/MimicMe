# from django.db import models
from mongoengine import *
# Create your models here.

class User(Document):
	name = StringField(max_length=200)
	email = StringField(max_length=200)
	password = StringField(max_length=200)
