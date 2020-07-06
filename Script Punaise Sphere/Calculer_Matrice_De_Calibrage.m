function K = Calculer_Matrice_De_Calibrage(Nb_De_Lignes, Nb_De_Colonnes, Sensor_Length)
    u0 = Nb_De_Lignes/2 ;
    v0 = Nb_De_Colonnes/2 ;
    f = (90/Sensor_Length)*Nb_De_Colonnes ;
    K = [f 0 u0;
         0 f v0;
         0 0 1];
    K(3,3) = 1 ;
end