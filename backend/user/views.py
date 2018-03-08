from django.shortcuts import render
from .models import User
from django.http import HttpResponse  # HttpResponse is how we send
import json                           # Converts to json
from django.views.decorators.csrf import csrf_exempt

# TODO: csrf_exempt needs to be remedied before we move closer to production
#		Implement trimming and escaping for POST

# We use res to generate a response to send back to the client


# A simple text function to check GET and POST functionality
@csrf_exempt
def index(request):

	if request.method == "POST":
		res = { 'response': 'POST recieved!' }
	elif request.method == "GET":
		res = { 'response': 'GET recieved!'}

	data = json.dumps(res)
  # Return JSON and let it know its json
	return HttpResponse(data, content_type='application/json')


# Input : name, email, password
@csrf_exempt
def register(request):
	if request.method == "POST":
		user = User.objects(name=request.POST.get('name',''))
		if user:
			res = {	'response' : 'name already exists' }
			data = json.dumps(res)
			return HttpResponse(data, content_type='application/json')

		user = User.objects.create(
			name=request.POST.get('name',''),
			email=request.POST.get('email',''),
			password=request.POST.get('password',''),
			)

		user.save()

		res = {	'response' : 'POST received!' }

	else :
		res = { 'response' : 'GET recived when POST was expected' }

	data = json.dumps(res)
	return HttpResponse(data, content_type='application/json')



@csrf_exempt
def login(request):
	if request.method == "POST":
		user = User.objects.get(name=request.POST.get('name',''))

		if user.password == request.POST.get('password',''):
			res = { 'response' : 'Account Found!' }

		else:
			res = { 'response' : 'Account not found' }

	elif request.method == "GET":
		res = { 'response' : 'GET recived when POST was expected' }

	data = json.dumps(res)
	return HttpResponse(data, content_type='application/json')



		