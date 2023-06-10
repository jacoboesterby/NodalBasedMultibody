# -*- coding: utf-8 -*-
"""
Created on Tue Jun  6 16:00:29 2023

@author: T3FCYPQ
"""
import meshio
import numpy as np
import os

folder = "C:\Temp\FlexibleRotorScripts"


#Move to folder
os.chdir(folder)

#Read nodal values
time = np.loadtxt("NDt.txt",delimiter=',')
#Read total displacement field
x = np.loadtxt("NDx.txt",delimiter=',')
y = np.loadtxt("NDy.txt",delimiter=',')
z = np.loadtxt("NDz.txt",delimiter=',')
#Read elastic displacement field in global coordinates
dx = np.loadtxt("NDdx.txt",delimiter=',')
dy = np.loadtxt("NDdy.txt",delimiter=',')
dz = np.loadtxt("NDdz.txt",delimiter=',')

#Read mesh
mesh = meshio.read("Bar.inp")

#Create mesh with data
mesh2write = meshio.Mesh(mesh.points,mesh.cells)

#Write mesh to vtk file
mesh2write.write("out.vtk")

with meshio.xdmf.TimeSeriesWriter("out.vtk") as writer:
    writer.write_points_cells(mesh2write.points,mesh2write.cells)
    k = 0
    for t in list(time):
        writer.write_data(t,point_data={"y": y[:,k], "z": z[:,k],"x": x[:,k], "dx": dx[:,k], "dy": dy[:,k], "dz": dz[:,k]})
        k = k+1
