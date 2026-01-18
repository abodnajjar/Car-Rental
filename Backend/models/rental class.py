
class Rental:
    def __init__(self, rental_id, user_id, car_id,
                 pickup_location, dropoff_location,
                 start_date, end_date,
                 total_price=0, status="pending",
                 employee_id=None, created_at=None):
        self.rental_id = rental_id
        self.user_id = user_id           
        self.employee_id = employee_id    
        self.car_id = car_id
        self.pickup_location = pickup_location
        self.dropoff_location = dropoff_location
        self.start_date = start_date
        self.end_date = end_date
        self.total_price = total_price
        self.status = status
        self.created_at = created_at