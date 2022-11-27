# -*- coding: utf-8 -*-
"""
Created on Sat May  8 23:35:20 2021

@author: Tobias Grøsfjeld
"""
import tkinter as tk
from tkinter import filedialog #, Text, Frame
#import os
from . import injectormaker as inj
from . import tutorial as tut
#from tkscrolledframe import ScrolledFrame


global myClasses
myClasses = []

# Set default styles for various interface widgets
def myGridEntrys(parent,x=0,y=0,text="Placeholder"):
    temp = tk.Entry(parent,borderwidth=5)
    temp.grid(row=y, column=x+1)
    myGridLabel(parent,x,y,text)
    return temp
    
def myGridLabel(parent,x=0,y=0,text="Placeholder"):
    temp = tk.Label(parent,text=text,bg="black",fg="white")
    temp.grid(row=y, column=x)
    return temp

def myGridButton(parent,command,x=0,y=0,text="Placeholder"):
    temp = tk.Button(parent,text=text,command=command,width=10)
    temp.grid(row=y, column=x)
    return temp

def myListWidget(parent,text_list):
    scrollbar = tk.Scrollbar(parent)
    scrollbar.pack( side = tk.RIGHT, fill = tk.Y )
    temp = tk.Listbox(parent, yscrollcommand = scrollbar.set, width = 50)
    for i in text_list:
        temp.insert(tk.END,i)
    temp.pack(side = tk.BOTTOM,fill = tk.BOTH)
    scrollbar.config( command = temp.yview )
    return temp
    
separateExportLabel = """# Unless you use the file produced by "Export All", you must put this file in your scripted_effects folder to run manually exported injectors. 
# The same code can be found in the file produced by 'Export All'.
"""
# The class that should really be a dataclass.
# Contains the Main key, secondary key, [iterant key] and filepath.
class myClass:
    # Alternative style data specific to this class
    def myGridEntry(self,parent,x=0,y=0,text="Placeholder",string_var=""):
        temp = tk.Entry(parent,borderwidth=5,textvariable=string_var, width = 70)
        temp.grid(row=y, column=x+1)
        myGridLabel(parent,x,y,text)
        return temp
    def myStringCleaner(self, x): #Fetches just the last piece of text
        return x.split("/")[-1].split("_")[-1].split(".")[0]
    def __init__(self,my_text, init_main_key="MAIN_KEY", init_secondary_key = "SECONDARY_KEY", init_inspector_level = 0):
        global myClasses
        global frame
        global canvas
        #global sframe
        # Add to list of existing classes, for mass export purposes
        myClasses+= [self]
        # Make the subframe and the subgrid of the subframe
        self.subframe = tk.Frame(frame,bg="black",borderwidth=5)
        self.subframe.pack()
        self.subgrid = tk.Frame(self.subframe,bg="black")
        self.subgrid.pack()
        # Data entry
        self.mkey = tk.StringVar(self.subframe,init_main_key)
        self.mkey.trace_add("write",self.exportcontroller)
        self.skey = tk.StringVar(self.subframe,init_secondary_key)
        self.skey.trace_add("write",self.exportcontroller)
        self.main_key = self.myGridEntry(self.subgrid,0,0,"Main Key",self.mkey)
        self.secondary_key = self.myGridEntry(self.subgrid,0,1,"Secondary Key",self.skey)        
        # Buttons
        self.inspectButton = myGridButton(self.subgrid,self.ToggleInspect,2,0,"Inspect Keys")
        self.destroyButton = myGridButton(self.subgrid,self.myDestroy,2,1,"Remove")
        self.inspectorToggleButton = myGridButton(self.subgrid,self.inspectorToggle,3,0,"Inspect Level")
        self.exportButton = myGridButton(self.subgrid,self.export,3,1,"Export")
        self.exportButton["state"] = tk.DISABLED
        # Handle the file path
        self.filepath = tk.Label(self.subframe,text = my_text).pack()
        self.filetext = my_text
        # Initialize or refresh data.
        self.inspectionToggle = 0
        self.inspectionLevel = init_inspector_level
        self.parseKeys()
        self.exportcontroller()

        print("Loaded: " + repr(self))
        #canvas.configure(scrollregion=canvas.bbox("all"))
    def dataTriplet(self): # For passing to the exporter
        return (self.main_key.get(),self.secondary_key.get(),self.parsedkeys)
    
    # Inspectors, displays and filtering
    def inspectorToggle(self): # Switch inspector number
        self.inspectionLevel += 1
        self.inspectionLevel = self.inspectionLevel % 4
        self.parsedkeys = inj.injector_reader(self.filetext,self.inspector())
        if self.inspectionToggle == 1: # Refresh the list
            self.ToggleInspect()
            self.ToggleInspect()
    def ToggleInspect(self): # View the inspected data
        if self.inspectionToggle == 0:
            self.inspectionToggle = 1
            self.inspectionFrame = tk.Frame(self.subframe,bg="white") #,width = 500, height = 250)
            self.inspectionFrame.pack()
            self.listwidget = myListWidget(self.inspectionFrame,self.parsedkeys)
        else: 
            self.inspectionToggle = 0
            self.inspectionFrame.destroy()
    def inspector(self): # Which inspector are we using?
        return lambda x: inj.should_read(x,self.inspectionLevel)
    # Deploy the inspector
    def parseKeys(self):
        self.parsedkeys = inj.injector_reader(self.filetext,self.inspector())
        return self.parsedkeys
    def myParseFile(self):
        return (self.main_key.get(),self.secondary_key.get(),inj.injector_reader(self.filetext,self.inspector()))
        
    # Remove self
    def myDestroy(self):
        global myClasses
        myClasses.remove(self)
        self.subframe.destroy()
        
    # Export self
    def export(self):
        with open("required_metainjectors.txt","w",encoding='utf-8-sig') as file:
            file.write(separateExportLabel)
            file.write(inj.initial_template)
        exportlist = inj.injector_maker(self.main_key.get(),self.secondary_key.get(),self.parsedkeys)
        with open(self.main_key.get()+"_injector.txt","w",encoding='utf-8-sig') as file:
            file.write(exportlist)    
    # Control whether exporting is possible (We need both keys to exist)
    def exportcontroller(self,*args):
        #print(args)
        if len(self.main_key.get()) > 0 and len(self.secondary_key.get()) > 0:
            self.exportButton["state"] = tk.NORMAL
            return tk.NORMAL
        else:
            self.exportButton["state"] = tk.DISABLED
            return tk.DISABLED
    def concatenate(self,other):
        global myClasses
        if self != other and self.main_key.get() == other.main_key.get():
            self.parsedkeys += other.parsedkeys
            self.filetext += "\n" + other.filetext
            other.myDestroy()
            #print("Matched {} with {}".format(self.main_key.get(),other.main_key.get()))
    # Representation etc
    def __repr__(self):
        return "Saved: " + ", ".join([self.main_key.get(),self.secondary_key.get(),self.parsedkeys[0] + ",..."])
        
        
