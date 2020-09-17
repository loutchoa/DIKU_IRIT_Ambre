function [Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs] = Calculer_Imgs_2_Dioptres(...
    Pts_Dioptres, R, t, Matrice_De_Calibrage, Masques_Imgs)
    [Nb_Lignes, Nb_Colonnes, Nb_Imgs] = size(Masques_Imgs) ;
    Masques_Imgs_Projections_Pts_Dioptres = zeros(size(Masques_Imgs), 'logical') ;
    Imgs_2_Dioptres = zeros(Nb_Lignes, Nb_Colonnes, 3, Nb_Imgs) ;
    Dioptres_2_Imgs = cell(Nb_Imgs, 1) ;
    for i = 1:Nb_Imgs
        [Masque_Img_Projections_Pts_Dioptre_i, Img_2_Dioptre_i, Dioptre_2_Img_i] = Calculer_Img_2_Dioptre(...
            Pts_Dioptres{i}, R(:, :, i), t(i, :)', Matrice_De_Calibrage, Masques_Imgs(:, :, i)) ;
        Masques_Imgs_Projections_Pts_Dioptres(:, :, i) = Masque_Img_Projections_Pts_Dioptre_i ;
        Imgs_2_Dioptres(:, :, :, i) = Img_2_Dioptre_i ;
        Dioptres_2_Imgs(i) = {Dioptre_2_Img_i} ;
    end
end


function [Masque_Img_Projections_Pts_Dioptre, Img_2_Dioptre, Dioptre_2_Img] = Calculer_Img_2_Dioptre(...
    Pts_Dioptre, R, t, Matrice_De_Calibrage, Masque_Img)
    
    Nb_Pts_Dioptre = size(Pts_Dioptre, 1) ;

    % Positions des points du dioptre dans le repère Caméra
    Pts_Dioptre_Repere_Camera = R*(Pts_Dioptre' - repmat(t, 1, Nb_Pts_Dioptre)) ;

    % Positions des projections des points du dioptre sur le plan
    % image dans le repère Caméra
    Projections_Pts_Dioptre = Pts_Dioptre_Repere_Camera./Pts_Dioptre_Repere_Camera(3,:) ;

    % Pixels de l'Image sur lesquels tombent les projections
    Coord_Pixels = Matrice_De_Calibrage*Projections_Pts_Dioptre ;
    Coord_Pixels = round(Coord_Pixels(2:-1:1, :))'; % Coord_Pixels = [Ligne, Colonne]

    Masque_Img_Projections_Pts_Dioptre = zeros(size(Masque_Img), 'logical') ;
    [Nb_Lignes, Nb_Colonnes] = size(Masque_Img) ;
    Img_2_Dioptre = zeros(Nb_Lignes, Nb_Colonnes, 3) ;
    for k = 1:Nb_Pts_Dioptre
        i = Coord_Pixels(k,1) ;
        j = Coord_Pixels(k,2) ;
        if (1 <= i) && (i <= Nb_Lignes) && (1 <= j) && (j <= Nb_Colonnes)
            Masque_Img_Projections_Pts_Dioptre(i, j) = 1 ;
            Img_2_Dioptre(i, j, :) = Pts_Dioptre(k, :) ;
        end
    end
    Masque_Img_Projections_Pts_Dioptre = Masque_Img .* Masque_Img_Projections_Pts_Dioptre ;
    Dioptre_2_Img = Coord_Pixels ;
end
