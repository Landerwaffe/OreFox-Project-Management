from django.shortcuts import render
from django.http import HttpResponse

from .models import *

# Create your views here.

def board_view(request, board, *args, **kwargs): 
    context = {
        "board": Board.objects.get(id=board),
        "lists": List.objects.get(board=board),
        "cards": Card.objects.get(board=board)
    }
    return render(request, "b.html", context)