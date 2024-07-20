from decimal import *
from inspect import signature

class LookupBuilder:
    def __del__(self):
        print("Destroying LookupBuilder object")

    def __init__(self, category, increment_y, increment_x, start_y, start_x, max_y, max_x, solver, **kwargs):
        self.category = category
        self.increment_y = increment_y
        self.increment_x = increment_x
        self.increment_z = kwargs.get("increment_z", None)
        self.start_y = start_y
        self.start_x = start_x
        self.start_z = kwargs.get("start_z", None)
        self.max_y = max_y
        self.max_x = max_x
        self.max_z = kwargs.get("max_z", None)
        self.max_cells = 13281

        z_args = {
            "increment_z": self.increment_z,
            "start_z": self.start_z,
            "max_z": self.max_z
        }

        z_args_all_numbers = all(isinstance(arg, (int, float)) for arg in z_args.values())
        z_args_all_bools = all(arg == None for arg in z_args.values())
        if not z_args_all_numbers and not z_args_all_bools:
            bad_args = []
            for arg in z_args.items():
                if not isinstance(arg[1], (int, float)):
                    bad_args.append(arg[0])
            raise ValueError("Maldefined or missing z values: " 
                                + str(bad_args) + 
                                ": Must be int or float")

        # Check how many coordinates have been given
        # Min num table dimensions is 2
        # Max num table dimensions is 3
        if not self.max_z:
            self.dimensions = 2
        else:
            self.dimensions = 3

        # Get the total number of cells needed in the table
        self.num_cells = (self.max_x / self.increment_x ) * (self.max_y / self.increment_y)
        if self.dimensions == 3:
            self.num_cells *= (self.max_z / self.increment_z )

        # Check if the right number of coordinates has been provided for the solver input
        solver_signature = signature(solver)
        solver_arguments_num = len(solver_signature.parameters)
        if solver_arguments_num != (self.dimensions):
            raise ValueError("Number of dimensions specified (" + 
                str(self.dimensions) + 
                ") must be equal to arguments accepted by solver (" + 
                str(solver_arguments_num) + ")"
                )
        self.solver = solver # Any function that takes the number of inputs as dimensions

    def create_table(self):
        # Ideally there's just one function to do this that depends on the num dimensions
        # ... or otherwise some way of minimising duplication
        print("Creating " + str(self.dimensions) + " dimensional lookup table...")
        self.lookup_table_file = open("lookup_table_output.txt", "a")
        if self.dimensions == 2:
            self.create_table_2d()
        elif self.dimensions == 3:
            self.create_table_3d()
        self.lookup_table_file.close()


    def create_table_2d(self):
        self.provid = 1 # Table cell ID
        self.current_y = self.start_y
        self.current_x = self.start_x

        while self.provid < (self.num_cells):
            if self.num_cells > self.max_cells:
                # Each cell is 1 province
                # There are only 13,281 provinces in the mod
                # Therefore if the value goes over 13,281 it must be made to loop around somehow
                # We need to set an extra set of variables with the appendix "_pass_i"
                # Where i is the number of times we've looped beyond 13,281 cells in the table
                # The LOOKUP_get_answer script then needs to know which pass to check based on the size of the input
                # So we need a "pass_i_trigger" variable which if the column (x) is beyond, it checks the "_pass_i" variables
                # The pass_i_trigger needs to be triggered just before the column where it would overflow 13,281
                # So if the expected number of rows in this column would lead cell nubmer to exceed 13,281, enable pass_i
                pass
            self.create_table_column() # Create the entire column of all Y values at this X value
            self.current_x += self.increment_x # Move on to the next X value, i.e. column
             
    def create_table_3d(self):
        pass

    def create_table_column(self):
        while self.current_y < self.max_y:
            self.lookup_table_file.write(self.create_table_cell())
            self.current_y += self.increment_y # Move on to the next row before repeating
            self.provid += 1 # Increment the cell

        # Reset Y position back down to minimum for the next column
        print("Finished creating column")
        self.current_y = self.start_y     

    def create_table_cell(self):
        print("Creating table cell x" + 
            str(round(self.current_x,2)) +
             " y" 
             + str(round(self.current_y,2)) +
             "\n" + str(self.provid) + " of " + str(self.num_cells)
             )
        output = """
        P:{provid} = {{
            LOOKUP_create_cell = {{
                category = {category}
                x_lo = {current_x}
                x_hi = {current_x_incremented}
                y_lo = {current_y}
                y_hi = {current_y_incremented}
                ans = {ans}
            }}
        }}
        """.format(provid=self.provid,
                    category=self.category,
                    current_y = round(self.current_y,2),
                    current_y_incremented = round(self.current_y + self.increment_y,2),
                    current_x = round(self.current_x,2),
                    current_x_incremented = round(self.current_x + self.increment_x,2),
                    ans = round(self.solver(self.current_y, self.current_x),2)
            )
        return output


# TODO: Create an alternative method to use a binary search to find the answer in each coordinate

def multiply_together(x,y):
    return x*y

def get_country_import_price(x,y):
    # x = global_base_import_price_$tradegood$
    # y = country_global_market_penetration_$tradegood$
    # return country_unit_price_$tradegood$
    return (x / (y + 0.5))

builder_global_trade_penetration = LookupBuilder(category = "global_trade_penetration",
             increment_x = 0.01,
             increment_y = 0.01,
             start_y = 0,
             start_x = 0,
             max_x = 1,
             max_y = 1,
             solver = multiply_together)

builder_country_import_price = LookupBuilder(category = "country_import_price",
             increment_x = 0.03,
             increment_y = 0.01,
             start_y = 0,
             start_x = 0,
             max_x = 3,
             max_y = 1,
             solver = get_country_import_price)

builder.create_table()