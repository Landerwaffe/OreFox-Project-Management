from django.shortcuts import render
from django.core.exceptions import ObjectDoesNotExist

from .models import *
from .forms import *

# Create your views here.
def board_view(request, board_id, *args, **kwargs): 
    try:
        board = Board.objects.get(id=board_id)
        members = BoardMember.objects.filter(board=board_id)
        lists = List.objects.filter(board=board_id)
        cards = Card.objects.filter(board=board_id)

        # Just some debug text, this can be removed
        print('\nBoard:\t%s\nUser:\t(%s,%s)\nMembers:%s\n' % (
            board.get_absolute_url(),
            request.user.id, 
            request.user,
            members.values_list('member', flat=True)))

        # Show the website to users who are authenticated and a member of the board or a member of staff
        if request.user.is_authenticated and (request.user == board.author or request.user.is_staff or request.user.id in members.values_list('member', flat=True)):
            return render(request, "board.html", {
                "title": board.title,
                "board": board,
                "members": members,
                "lists": lists,
                "cards": cards
            })

    except ObjectDoesNotExist: 
        pass
    
    return error_view(request)


def home_view(request, *args, **kwargs):
    return render(request, "home.html", { 
        "title": 'Home' 
    })


def error_view(request, *args, **kwargs):
    return render(request, "error.html", { 
        "title": 'Error'
    })

