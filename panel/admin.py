from .Ticketing.models import Ticket, Message, Attachment, TicketType
from .Notification.models import Notification
from .Feedback.models import Feedback
from django.contrib import admin

admin.site.register(TicketType)
admin.site.register(Ticket)
admin.site.register(Message)
admin.site.register(Attachment)
admin.site.register(Notification)
admin.site.register(Feedback)