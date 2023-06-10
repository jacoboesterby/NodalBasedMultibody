# -*- coding: utf-8 -*-
"""
Created on Thu Jun  8 09:27:57 2023

@author: T3FCYPQ
"""
from paraview.simple import *


folder = "C:\Temp\FlexibleRotorScripts\\"
file = "out.vtk"


filename = folder + file
print("Filename = {:s}".format(filename))
reader = Xdmf3ReaderT(FileName=filename)
if reader:
    print("Loading succeeded!")
else:
    print("Loading failed. Try another file")
    
    
filter1 = WarpByScalar(Input=reader,Normal = [1,0,0],Scalars="x")
filter2 =  WarpByScalar(Input=filter1,Normal = [0,1,0],Scalars="y")
filter3 =  WarpByScalar(Input=filter2,Normal = [0,0,1],Scalars="z")