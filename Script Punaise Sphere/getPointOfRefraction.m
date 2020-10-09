function P_barre = getPointOfRefraction(...
    Numero_Image_Temoin, Pk, camera, interface, param)

    Cj = camera.t(Numero_Image_Temoin, :)' ;
    Pts_Dioptre = interface.points(camera.visiblePoints{Numero_Image_Temoin}, :)' ;
    n_Air = param.IOR_1 ;
    n_Ambre = param.IOR_2 ;

    Nb_Pts_Dioptre = size(Pts_Dioptre, 2) ;
    Pk = repmat(Pk, 1, 1, 1, Nb_Pts_Dioptre) ;
    [~, nbPixels, nbOfSteps, Nb_Pts_Dioptre] = size(Pk) ;
    Pts_Dioptre = repmat(reshape(Pts_Dioptre, 3, 1, 1, Nb_Pts_Dioptre), 1, nbPixels, nbOfSteps, 1) ;
    Cj = repmat(Cj, 1, nbPixels, nbOfSteps, Nb_Pts_Dioptre) ;
    
    Distance_Ambre = sqrt(dot((Pts_Dioptre-Pk), (Pts_Dioptre-Pk))) ;
    Distance_Air = sqrt(dot((Pts_Dioptre-Cj), (Pts_Dioptre-Cj))) ;
    Temps_Parcours = n_Ambre*Distance_Ambre + n_Air*Distance_Air ;
    Temps_Parcours = squeeze(Temps_Parcours) ;
    
    [~, Indice_Minimum] = min(Temps_Parcours, [], 3) ;
    
    P_barre = camera.visiblePoints{Numero_Image_Temoin}(Indice_Minimum) ;
    % P_barreCoord = interface.points(P_barre(:), :) ;
    % P_barreCoord = reshape(P_barreCoord, 502, 100, 3) ;
end