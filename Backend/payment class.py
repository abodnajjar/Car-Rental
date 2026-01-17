
class Payment:
    def __init__(self, payment_id, rental_id, user_id,
                 amount, payment_method, payment_status,
                 created_at=None):
        self.payment_id = payment_id
        self.rental_id = rental_id
        self.user_id = user_id
        self.amount = amount
        self.payment_method = payment_method
        self.payment_status = payment_status
        self.created_at = created_at