from django.db import models
import json

class Room(models.Model):
    # Room name
    name = models.CharField(max_length=255)
    # bots = models.ListCharField(base_field=CharField(max_length=2),
    #     size=6,
    #     max_length=(6 * 11)  # 6 * 10 character nominals, plus commas
    # )

    bots = models.CharField(max_length=200,default='[0]')

    def set_bots(self, x):
        self.bots = json.dumps(x)

    def get_bots(self):
        return json.loads(self.bots)


    def __str__(self):
        return self.name

    @property
    def group_name(self):

        """
        Returns the Channels Group name that sockets should subscribe to to get sent
        messages as they are generated.
        """
        return "room-%s" % self.id
