from django.http import HttpResponseBadRequest
from django.contrib import auth


class TokenMiddleware(object):
    def __init__(self, get_response):
        self.get_response = get_response
    """
    Middleware that authenticates against a token in the http authorization header.
    """

    def process_request(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION', b'').split()

        if not auth_header or auth_header[0].lower() != b'token':
            return None

        # If they specified an invalid token, let them know.
        if len(auth_header) != 2:
            return HttpResponseBadRequest("Improperly formatted token")

        user = auth.authenticate(token=auth_header[1])
        if user:
            request.user = user