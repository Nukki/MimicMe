from django.urls import path
from . import views

# Routing take url pattern and call a function from views
urlpatterns = [
	path('rooms', views.index, name='index'),
    # path('room/<str:id>', ,name='room'),
	path('create', views.create, name='create'),
]
