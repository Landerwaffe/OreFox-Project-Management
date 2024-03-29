from django.contrib import admin

# Register your models here.

from .models import *

admin.site.register(Profile)
admin.site.register(Board)
admin.site.register(BoardMember)

admin.site.register(List)
admin.site.register(Card)
admin.site.register(Comment)
admin.site.register(Task)
admin.site.register(Attachment)
admin.site.register(Tag)
admin.site.register(CardTag)
admin.site.register(Reaction)