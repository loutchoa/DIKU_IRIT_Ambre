function [Nuage, Couleur] = MVS_Boule(Ind_Last_Witness, ...
    Barycentre, Imgs, Masques_Imgs, Pts_Dioptres, ...
    Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, ...
    t, Nb_De_Tranches, n_Air, n_Ambre, Taille_Fenetre_SAD, Profondeur)
    
    Img_Ref = Imgs(:, :, :, 1) ;
    Masque_Img_Ref = Masques_Imgs(:, :, 1) ;
    Masque_Proj_Ref = Masques_Imgs_Projections_Pts_Dioptres(:, :, 1) ;
    
    [Coord_Ligne, Coord_Colonnes] = find(Masque_Proj_Ref) ;
    Coord_Des_Pixels_A_Projeter = [Coord_Ligne, Coord_Colonnes] ;
    Nb_De_Pixels_A_Projeter = size(Coord_Des_Pixels_A_Projeter, 1) ;
    
    N = (Taille_Fenetre_SAD - 1) / 2 ;
    [Nb_De_Lignes, Nb_De_Colonnes, ~, ~] = size(Imgs) ;
    Nuage = zeros(Nb_De_Pixels_A_Projeter, 3) ;
    Couleur = zeros(Nb_De_Pixels_A_Projeter, 3) ;
    Indice = 1 ;
    
    for Numero_Pixel = 1:Nb_De_Pixels_A_Projeter
        % Afficher l'avancement de la MVS
        if mod(Numero_Pixel, 100) == 0
                fprintf(strcat(num2str(Numero_Pixel),'/', ...
                    num2str(Nb_De_Pixels_A_Projeter),'\n'));
        end

        Coord_Pixel = Coord_Des_Pixels_A_Projeter(Numero_Pixel, :)' ;
        
        % Fenetre de (Taille_Fenetre_SAD*Taille_Fenetre_SAD) pixels autour
        % du pixel de l'Image De Reference
        Fenetre_Img_Ref = ...
            Img_Ref(Coord_Pixel(1)-N:Coord_Pixel(1)+N, ...
            Coord_Pixel(2)-N:Coord_Pixel(2)+N, :) ;
        Fenetre_Masque_Img_Ref = ...
            Masque_Img_Ref(Coord_Pixel(1)-N:Coord_Pixel(1)+N, ...
            Coord_Pixel(2)-N:Coord_Pixel(2)+N) ;
        
        P0 = squeeze(Imgs_2_Dioptres(Coord_Pixel(1), Coord_Pixel(2), :, 1)) ;
        
        % Vecteur Directeur Unitaire du Rayon Incident
        t_Ref = t(1, :)' ; % Position Camera de Reference
        VD_Unitaire_Rayon_Incident = (P0 - t_Ref)/norm(P0 - t_Ref) ;
        
        % Vecteur Directeur du Rayon Refracte
        Normale_Au_Dioptre_Reference = (Barycentre - P0)/norm(Barycentre - P0) ;
        VD_Unitaire_Rayon_Refracte = ...
            Calculer_VD_Du_Rayon_Refracte(VD_Unitaire_Rayon_Incident, ...
            Normale_Au_Dioptre_Reference, n_Air, n_Ambre) ;
        
        Pmax = P0 + VD_Unitaire_Rayon_Refracte*Profondeur ;
        Pas = (Pmax-P0) / Nb_De_Tranches ;
        Meilleur_Score = Inf ;
        Booleen_Nuage_Updated = 0 ;
        
        for Numero_Tranche = 1:Nb_De_Tranches
            Pj = P0 + Numero_Tranche*Pas ; % j = Numero_Tranche
            Score = 0 ;
            Booleen_Break = 0 ;
            
            for Numero_Image_Temoin = 2:size(Imgs,4)
                % Position du point pij_prime dans le repère Monde
                % i = Numero_Image_Temoin  ;
                % tic
                [~, Indice_pij_prime] = Calcul_de_pij_prime_Discret(...
                    t(Numero_Image_Temoin, :)', Pj, ...
                    Pts_Dioptres{Numero_Image_Temoin}, n_Air, n_Ambre) ;
                % toc
                Dioptre_2_Img = Dioptres_2_Imgs{Numero_Image_Temoin} ;
                pij = Dioptre_2_Img(Indice_pij_prime, :)' ;
                
                if (0 < pij(1)-N) && (pij(1)+N <= Nb_De_Lignes) && ...
                   (0 < pij(2)-N) && (pij(2)+N <= Nb_De_Colonnes) && ...
                   (Masques_Imgs(pij(1), pij(2), Numero_Image_Temoin))
                    if Numero_Image_Temoin > Ind_Last_Witness % Num_Camera_Ctrl
                        % Ne pas calculer de score
                    else
                        % Fenetre de (Taille_Fenetre_SAD*Taille_Fenetre_SAD)
                        % pixels autour du pixel de l'Image Temoin
                        Fenetre_Img_Temoin_ij = ...
                            Imgs(pij(1)-N:pij(1)+N, ...
                            pij(2)-N:pij(2)+N, :, Numero_Image_Temoin) ;
                        Fenetre_Masque_Img_Temoin_ij = ...
                            Masques_Imgs(pij(1)-N:pij(1)+N, ...
                            pij(2)-N:pij(2)+N, Numero_Image_Temoin) ;
                        Score_j = SAD(Fenetre_Img_Ref, Fenetre_Img_Temoin_ij, ...
                            Fenetre_Masque_Img_Ref, Fenetre_Masque_Img_Temoin_ij) ;
                        Score = Score + Score_j ;
                    end
                else
                    Booleen_Break = 1 ;
                    break
                end
            end
            
            if (Booleen_Break == 0) && (Score < Meilleur_Score)
                Booleen_Nuage_Updated = 1 ;
                Meilleur_Score = Score ;
                Nuage(Indice,:) = Pj';
                Couleur(Indice,:) = Img_Ref(Coord_Pixel(1), Coord_Pixel(2), :) ;
            end
        end
        
        if Booleen_Nuage_Updated == 1
            Indice = Indice + 1 ;
        end
    end
    
    Nuage = Nuage(1:Indice-1,:) ;
    Couleur = Couleur(1:Indice-1,:) ;
end
