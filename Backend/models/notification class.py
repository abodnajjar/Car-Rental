
class Notification:
    def __init__(self, notification_id, user_id, title, message,
                 is_read=False, created_at=None):
        self.notification_id = notification_id
        self.user_id = user_id
        self.title = title
        self.message = message
        self.is_read = is_read
        self.created_at = created_at