def filePrompt():
    return tk.filedialog.askopenfilename(initialdir="../", title="Select File", filetypes=(("Text Files","*.txt"),("All Files","*.*")))

def addFile():
    try: 
        temp = filePrompt()
        if temp != "":
            myClass(temp)
    except:
        pass
    
def exportAll():
    global myClasses
    exportlist = [[C.main_key.get(),C.secondary_key.get(),C.parsedkeys] for C in myClasses]
    exportlist = inj.filter_duplicate_keys(exportlist)
    exportlist = inj.initial_template + inj.injector_maker_list(exportlist)
    with open("exported_injectors.txt","w",encoding='utf-8-sig') as injector_file:
        injector_file.write(exportlist)
    

def loadExportList():
    with open("saved_injectors.txt","r",encoding='utf-8-sig') as file:
        s = []
        for i in file.readlines():
            s+=[i.replace("\n","")]
            if len(s) == 4:
                myClass(s[0],s[1],s[2],int(s[3]))
                #print(s)
                s = []

def saveExportList():
    global myClasses
    with open("saved_injectors.txt","w",encoding='utf-8-sig') as file:
        for C in myClasses:
            print(C)
            file.write(C.filetext+"\n")
            file.write(C.main_key.get()+"\n")
            file.write(C.secondary_key.get()+"\n")
            file.write(str(C.inspectionLevel)+"\n")
            #for i in C.parsedkeys:
            #    file.write(i+"\n")
            #file.write(separator)
# def mergeKeys():
#     global myClasses
#     for C in myClasses:
#         for c in myClasses:
#             C.concatenate(c)
#        matchingclasses = [c.dataTriplet() for c in myClasses if c.main_key.get() == C.main_key.get()]   
#        print(matchingclasses)
NotificationLabel = """"Export All" automatically merges Main Keys,
using the first valid Secondary Key."""
def dumpTutorial():
    with open("tutorial.info","w",encoding='utf-8-sig') as file:
        file.write(tut.tutorial_examples_0)
        file.write(tut.tutorial_examples_1)
        file.write(tut.tutorial_examples_2)
        file.write(tut.tutorial_examples_3)
        file.write(tut.tutorial_examples_4)
        file.write(tut.tutorial_examples_5)
        file.write(tut.tutorial_examples_6)

