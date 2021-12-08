from django.db import models
from django.conf import settings
from django.urls import reverse

"""
Project Management Board Model
===============================

Here is my adaptation of the SQL/schema within /.DB/PMDB.sql, I'm not sure if it's exact to the mark as far as 
the ForeignKey and MYSQL Indexing goes. Might need to do some more reading / asking of questions.

Contains Models:
    Board
    BoardMember
    List
    Card
    CardContent
    BoardTag
    CardTag
    Reaction

Author: Thomas Fabian
"""

class Board(models.Model):
    """
    Board Model
    -----------

    This is the base model for a specific project management board. All cards and board members reference this 
    model.
    """
    title           = models.CharField(max_length=255, db_index=True)
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, db_index=True)
    description     = models.TextField()
    date_created    = models.DateTimeField(auto_now_add=True)
    date_modified   = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [ models.UniqueConstraint(fields=['author','title'], name='uq_board') ]
        indexes = [ models.Index(fields=['author', 'title']) ]

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        return reverse('b:id', kwargs={'id': str(self.id)})

class BoardMember(models.Model):
    """
    Board Member
    ------------

    These are the members of each board, this could likely extend djangos built in user model for convenience.
    """

    # ACCESS CHOICES
    class Access(models.IntegerChoices):
        OWNER = 1
        ADMIN = 2
        READ  = 3
        WRITE = 4

    # Fields
    board   = models.ForeignKey(Board, on_delete=models.CASCADE)
    member  = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, db_index=True)
    access  = models.IntegerField(choices=Access.choices, default=Access.READ)

    class Meta:
        constraints = [ models.UniqueConstraint(fields=['board','member'], name='uq_member') ]
        indexes = [ models.Index(fields=['board', 'member']) ]

    def has_admin_privileges(self):
        return self.access in {self.OWNER, self.ADMIN}

class List(models.Model):
    """
    List
    ----

    A List is a 'container' similar to what holds the cards on trello. The location field is the order 
    left-to-right on the board, I want it to be unique so that only one list can be in a location, but I'm not
    sure how swapping them around should work (in the case of inserting a list inbetween pre-existing or moving
    them around)
    """
    board       = models.ForeignKey(Board, on_delete=models.CASCADE)
    title       = models.CharField(max_length=45)
    location    = models.PositiveIntegerField(unique=True)

    class Meta:
        indexes = [ models.Index(fields=['board']) ]

class Card(models.Model):
    """
    Card
    ----

    These are the cards that are contained within a list on a board, they aren't unique and any amount of the same
    card can be made. The content is stored in another model based on some enum choice.
    """
    board           = models.ForeignKey(Board, on_delete=models.CASCADE)
    list            = models.ForeignKey(List, on_delete=models.CASCADE)
    location        = models.PositiveIntegerField()
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title           = models.CharField(max_length=45)
    description     = models.TextField(max_length=256)
    date_created    = models.DateTimeField(auto_now_add=True)
    date_modified   = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [ models.Index(fields=['board', 'list', 'author']) ]

    def __str__(self):
        return self.title

class CardContent(models.Model):
    """
    Card Content
    ------------

    A Card can have any amount of content added into it such as comments, lists and file attachments. I'm not sure
    that storing a file in a charfield is optimal though (in MYSQL you'd normally use a BLOB)
    """
    class ContentType(models.IntegerChoices):
        COMMENT = 1
        LIST = 2
        ATTACHMENT = 3 

    card            = models.ForeignKey(Card, on_delete=models.CASCADE)
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    type            = models.IntegerField(choices=ContentType.choices, default=ContentType.COMMENT)
    contents        = models.CharField(max_length=2048, null=False)
    date_created    = models.DateTimeField(auto_now_add=True)
    date_modified   = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [ models.Index(fields=['card', 'author']) ]

class BoardTag(models.Model):
    """
    Board Tag
    ---------

    A Board Tag is some coloured label that can be applied to any card within a board (uniquely) and this is the 
    model that stores the tags available for each board.
    """
    board   = models.ForeignKey(Board, on_delete=models.CASCADE)
    name    = models.CharField(max_length=32)
    colour  = models.CharField(max_length=6)

    class Meta:
        constraints = [ models.UniqueConstraint(fields=['board','name'], name='uq_board_tag') ]
        indexes = [ models.Index(fields=['board', 'name']) ]

class CardTag(models.Model):
    """
    Card Tag
    --------

    References the board tags so that each card can be supplied with its own tags (uniquely of course!)
    """
    board   = models.ForeignKey(Board, on_delete=models.CASCADE)
    card    = models.ForeignKey(Card, on_delete=models.CASCADE)
    tag     = models.ForeignKey(BoardTag, on_delete=models.CASCADE)
    author  = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

    class Meta:
        constraints = [ models.UniqueConstraint(fields=['board','card','tag'], name='uq_card_tag') ]
        indexes = [ models.Index(fields=['board', 'card']) ]

class Reaction(models.Model):
    """
    Reaction
    --------

    This model is just about user interaction on cards, whether they like or dislike it etc.
    I was considering just making this applicable to the card content though as that would make more sense (assuming
    that this model gets used at all as it's not a high priority goal)
    """
    class Reactions(models.IntegerChoices):
        LIKE = 1
        DISLIKE = 2
        CHECKMARK = 3
        CROSS = 4

    card            = models.ForeignKey(Card, on_delete=models.CASCADE)
    author          = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    reaction        = models.IntegerField(choices=Reactions.choices)
    date_created    = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [ models.UniqueConstraint(fields=['card','author','reaction'], name='uq_reaction') ]
        indexes = [ models.Index(fields=['card', 'author']) ]