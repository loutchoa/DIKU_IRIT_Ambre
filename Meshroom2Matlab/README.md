# Meshroom2Matlab

Read camera.sfm file created by Meshroom (in StructureFromMotion folder) and extract cameras matrices R and C, and intrinsic matrix K
so that :  P(cam) = R x P(world) - R x C

Output : 

 * R : rotation matrices (3x3xnbCam)
 * C : poses (3xnbCam)
 * K : intrinsic matrix (3x3)

### Use :

node getCam.js 'Path/to/cameras.sfm'                 prints the matrices

node getCam.js 'Path/to/cameras.sfm' > yourFile.m    writes the matrices in a matlab file which can be read in matlab environment (the data can then be saved)

### Warning :

The indexes in R and C matrices follow the order of reconstruction in Meshroom, it can differ from the original picture order.

### To do :

Get the R and C matrices in the pictures original order (in progress)
