from django.shortcuts import render
from django.http import HttpResponse
from django.core.exceptions import ObjectDoesNotExist

from .models import *

# Create your views here.

def board_view(req, board_id, *args, **kwargs): 
    try:
        board = Board.objects.get(id=board_id)
        members = BoardMember.objects.filter(board=board_id)
        lists = List.objects.filter(board=board_id)
        cards = Card.objects.filter(board=board_id)

        # Just some debug text, this can be removed
        print('\nBoard:\t%s\nUser:\t(%s,%s)\nMembers:%s\n' % (
            board.get_absolute_url(),
            req.user.id, 
            req.user,
            members.values_list('member', flat=True)))

        # Show the website to users who are authenticated and a member of the board or a member of staff
        if req.user.is_authenticated and (req.user.id in members.values_list('member', flat=True) or req.user == board.author or req.user.is_staff):
            return render(req, "b.html", {
                "board": board,
                "members": members,
                "lists": lists,
                "cards": cards
            })
        else: 
            # Just throw an error if it happens, there's probably a better way to do this
            raise Exception("ACCESS DENIED: %s by %s" % (board.get_absolute_url(), req.user))

    except Exception:
        # Return the error page if anything goes wrong e.g. invalid credentials
        return render(req, "error.html")