# Stolen from stackoverflow, idk
#def on_configure(event):
#    global canvas
    # update scrollregion after starting 'mainloop'
    # when all widgets are in canvas
#    canvas.configure(scrollregion=canvas.bbox('all'))
def onFrameConfigure(canvas):
    canvas.configure(scrollregion=canvas.bbox("all"))
    
def populate(frame):
    '''Put in some fake data'''
    for row in range(100):
        tk.Label(frame, text="%s" % row, width=3, borderwidth="1", 
                 relief="solid").grid(row=row, column=0)
        t="this is the second column for row %s" %row
        tk.Label(frame, text=t).grid(row=row, column=1)



def on_mousewheel(event):
    global canvas
    canvas.yview_scroll(int(-1*(event.delta/120)), "units")



def main():
    global canvas
    global frame
    global sframe
    global root
    root = tk.Tk()
    root.title("Injector Maker v0.1")
    
    twocanvas = tk.Canvas(root,bg="grey",height=700,width=800)
    twocanvas.pack()
    canvas = tk.Canvas(twocanvas,bg="grey", height=600,width=900)
    canvas.pack( fill="both", expand=True)
    twocanvas.create_window((0,0), window=canvas, anchor="nw")
    #canvas.place(y = 2,height=800,width=1100)
    
    #sframe = ScrolledFrame(canvas,bg="black")
    #sframe.bind_arrow_keys(root)
    #sframe.bind_scroll_wheel(root)
    #sframe.place(relwidth=1, relheight=1,rely=0)

    #frame.pack()
    #tframe = tk.Frame(canvas,height=800,width=1100, bg="black")
    #tframe.place(relwidth=1, relheight=0.85,rely=0)
    frame = tk.Frame(canvas,bg="blue",)
    frame.pack()
    #frame.place(height=800,width=1100)#(relwidth=1, relheight=1,rely=0)

    #lbox = tk.Listbox(frame,bg="black")
    #frame.pack()
    scrollbar = tk.Scrollbar(root,command=canvas.yview)
    scrollbar.place(width = 20, height=605, relx=1, x= -20)
    #scrollbar.pack( side = tk.RIGHT, fill = tk.Y )
    #scrollbar.pack()
    canvas.configure(yscrollcommand = scrollbar.set)
    canvas.bind_all("<MouseWheel>", on_mousewheel)
    #scrollbar.config( command = frame.yview )
    #canvas.bind('<Configure>', on_configure)
    
    #canvas.configure(scrollregion=(0,0,800,800))#canvas.bbox("all"))
    #canvas.create_window((0,0), window=tframe, anchor='nw')

    canvas.create_window((0,0), window=frame, anchor="nw")
    frame.bind("<Configure>", lambda event, canvas=canvas: onFrameConfigure(canvas))
    #populate(frame)

    buttongrid = tk.Frame(twocanvas, bg="grey")
    buttongrid.place(relx=0, rely=1, y = -100, relwidth = 1, height = 100)
    #buttongrid.pack()
    
    myButton1 = tk.Label(buttongrid, text = NotificationLabel, bg = "grey", width = 50).grid(row = 0, column = 0,columnspan = 5)
    myButton2 = tk.Button(buttongrid, text = "Add File", command=addFile).grid(row = 1, column = 1)
    myButton3 = tk.Label(buttongrid, text = "   ", bg = "grey").grid(row = 1, column = 2)
    myButton4 = tk.Button(buttongrid, text = "Export All", command=exportAll).grid(row = 2, column = 1)#.place(relx=0.9, rely=0.9)
    myButton5 = tk.Label(buttongrid, text = "   ", bg = "grey").grid(row = 1, column = 4)
    myButton6 = tk.Button(buttongrid, text = "Save Export List", command=saveExportList).grid(row = 1, column = 3)#.place(relx=0.9, rely=0.9)
    myButton7 = tk.Button(buttongrid, text = "Load Export List", command=loadExportList).grid(row = 2, column = 3)#.place(relx=0.9, rely=0.9)
   # myButton8 = tk.Label(buttongrid, text = "   ", bg = "grey").grid(row = 1, column = 6)
    myButton9 = tk.Button(buttongrid, text = "Dump Tutorial.info", command=dumpTutorial).grid(row = 2, column = 5)#.place(relx=0.9, rely=0.9)

    root.mainloop()

if __name__ == "__main__":
    main()