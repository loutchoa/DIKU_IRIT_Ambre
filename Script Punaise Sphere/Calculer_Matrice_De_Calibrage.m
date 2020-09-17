function K = Calculer_Matrice_De_Calibrage(Nb_De_Lignes, Nb_De_Colonnes, camera)
    u0 = Nb_De_Colonnes/2 ;
    v0 = Nb_De_Lignes/2 ;
    f = (camera.focal/camera.sensorLength)*Nb_De_Colonnes ;
    K = [f 0 u0;
         0 f v0;
         0 0 1];
end
