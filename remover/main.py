import os
import tkinter as Tk
import tkinter.ttk as ttk
import tkinter.filedialog as fdl
import tkinter.messagebox as msgb
from PIL import Image


targetName="sample"
file=targetName+".png"

widthBorder=0.8

im = Image.open(file)
print(im.format, im.size, im.mode)
im.show()
new_im=im.crop((0,0,im.width*border,im.height))
new_im.show()
new_im.save(targetName+"-Trimmed.png")
