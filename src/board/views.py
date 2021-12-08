from django.shortcuts import render
from django.http import HttpResponse
from .models import Board

# Create your views here.

def board_view(request, id, *args, **kwargs): 
    obj = Board.objects.get(id)
    context = {
        "object": obj
    }
    return render(request, "board.html", context)