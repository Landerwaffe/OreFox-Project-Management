from django.shortcuts import render
from django.http import HttpResponse

from .models import *

# Create your views here.

def board_view(request, board_id, *args, **kwargs): 

    board = Board.objects.get(id=board_id)
    boardmembers = BoardMember.objects.filter(board=board_id)
    lists = List.objects.filter(board=board_id)
    cards = Card.objects.filter(board=board_id)

    # Just some debug text, this can be removed
    print('\nUser:(%s,%s) Auth:%s\nMembers:%s' % (request.user.id, request.user, request.user.is_authenticated, boardmembers.values_list('member', flat=True)))

    # Check if the user is a member on the board, if they're not don't direct them to the page
    if request.user.id in boardmembers.values_list('member', flat=True) and request.user.is_authenticated == True:
        context = {
            "board": board,
            "members": boardmembers,
            "lists": lists,
            "cards": cards
        }
        return render(request, "b.html", context)
    else:
        return render(request, "error.html")