from decimal import *

def create_table(category, increment, start_y, start_x, max_y, max_x, solver):

    provid = 1
    current_y = start_y
    current_x = start_x
    increment = increment

    while current_x < max_x:

        print_table_output(provid,category,current_y,current_x,increment,solver)
        current_x += increment
    current_x = start_x
    current_y += increment


def print_table_output(provid,category,current_y,current_x,increment,solver):
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
        """.format(provid=provid,
                category=category,
                current_y = current_y,
                current_y_incremented = current_y + increment,
                current_x = current_x,
                current_x_incremented = current_x + increment,
                ans = solver(current_y, current_x))
        print(output)


def multiply_together(x,y):
    return x*y

create_table(category = "global_trade_penetration",
             increment = 0.01,
             start_y = 0,
             start_x = 0,
             max_x = 1,
             max_y = 1, 
             solver = multiply_together
             )

