from django.shortcuts import render
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.contrib.auth import login as auth_login
from django.http import HttpResponseServerError # let front end know about server error
from django.http import HttpResponseBadRequest # let front end know about client side error
from django.http import HttpResponse  # HttpResponse is how we send
import json                           # Converts to json
from django.views.decorators.csrf import csrf_exempt




# A simple test function to check GET and POST functionality
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
# user = User.objects.create_user('john', 'lennon@thebeatles.com', 'johnpassword')
@csrf_exempt
def register(request):
	if request.method == "POST":

		# parse the raw request body from bytes to unicode string
		body_unicode = request.body.decode('utf-8')
		body = json.loads(body_unicode)

        # request contains raw JSON, it's not form-data formatted
		# in request.POST form-data JSON is found, raw JSON is attached in request.body
		# with raw JSON request.POST is always empty
		if User.objects.filter(email=body['email']).exists():
			res = {	'response' : 'Email already in use' }
			data = json.dumps(res)
			return HttpResponseBadRequest(data, content_type='application/json') # error, send 400 status

		user = User.objects.create_user(
			body['name'],
			body['email'],
			body['password'],)
		# user.save()
		res = {	'response' : 'New user created' } #success, send 201 status
		data = json.dumps(res)
		return HttpResponse(data, content_type='application/json',status=201, reason='created' )


	else :
		res = { 'response' : 'GET recived when POST was expected' } #error

	data = json.dumps(res)
	return HttpResponseBadRequest(data, content_type='application/json') # error, send 400 status



@csrf_exempt
def login(request):
	if request.method == "POST":

		# parse the raw request body from bytes to unicode string
		body_unicode = request.body.decode('utf-8')
		body = json.loads(body_unicode)



		user = authenticate(username=body['name'], password=body['password'])
		if user is not None:
			auth_login(request, user)
			res = { 'response' : 'Login success!',
			 		'UID' : user.id} # success, send 200 status
			data = json.dumps(res)
			print(user.id)
			return HttpResponse(data, content_type='application/json')
		    # A backend authenticated the credentials
		else:
			res = {'response' : 'Account not found. User does not exist'}
			data = json.dumps(res)
			return HttpResponseServerError(data, content_type='application/json') # error, send 500 status


	elif request.method == "GET":
		res = { 'response' : 'GET recived when POST was expected' }

	data = json.dumps(res)
	return HttpResponseBadRequest(data, content_type='application/json') # error, send 400 status
