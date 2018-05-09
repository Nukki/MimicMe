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

    rooms = Room.objects.order_by("name")
    res = []
    for room in rooms:
        print(room.bots)
        res.append({"name": room.name, "id": room.id})
    data = json.dumps(res)
    # turn into HTTp response and send json of all the rooms
    # Render that in the index template
    # return render(request, "index.html", {
    #     "rooms": rooms
    # })
    return HttpResponse(data, content_type='application/json',status=200)





# Function to handle GET and POST request for room creation
# GET: Send a list of bots in json format {name, id}
#       hardcoded for not but TODO: make modular
# POST: Recieve name of room
#       and list of bots by id
#       Generate new room object
@csrf_exempt
def create(request):
    if request.method == "GET":
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)

        bots = [{"name": "Tensorflow-dataset2", "id": "0"},
                {"name": "Tensorflow-dataset1", "id": "1"}]
        data = json.dumps(bots)

        return HttpResponse(data, content_type='application/json', status=200)

    elif request.method == "POST":
        print("Post recieved!")

        # parse raw to usable format
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        # print(bots)
        room =  Room.objects.create(
            name=body['name'],
            bots=body['bots']
        )

        room.save()

        res = {	'response' : 'New room created' } #success, send 201 status
        data = json.dumps(res)
        return HttpResponse(data, content_type='application/json',status=201, reason='created' )


# def room(request):
