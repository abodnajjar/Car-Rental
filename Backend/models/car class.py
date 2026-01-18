
from car_price_class import CarPrice

class Car:
    def __init__(self, car_id, brand, model, category, year, status):
        self.car_id = car_id
        self.brand = brand
        self.model = model
        self.category = category
        self.year = year
        self.status = status
        self.prices = []

    def get_brand(self):
        return self.brand

    def set_brand(self, brand):
        self.brand = brand
    
    def get_model(self):
        return self.model

    def set_model(self, model):
        self.model = model

    def get_category(self):
        return self.category

    def set_category(self, category):
        self.category = category
    
    def get_year(self):
        return self.year

    def set_year(self, year):
        self.year = year

    def get_status(self):
        return self.status

    def set_status(self, status):
        self.status = status

    def add_price(self, day, price):
        car_price = CarPrice(day, price)
        self.prices.append(car_price)

    def get_price_for_day(self, day):
        for car_price in self.prices:
            if car_price.get_day() == day:
                return car_price.get_price()
        return None
    
    def get_prices_only(self):
          prices = []
          for p in self.prices:
            prices.append(p.get_price())
            return prices
