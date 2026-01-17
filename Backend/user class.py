
class User:
    
    
    def __init__(self, uid, full_name, email, phone, role,
                 driving_license_no=None, salary=None):
        self.uid = uid
        self.full_name = full_name
        self.email = email
        self.phone = phone
        self.role = role         
        self.driving_license_no = driving_license_no
        self.salary = salary 

    def get_id(self):
        return self.uid
    
    def get_name(self):
        return self.full_name
    
    def set_name(self,name):
        self.full_name=name

    def get_email(self):
        return self.email
    
    def set_email(self,email):
        self.email=email

    def get_phone(self):
        return self.phone

    def set_phone(self,phone):
        self.phone=phone

    def get_driving_license_no(self):
     return self.driving_license_no

    def set_driving_license_no(self,driving_license_no):
        self.driving_license_no=driving_license_no

    def get_salary(self):
        return self.salary

    def set_salary(self,salary):
        self.salary=salary