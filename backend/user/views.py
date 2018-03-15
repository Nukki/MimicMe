from django.shortcuts import render
from django.contrib.auth.models import User
from django.http import HttpResponseServerError # let front end know about server error
from django.http import HttpResponseBadRequest # let front end know about client side error
from django.http import HttpResponse  # HttpResponse is how we send
import json                           # Converts to json
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view #helps token auth

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

		# parse the raw request body from bytes to unicode string
		body_unicode = request.body.decode('utf-8')
		body = json.loads(body_unicode)
		

        # request contains raw JSON, it's not form-data formatted
		# in request.POST form-data JSON is found, raw JSON is attached in request.body
		# with raw JSON request.POST is always empty
		try:
			user = User.objects.get(email=body['email'])
			if user:
				res = {	'response' : 'Email already in use' }
				data = json.dumps(res)
				return HttpResponseBadRequest(data, content_type='application/json') # error, send 400 status
		except User.DoesNotExist:		
			user = User.objects.create_user( body['name'], body['email'], body['password'])
			res = {	'response' : 'New user created' } #success, send 201 status
			data = json.dumps(res)
			return HttpResponse(data, content_type='application/json',status=201, reason='created' )


	else :
		res = { 'response' : 'GET recived when POST was expected' } #error

	data = json.dumps(res)
	return HttpResponseBadRequest(data, content_type='application/json') # error, send 400 status



@csrf_exempt
# @api_view(['POST'])
def login(request):
	if request.method == "POST":
    	
		# parse the raw request body from bytes to unicode string
		body_unicode = request.body.decode('utf-8')
		body = json.loads(body_unicode)
		print("*************************************")
		print("LOL: ", request.user.is_active)

		# catch the error if user doesn't exist to let front end know
		try:
			user = User.objects.get(email=body['email'])
			if user:
    			#if user.check_paswword(body['password']:)		
				if user.check_password(body['password']):
					res = { 'token' : 'Login success!' } # success, send 200 status and auth token
					data = json.dumps(res)
					return HttpResponse(data, content_type='application/json')
				else:
					res = { 'response' : 'Wrong password' } # error, send 400 status
					data = json.dumps(res)
					return HttpResponseBadRequest(data, content_type='application/json')
		except User.DoesNotExist:			
			res = {'response' : 'Account not found. User does not exist'}
			data = json.dumps(res)
			return HttpResponseServerError(data, content_type='application/json') # error, send 500 status	

	elif request.method == "GET":
		res = { 'response' : 'GET recived when POST was expected' }

	data = json.dumps(res)
	return HttpResponseBadRequest(data, content_type='application/json') # error, send 400 status




