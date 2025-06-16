import tkinter as tk
from tkinter import ttk
import pandas as pd

# Create a Tkinter root window
root = tk.Tk()

# Reading the database
data = pd.read_csv(r"C:/Users/User/Downloads/addresses.csv")

# Create a treeview widget (similar to a table) with ttk
tree = ttk.Treeview(root)
tree["columns"] = tuple(data.columns)

# Add column headings
for col in data.columns:
    tree.heading(col, text=col)

# Insert data into the treeview
for index, row in data.head(10).iterrows():
    tree.insert("", "end", values=tuple(row))

# Pack the treeview into the window
tree.pack()

# Run the Tkinter event loop
root.mainloop()
