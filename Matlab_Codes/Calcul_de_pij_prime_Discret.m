function [pij_prime, Indice_pij_prime] = Calcul_de_pij_prime_Discret_M(...
    Position_Camera_i, Pj, Pts_Dioptre_Temoin, n_Air, n_Ambre)
    
    Nb_De_Voisins = size(Pts_Dioptre_Temoin, 1) ;
    Distance_Ambre = sqrt(sum((Pts_Dioptre_Temoin' - repmat(Pj',1,Nb_De_Voisins)).^2, 1))' ;
    Distance_Air = sqrt(sum((Pts_Dioptre_Temoin' - repmat(Position_Camera_i,1,Nb_De_Voisins)).^2, 1))' ;
    Temps_Parcours = n_Ambre*Distance_Ambre + n_Air*Distance_Air ;
    [~, Indice_Minimum] = min(Temps_Parcours) ;
    pij_prime = Pts_Dioptre_Temoin(Indice_Minimum, :)' ;
    Indice_pij_prime = Indice_Minimum ;
end
