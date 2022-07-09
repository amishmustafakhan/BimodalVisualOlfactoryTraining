#compress_images.py
'''
Compress PNG images liscenced from Shutterstock.
These parameters resulted in optimal balance between image quality and load times on web application. 
'''

import PIL, os, re
from PIL import Image

for folder, subfolders, images in os.walk("/Users/amishmustafakhan/Downloads/VOLT_Images"):
    print("The current folder is " + folder)

    for subfolder in subfolders:
        print("The current subfolder is " + subfolder)

    for image in images:
        print("The current image is " + image)
        if image.endswith(".png"):
            path = os.path.join(folder, image)
            img = Image.open(path)
            img.save(path, optimize = True, quality = 50)
