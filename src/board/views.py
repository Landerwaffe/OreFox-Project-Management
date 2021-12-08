from django.shortcuts import render
from django.http import HttpResponse

from .models import *

# Create your views here.

def board_view(request, board, *args, **kwargs): 

    board = Board.objects.get(id=board)
    boardmembers = BoardMember.objects.get(board=board)
    lists = List.objects.get(board=board)
    cards = Card.objects.get(board=board)

    # if request.user in boardmembers
    #     return render(request, "error.html")
    # else:   

    context = {
        "board": board,
        "members": boardmembers,
        "lists": lists,
        "cards": cards
    }
    return render(request, "b.html", context)