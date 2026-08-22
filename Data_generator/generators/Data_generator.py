from faker import Faker
import random
from datetime import timedelta
class data_generator:
    def __init__(self,n=0 ,seed=42):
      self.seed = seed 
      self.n = n 

    def generate_phone(self, country):

        if country == "Egypt":
            prefix = random.choice(["10", "11", "12", "15"])
            number = ''.join(random.choices("0123456789", k=8))
            return f"+20 {prefix}{number}"

        elif country == "Saudi Arabia":
            number = ''.join(random.choices("0123456789", k=8))
            return f"+966 5{number}"

        elif country == "United Arab Emirates":
            prefix = random.choice(["50", "52", "54", "55", "56"])
            number = ''.join(random.choices("0123456789", k=7))
            return f"+971 {prefix}{number}"

        

    def generator_customer(self,n=None):
        print("Generating Customer data : ")
        if n is None : 
          n=self.n
        faker = Faker()

        random.seed(self.seed)

        faker.seed_instance(self.seed)
        countries = {
            "Egypt": ["Cairo", "Alexandria", "Giza", "Luxor"],
            "Saudi Arabia": ["Riyadh", "Jeddah", "Mecca"],
            "United Arab Emirates": ["Dubai", "Abu Dhabi", "Sharjah"],
        }

        customers = []
        for customer_id in range(1,n+1):

            country = random.choice(list(countries.keys()))

            city =  random.choice (countries[country])


            date_of_birth = faker.date_of_birth(
                minimum_age=18,
                maximum_age=70
            )

            registration_date = faker.date_between(
            start_date=date_of_birth + timedelta(days=1),
            end_date="today"
                            )






            customer = {
               "customer_id":customer_id , 
               "first_name": faker.first_name(),
               "last_name" : faker.last_name(),
               "email":faker.email(), 
               "phone": self.generate_phone(country),
               "gender" : random.choice(["Male", "Female" , "Other" ,"Unknown"]),
               "date_of_birth": date_of_birth , 
               "country" : country , 
               "city" : city , 
               "registration_date" : registration_date , 
               "customer_status" : random.choice(["Active" , "Inactive", "Suspended"]) 
            }
            customers.append(customer)

        return customers
    
    def generator_product(self, n=None):

        print("Generating Product data : ")

        if n is None:
            n = self.n

        faker = Faker()

        random.seed(self.seed)
        faker.seed_instance(self.seed)

        # Category -> Subcategory
        categories = {

            "Electronics": [
                "Laptops",
                "Smartphones",
                "Headphones",
                "Tablets",
                "Accessories"
            ],

            "Clothing": [
                "Shirts",
                "Pants",
                "Shoes",
                "Jackets",
                "Dresses"
            ],

            "Home": [
                "Furniture",
                "Kitchen",
                "Decor",
                "Lighting",
                "Bedding"
            ],

            "Sports": [
                "Fitness",
                "Running",
                "Football",
                "Basketball",
                "Outdoor"
            ],

            "Beauty": [
                "Skincare",
                "Haircare",
                "Makeup",
                "Fragrance",
                "Bath"
            ]
        }

        brands = [
            "Samsung",
            "Apple",
            "Nike",
            "Adidas",
            "Sony",
            "LG",
            "Dell",
            "HP",
            "Lenovo",
            "Philips",
            "Puma",
            "Zara"
        ]

        suppliers = [
            "Global Supplies",
            "Prime Distribution",
            "Tech Source",
            "Mega Wholesale",
            "Direct Imports",
            "Global Trade",
            "Premium Suppliers"
        ]

        product_statuses = [
            "Active",
            "Inactive",
            "Discontinued"
        ]

        products = []

        for product_id in range(1, n + 1):


            category = random.choice(list(categories.keys()))

            
            subcategory = random.choice(categories[category])

           
            cost = round(random.uniform(5, 1000), 2)

           
            price = round(
                cost * random.uniform(1.10, 2.50),
                2
            )

           
            stock_quantity = random.randint(0, 500)

            
            launch_date = faker.date_between(
                start_date="-5y",
                end_date="today"
            )

            product = {
                "product_id": product_id,

                "product_name": f"{faker.word().capitalize()} "
                                f"{faker.word().capitalize()}",

                "category": category,

                "subcategory": subcategory,

                "brand": random.choice(brands),

                "supplier": random.choice(suppliers),

                "cost": cost,

                "price": price,

                "stock_quantity": stock_quantity,

                "product_status": random.choice(product_statuses),

                "launch_date": launch_date
            }

            products.append(product)

        return products

    def generator_order(self, customers, n=None):

        print("Generating Order data : ")

        if n is None:
            n = self.n

        faker = Faker()

        random.seed(self.seed)
        faker.seed_instance(self.seed)

        order_statuses = [
            "Pending",
            "Processing",
            "Shipped",
            "Delivered",
            "Cancelled"
        ]

        currencies = {
            "Egypt": "EGP",
            "Saudi Arabia": "SAR",
            "United Arab Emirates": "AED"
        }

        orders = []

        for order_id in range(1, n + 1):

            # Select an existing customer
            customer = random.choice(customers)

            customer_id = customer["customer_id"]
            customer_country = customer["country"]
            customer_city = customer["city"]
            registration_date = customer["registration_date"]

            # Order date must be after customer registration
            order_date = faker.date_between(
                start_date=registration_date,
                end_date="today"
            )

            order = {
                "order_id": order_id,

                "customer_id": customer_id,

                "order_date": order_date,

                "order_status": random.choice(order_statuses),

                "currency": currencies[customer_country],

                "shipping_country": customer_country,

                "shipping_city": customer_city
            }

            orders.append(order)

        return orders

    
    def generator_order_item(self, orders, products, n=None):

        print("Generating Order Item data : ")

        if n is None:
            n = self.n

        random.seed(self.seed)

        order_items = []

        # Create lookup dictionaries
        product_lookup = {
            product["product_id"]: product
            for product in products
        }

        order_lookup = {
            order["order_id"]: order
            for order in orders
        }

        # Keep track of (order_id, product_id)
        used_combinations = set()

        while len(order_items) < n:

            # Select an existing order
            order = random.choice(orders)
            order_id = order["order_id"]

            # Select an existing product
            product = random.choice(products)
            product_id = product["product_id"]

            # Composite PK must be unique
            if (order_id, product_id) in used_combinations:
                continue

            used_combinations.add((order_id, product_id))

            # Quantity: primarily 1-10
            quantity = random.randint(1, 10)

            # Current product price
            product_price = product["price"]

            # Historical selling price
            unit_price = round(
                product_price * random.uniform(0.90, 1.05),
                2
            )

            # Mostly zero or small discounts
            discount = random.choices(
                [0, 5, 10, 15, 20, 25, 30],
                weights=[50, 20, 15, 7, 4, 3, 1],
                k=1
            )[0]

            # Historical product cost
            cost_at_sale = round(
                product["cost"] * random.uniform(0.95, 1.05),
                2
            )

            order_item = {
                "order_id": order_id,
                "product_id": product_id,
                "quantity": quantity,
                "unit_price": unit_price,
                "discount": discount,
                "cost_at_sale": cost_at_sale
            }

            order_items.append(order_item)

        return order_items

    
    def generator_payment(self, orders, n=None):

        print("Generating Payment data : ")

        if n is None:
            n = self.n

        faker = Faker()

        random.seed(self.seed)
        faker.seed_instance(self.seed)

        payment_methods = [
            "Credit Card",
            "Debit Card",
            "PayPal",
            "Cash",
            "Bank Transfer"
        ]

        payment_statuses = [
            "Pending",
            "Completed",
            "Failed",
            "Refunded"
        ]

        payments = []

        # Only orders that can have a payment
        available_orders = orders.copy()

        # We cannot generate more payments than available orders
        if n > len(available_orders):
            raise ValueError(
                "Number of payments cannot exceed number of orders."
            )

        # Select unique orders
        selected_orders = random.sample(
            available_orders,
            n
        )

        for payment_id, order in enumerate(selected_orders, start=1):

            order_id = order["order_id"]

            # Payment date should not be before the order date
            payment_date = faker.date_between(
                start_date=order["order_date"],
                end_date="today"
            )

            payment = {
                "payment_id": payment_id,

                "order_id": order_id,

                "payment_date": payment_date,

                "payment_method": random.choice(
                    payment_methods
                ),

                "amount": round(
                    random.uniform(10, 5000),
                    2
                ),

                "currency": order["currency"],

                "payment_status": random.choice(
                    payment_statuses
                ),

                "transaction_reference": (
                    f"TXN-{faker.uuid4()}"
                )
            }

            payments.append(payment)

        return payments

    
    def generator_shipping(self, orders, n=None):

        print("Generating Shipping data : ")

        if n is None:
            n = self.n

        faker = Faker()

        random.seed(self.seed)
        faker.seed_instance(self.seed)

        shipping_methods = [
            "Standard",
            "Express",
            "Same Day",
            "Next Day"
        ]

        shipping_statuses = [
            "Pending",
            "Shipped",
            "In Transit",
            "Delivered",
            "Returned"
        ]

        shippings = []

        # One shipping record per order
        if n > len(orders):
            raise ValueError(
                "Number of shipments cannot exceed number of orders."
            )

        # Select unique orders
        selected_orders = random.sample(orders, n)

        for shipment_id, order in enumerate(selected_orders, start=1):

            order_id = order["order_id"]

            # Shipping date must be on or after order date
            shipping_date = faker.date_between(
                start_date=order["order_date"],
                end_date="today"
            )

            # Estimated delivery is after shipping date
            estimated_delivery_date = faker.date_between(
                start_date=shipping_date,
                end_date="+14d"
            )

            # Decide whether the order has been delivered
            shipping_status = random.choice(shipping_statuses)

            if shipping_status == "Delivered":

                delivery_date = faker.date_between(
                    start_date=shipping_date,
                    end_date=estimated_delivery_date
                )

            else:

                delivery_date = None

            shipping = {
                "shipment_id": shipment_id,

                "order_id": order_id,

                "shipping_date": shipping_date,

                "estimated_delivery_date": estimated_delivery_date,

                "delivery_date": delivery_date,

                "shipping_country": order["shipping_country"],

                "shipping_city": order["shipping_city"],

                "shipping_method": random.choice(
                    shipping_methods
                ),

                "shipping_status": shipping_status,

                "shipping_cost": round(
                    random.uniform(20, 500),
                    2
                )
            }

            shippings.append(shipping)

        return shippings


    def generator_review(self, customers, products, n=None):

        print("Generating Review data : ")

        if n is None:
            n = self.n

        faker = Faker()

        random.seed(self.seed)
        faker.seed_instance(self.seed)

        review_statuses = [
            "Published",
            "Pending",
            "Rejected"
        ]

        reviews = []

        # Keep track of customer-product combinations
        used_combinations = set()

        while len(reviews) < n:

            # Select existing customer and product
            customer = random.choice(customers)
            product = random.choice(products)

            customer_id = customer["customer_id"]
            product_id = product["product_id"]

            # A customer should review a product only once
            if (customer_id, product_id) in used_combinations:
                continue

            used_combinations.add(
                (customer_id, product_id)
            )

            # Review date must be after registration date
            review_date = faker.date_between(
                start_date=customer["registration_date"],
                end_date="today"
            )

            # Realistic rating distribution
            rating = random.choices(
                [1, 2, 3, 4, 5],
                weights=[5, 8, 15, 30, 42],
                k=1
            )[0]

            # Mostly verified purchases
            verified_purchase = random.choices(
                [True, False],
                weights=[80, 20],
                k=1
            )[0]

            review = {
                "review_id": len(reviews) + 1,

                "customer_id": customer_id,

                "product_id": product_id,

                "rating": rating,

                "review_date": review_date,

                "verified_purchase": verified_purchase,

                "review_status": random.choice(
                    review_statuses
                )
            }

            reviews.append(review)

        return reviews


    def generator_marketing_event(self, customers, n=None):

        print("Generating Marketing Event data : ")

        if n is None:
            n = self.n

        faker = Faker()

        random.seed(self.seed)
        faker.seed_instance(self.seed)

        campaign_names = [
            "Summer Sale",
            "Winter Sale",
            "Black Friday",
            "New Year Campaign",
            "Back to School",
            "Ramadan Offers",
            "Flash Sale",
            "New Product Launch"
        ]

        event_types = [
            "Impression",
            "Click",
            "View",
            "Add to Cart",
            "Purchase"
        ]

        channels = [
            "Email",
            "Social Media",
            "Google Ads",
            "Website",
            "Mobile App"
        ]

        device_types = [
            "Mobile",
            "Desktop",
            "Tablet"
        ]

        marketing_events = []

        for event_id in range(1, n + 1):

            # Select an existing customer
            customer = random.choice(customers)

            customer_id = customer["customer_id"]

            # Use the customer's country
            country = customer["country"]

            # Generate campaign
            campaign_id = random.randint(1, 100)

            campaign_name = random.choice(campaign_names)

            # Generate event timestamp
            event_timestamp = faker.date_time_between(
                start_date=customer["registration_date"],
                end_date="now"
            )

            marketing_event = {
                "event_id": event_id,

                "customer_id": customer_id,

                "campaign_id": campaign_id,

                "campaign_name": campaign_name,

                "event_type": random.choice(event_types),

                "channel": random.choice(channels),

                "event_timestamp": event_timestamp,

                "device_type": random.choice(device_types),

                "country": country
            }

            marketing_events.append(marketing_event)

        return marketing_events
    

       