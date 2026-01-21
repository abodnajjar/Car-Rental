
class CarPrice:
    def __init__(self, day, price):
        self.day = day       
        self.price = price

    def get_day(self):
        return self.day

    def get_price(self):
        return self.price

    def set_day(self, day):
        self.day = day

    def set_price(self, price):
        self.price = price