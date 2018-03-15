from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager,PermissionsMixin

# for token auth
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)

# from mongoengine import *
# Create your models here.

class UserManager(BaseUserManager):
    
    def create_user(self, name, email, password):
        """
        Creates and saves a User with the given email and password.
        """
        if not email:
            raise ValueError('The given email must be set')
        email = self.normalize_email(email)
        user = self.model(email=email,name=name)
        user.set_password(password)
        user.save(using=self._db)
        return user

class User(AbstractBaseUser):
	name = models.CharField(max_length=200)
	email = models.EmailField( ('email address'), max_length=254, unique=True, db_index=True, blank=True)
	USERNAME_FIELD = 'email'
	objects = UserManager()
       

