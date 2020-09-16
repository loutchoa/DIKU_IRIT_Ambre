# Meshroom2Matlab

Read camera.sfm file created by Meshroom (in StructureFromMotion folder) and extract cameras matrices R and t, and intrinsic matrix K
so that :  X(world) = R x X(cam) + t   // to be double-checked

Output : 

 * R : rotation matrices (3x3xnbCam)
 * t : poses (3xnbCam)
 * K : intrinsic matrix (3x3)

### Use :

node getCam.js 'Path/to/cameras.sfm'                 prints the matrices

node getCam.js 'Path/to/cameras.sfm' > yourFile.m    writes the matrices in a matlab file which can be read in matlab environment (the data can then be saved)

### Warning :

The indexes in R and t matrices follow the order of reconstruction in Meshroom, it can differ from the original picture order.

### To do :

Get the R and t matrices in the pictures original order (in progress)
