from django.shortcuts import render

# Create your views here.
def notindex(request):
    print("OMG THE REQUEST CAME THROUGH")
    print(request.user)
    print("****************************")
    """
    Root page view. This is essentially a single-page app, if you ignore the
    login and admin parts.
    """

    # Render that in the index template
    return render(request, "index.html")