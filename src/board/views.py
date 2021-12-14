from django.shortcuts import redirect, render
from django.core.exceptions import ObjectDoesNotExist
from django.contrib.auth.decorators import login_required
import django.contrib.auth as auth

from django.contrib.auth.models import *
from .models import *
from .forms import *

# Create your views here.

@login_required(login_url='/login/')
def board_view(request, board_id, *args, **kwargs): 
    """
    Board View
    ----------

    This is the main application of the website, where project management stuff happens. 
    Better description incoming once the page has been developed.
    """
    try:
        board = Board.objects.get(id=board_id)
        members = board.get_members()
        lists = board.get_lists()
        cards = board.get_cards()

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
    
    return error_view(request, "Board Not Found")


def home_view(request, *args, **kwargs):
    """
    Home View
    ---------

    This is the home-page of the website
    """
    return render(request, "home.html", { 
        "title": 'Home' 
    })


def error_view(request, message, *args, **kwargs):
    """
    Error View
    ----------

    This is just a generic error page, you can pass in a message via the main arguments
    """
    return render(request, "error.html", { 
        "title": 'Error',
        "message": message
    })

@login_required(login_url='/login/')
def dashboard_view(request, *args, **kwargs):
    """
    Dashboard View
    --------------

    This is the dashboard for the logged in user, we can probably add functionality for admins
    by using the is_superuser stuff etc.    
    """
    return render(request, "dashboard.html", {
        "title": "Dashboard"
    })

def login_view(request, *args, **kwargs):
    """
    Login View
    ----------

    Generic login view, authenticates whatever is in the pages fields on POST, a GET will return
    the general login page.
    """
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']

        user = auth.authenticate(username=username, password=password)

        if user is not None:
            if user.is_active:
                auth.login(request, user)
                return redirect('/dashboard/') # Redirect to a success page.
            else:
                return error_view(request, "Account Disabled") # Return a 'disabled account' error message
        else:
            # Return an 'invalid login' error message.
            return redirect('/')

    # If we're already logged in we don't need to see this page
    elif request.user is not None:
        return redirect('/dashboard/')
    
    # Otherwise show login page
    else:
        return render(request, "login.html", {
            "title" : 'Login'
        })


def logout_view(request):
    auth.logout(request)
    # Redirect to some logout page I guess

def registration_view(request, *args, **kwargs):
    """
    Registration View
    -----------------

    Users can register accounts on this page, I think it'd be wise to keep superuser, admins behind
    needing the Django Admin dashboard.
    """
    if request.method == 'POST':
        email = request.POST['email']
        username = request.POST['username']
        password = request.POST['password']

        # Not sure if this does any authentication checks, e.g. if a user already exists
        user = UserManager.objects.create_user(username=username, password=password, email=email)

        # This should be none if the create_user didn't work, though looking at the code within the 
        # UserManager object, create_user doesn't do any authentication checks, so I guess this will
        # require some testing/rejigging.
        if user is not None:
            # I suppose we want to login immediately after, though in the real world we'd want to sent an e-mail
            # token to stop bots from spam-creating user accounts.
            auth.login(request, user)

            # Redirect to the users dashboard
            return redirect('/dashboard/') 
        else:
            return error_view(request, "Invalid Credentials")
    else:
        return render(request, "register.html", {
            "title" : 'Register'
        })
