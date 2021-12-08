from django.contrib import admin

# Register your models here.

from .models import *

admin.site.register(Board)
admin.site.register(BoardMember)
admin.site.register(List)
admin.site.register(Card)
admin.site.register(CardContent)
admin.site.register(BoardTag)
admin.site.register(CardTag)
admin.site.register(Reaction)