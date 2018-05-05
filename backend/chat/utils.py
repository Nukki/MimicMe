import time
from random import randint

def delay(length):
    timelen = randint(length, length+6)
    time.sleep(timelen* .5)
