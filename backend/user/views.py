from django.shortcuts import render
from .models import User
from django.http import HttpResponse  # HttpResponse is how we send
import json                           # Converts to json
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
def index(request):

	if request.method == "POST":
		some_json = {
			'response': 'POST recieved!',
		}
	elif request.method == "GET":
		some_json = {
			'response': 'GET recieved!',
		}

	data = json.dumps(some_json)
  # Return JSON and let it know its json
	return HttpResponse(data, content_type='application/json')



@csrf_exempt
def register(request):
	if request.method == "POST":
		user = User.objects.get(name=request.POST.get('name',''))
		print(user)
		user = User.objects.create(
			name=request.POST.get('name',''),
			email=request.POST.get('email',''),
			password=request.POST.get('password',''),
			)

		user.save()

		res = {
			'response' : 'POST received!'
		}

	else :
		res = {
			'response' : 'GET recived when POST was expected'
		}

	data = json.dumps(res)
	return HttpResponse(data, content_type='application/json')


@csrf_exempt
def login(request):
	if request.method == "POST":
		user = User.objects.get(name=request.POST.get('name',''))

		if user.password == request.POST.get('password',''):
			res = {
				'response' : 'Account Found!'
			}
		else:
			res = {
				'response' : 'Account not found'
			}

	elif request.method == "GET":
		res = {
			'response' : 'GET recived when POST was expected'
		}

	data = json.dumps(res)
	return HttpResponse(data, content_type='application/json')



		