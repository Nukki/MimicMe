from django.shortcuts import render
from .models import Room
from django.http import HttpResponseServerError # let front end know about server error
from django.http import HttpResponseBadRequest # let front end know about client side error
from django.http import HttpResponse  # HttpResponse is how we send
import json                           # Converts to json
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required




@csrf_exempt
def index(request):

    rooms = Room.objects

    # turn into HTTp response and send json of all the rooms
    # Render that in the index template
    return render(request, "index.html", {
        "rooms": rooms
    })




# Recive post request
@csrf_exempt
def create(request):
    if request.method == "POST":
        print("Post recieved!")

        # parse raw to usable format
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)

        room =  Room.objects.create(
            name=body['name']
        )

        room.save()

        res = {	'response' : 'New room created' } #success, send 201 status
        data = json.dumps(res)
        return HttpResponse(data, content_type='application/json',status=201, reason='created' )


# def room(request):
