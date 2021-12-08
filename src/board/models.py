from django.db import models
from django.conf import settings
from django.db.models.fields import BooleanField
from django.urls import reverse

"""
Project Management Board Model
===============================

Here is my adaptation of the SQL/schema within /.DB/PMDB.sql, I'm not sure if it's exact to the mark as far as 
the ForeignKey and MYSQL Indexing goes. Might need to do some more reading / asking of questions.

Contains Models:
    Profile
    Board
    BoardMember
    List
    Card
    Comment
    Task
    Attachment
    Tag
    CardTag
    Reaction

Author: Thomas Fabian
"""

class Profile(models.Model):
    """
    Member Model
    ------------

    Extends the User with additional fields unrelated to authentication. Will update/create with the addition
    of new users within auth_user.

    Access this extra information with 'user.profile.birth_date' etc.
    """
    user        = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    birth_date  = models.DateField(null=True, blank=True)
    location    = models.CharField(max_length=30, blank=True)
    bio         = models.TextField(max_length=500, blank=True)
    avatar      = models.ImageField(upload_to='avatars/', null=True, blank=True)

    class Meta:
        ordering = ('user', )

    def __str__(self):
        return self.user.username

class Board(models.Model):
    """
    Board Model
    -----------

    This is the base model for a specific project management board. All cards and board members reference this 
    model.
    """
    title           = models.CharField(max_length=45)
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    description     = models.TextField(max_length=500, blank=True)
    date_created    = models.DateTimeField(auto_now_add=True)
    date_modified   = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [ models.UniqueConstraint(fields=['author','title'], name='uq_board') ]

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        return reverse('board-main', kwargs={"board_id": str(self.id)})

class BoardMember(models.Model):
    """
    Board Member Model
    ------------------

    These are the members of each board, this could likely extend djangos built in user model for convenience.
    """

    # ACCESS CHOICES
    class Access(models.IntegerChoices):
        OWNER = 1
        ADMIN = 2
        READ  = 3
        WRITE = 4

    # Fields
    board   = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    member  = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    access  = models.IntegerField(choices=Access.choices, default=Access.READ)

    class Meta:
        ordering = ('board', )
        constraints = [ models.UniqueConstraint(fields=['board','member'], name='uq_member') ]

    def has_admin_privileges(self):
        return self.access in {self.OWNER, self.ADMIN}

class List(models.Model):
    """
    List Model
    ----------

    A List is a 'container' similar to what holds the cards on trello. The location field is the order 
    left-to-right on the board, I want it to be unique so that only one list can be in a location, but I'm not
    sure how swapping them around should work (in the case of inserting a list inbetween pre-existing or moving
    them around)
    """
    board       = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    title       = models.CharField(max_length=45)
    location    = models.PositiveIntegerField(unique=True)

    class Meta:
        ordering = ('board', )

class Card(models.Model):
    """
    Card Model
    ----------

    These are the cards that are contained within a list on a board, they aren't unique and any amount of the same
    card can be made. The content is stored in another model based on some enum choice.
    """
    board           = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    list            = models.ForeignKey(List, on_delete=models.CASCADE)
    location        = models.PositiveIntegerField()
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, db_index=True)
    title           = models.CharField(max_length=45, default='New Card')
    description     = models.TextField(max_length=256, blank=True)
    date_created    = models.DateTimeField(auto_now_add=True)
    date_modified   = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ('board', 'list', )

    def __str__(self):
        return self.title

class Comment(models.Model):
    """
    Comment Model
    -------------

    A Comment that can be left on a card.
    """

    board           = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    card            = models.ForeignKey(Card, on_delete=models.CASCADE)
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    comment         = models.CharField(max_length=2048)
    date_created    = models.DateTimeField(auto_now_add=True)
    date_modified   = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ('board', 'card', )

class Task(models.Model):
    """
    Task Model
    ----------

    This is the sub-task model for inside the cards.
    """

    board   = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    card    = models.ForeignKey(Card, on_delete=models.CASCADE)
    name    = models.CharField(max_length=25)
    done    = models.BooleanField(default=False)

    class Meta:
        ordering = ('board', 'card', )

class Attachment(models.Model):
    """
    Attachment Model
    ----------------

    This Model handles file attachments to cards.
    """
    def get_board_directory_path(instance, filename):
        return 'board_%s/%s' % (instance.board.id, filename)

    board   = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    card    = models.ForeignKey(Card, on_delete=models.CASCADE)
    author  = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    file    = models.FileField(upload_to=get_board_directory_path)

    class Meta:
        ordering = ('board', 'card', )

class Tag(models.Model):
    """
    Tag Model
    ---------

    A Board Tag is some coloured label that can be applied to any card within a board (uniquely) and this is the 
    model that stores the tags available for each board.
    """

    board   = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    name    = models.CharField(max_length=32)
    colour  = models.CharField(max_length=6)

    class Meta:
        ordering = ('board', )
        constraints = [ models.UniqueConstraint(fields=['board','name'], name='uq_board_tag') ]

class CardTag(models.Model):
    """
    Card Tag Model
    --------------

    References the board tags so that each card can be supplied with its own tags (uniquely of course!)
    """
    board   = models.ForeignKey(Board, on_delete=models.CASCADE, db_index=True)
    card    = models.ForeignKey(Card, on_delete=models.CASCADE)
    tag     = models.ForeignKey(Tag, on_delete=models.CASCADE)

    class Meta:
        ordering = ('board', 'card', )
        constraints = [ models.UniqueConstraint(fields=['board','card','tag'], name='uq_card_tag') ]

class Reaction(models.Model):
    """
    Reaction Model
    --------------

    This model is just about user interaction on card comments, whether they like or dislike it etc.
    """
    class Reactions(models.IntegerChoices):
        LIKE = 1
        DISLIKE = 2
        CHECKMARK = 3
        CROSS = 4

    comment         = models.ForeignKey(Comment, on_delete=models.CASCADE)
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    reaction        = models.IntegerField(choices=Reactions.choices)
    date_created    = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ('comment', )
        constraints = [ models.UniqueConstraint(fields=['comment','author','reaction'], name='uq_reaction') ]