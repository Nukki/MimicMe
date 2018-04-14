from django.urls import path
from . import views

# Routing take url pattern and call a function from views
urlpatterns = [
	path('',views.index, name='index'),
	path('register',views.register, name='register'),
	path('login',views.login, name='login'),
]