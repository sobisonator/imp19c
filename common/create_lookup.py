from decimal import *

class LookupBuilder:
    def __init__(self, category, increment, start_y, start_x, max_y, max_x, solver):
        self.category = category
        self.increment = increment
        self.start_y = start_y
        self.start_x = start_x
        self.max_y = max_y
        self.max_x = max_x
        self.solver = solver

    def create_table(self):
        provid = 1
        current_y = self.start_y
        current_x = self.start_x
        increment = self.increment

        while provid < (self.max_x * self.max_y):
            self.create_table_column
            current_y += self.increment
            provid += 1
             
    def create_table_column(self):
        while current_x < self.max_x:

            self.print_table_output()
            current_x += self.increment

        current_x = self.start_x     

    def print_table_output(self):
            output = """
        p:{provid} = {{
            set_variable = LOOKUP_IS_CELL

            set_variable = {{
                name = LOOKUP_LO_x_{category}
                value = {current_x}
            }}
            set_variable = {{
                name = LOOKUP_HI_x_{category}
                value = {current_x_incremented}
            }}

            set_variable = {{
                name = LOOKUP_LO_y_{category}
                value = {current_y}
            }}
            set_variable = {{
                name = LOOKUP_HI_y_{category}
                value = {current_y_incremented}
            }}

            set_variable = {{
                name = LOOKUP_ANS_{category}
                value = {ans}
            }}
        }}
            """.format(provid=self.provid,
                    category=self.category,
                    current_y = round(self.current_y,2),
                    current_y_incremented = round(self.current_y + self.increment,2),
                    current_x = round(self.current_x,2),
                    current_x_incremented = round(self.current_x + self.increment,2),
                    ans = round(self.solver(self.current_y, self.current_x),2)
            )
            print(output)


# TODO: Create an alternative method to use a binary search to find the answer in each coordinate

def multiply_together(x,y):
    return x*y

builder = LookupBuilder(category = "global_trade_penetration",
             increment = 0.01,
             start_y = 0,
             start_x = 0,
             max_x = 1,
             max_y = 1, 
             solver = multiply_together)

builder.create_table()

