from django.db import models


class Room(models.Model):
    # Room name
    name = models.CharField(max_length=255)

    def __str__(self):
        return self.name

    @property
    def group_name(self):

        """
        Returns the Channels Group name that sockets should subscribe to to get sent
        messages as they are generated.
        """
        return "room-%s" % self.id
