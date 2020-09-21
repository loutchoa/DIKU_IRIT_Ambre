function K = evalK(nb_rows, nb_col, camera)
    u0 = nb_col/2;
    v0 = nb_rows/2;
    f = (camera.focal/camera.sensorLength)*nb_col ;
    K = [f 0 u0;
         0 f v0;
         0 0 1];
end
