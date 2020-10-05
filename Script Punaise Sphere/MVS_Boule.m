function [Nuage, Couleur] = MVS_Boule(data, camera, interface, interfacePoints2Pixels, options, param)
    
    [nb_rows, nb_cols, nb_ch, nb_pict] = size(data.Imgs) ;
    Img_Ref = data.Imgs(:, :, :, 1);
    interfacePoints2Pixels_Ref = interfacePoints2Pixels{1} ;
    Nb_De_Pixels_A_Projeter = size(interfacePoints2Pixels_Ref, 1) ;
    % N = (options.SADsize - 1) / 2 ;
    
    Img_Ref_R = Img_Ref(:, :, 1) ;
    Img_Ref_G = Img_Ref(:, :, 2) ;
    Img_Ref_B = Img_Ref(:, :, 3) ;
    pixels_ref = interfacePoints2Pixels_Ref(:, 2) ;
    Couleur = [Img_Ref_R(pixels_ref) Img_Ref_G(pixels_ref) Img_Ref_B(pixels_ref)] ;
    
    % Fenetre de (Taille_Fenetre_SAD*Taille_Fenetre_SAD) pixels autour
    % du pixel de l'Image De Reference        
    pixels_ref = repmat(pixels_ref, 1, options.numberOfSteps);
    Fenetre_Img_Ref = data.imStereo(pixels_ref, :, :, 1);
    
    points_ref = interfacePoints2Pixels_Ref(:, 1);
    P0 = interface.points(points_ref, :)';

    % Vecteur Directeur Unitaire du Rayon Incident
    t_Ref = camera.t(1, :)' ; % Position Camera de Reference
    VD_Unitaire_Rayon_Incident = P0 - repmat(t_Ref, 1, Nb_De_Pixels_A_Projeter);
    euclideanNorm = sqrt(sum(VD_Unitaire_Rayon_Incident.^2, 1)) ;
    VD_Unitaire_Rayon_Incident = VD_Unitaire_Rayon_Incident ./ euclideanNorm ;
    
    % Vecteur Directeur du Rayon Refracte
    Normale_Au_Dioptre_Reference = interface.normals(points_ref, :)' ;
    VD_Unitaire_Rayon_Refracte = ...
        Calculer_VD_Du_Rayon_Refracte(VD_Unitaire_Rayon_Incident, ...
        Normale_Au_Dioptre_Reference, param.IOR_1, param.IOR_2) ;
    
    Pmax = P0 + VD_Unitaire_Rayon_Refracte*options.depthMax ;
    Pas = (Pmax-P0) ./ options.numberOfSteps ;
    
    P0 = repmat(P0, 1, 1, options.numberOfSteps) ;
    Numero_Tranche = repmat(reshape(1:options.numberOfSteps, 1, 1, []), 3, Nb_De_Pixels_A_Projeter, 1)  ;
    Pas = repmat(Pas, 1, 1, options.numberOfSteps) ;
    Pk = P0 + Numero_Tranche.*Pas ;
    
    Score = zeros(Nb_De_Pixels_A_Projeter, options.numberOfSteps) ;
    
    for Numero_Image_Temoin = 2:nb_pict
        P_barre = Calcul_Plus_Court_Chemin(Numero_Image_Temoin, Pk, camera, interface, param) ;
        interfacePoints2Pixels_Temoin = interfacePoints2Pixels{Numero_Image_Temoin} ;
        [Bool, index] = ismember(P_barre, interfacePoints2Pixels_Temoin(:, 1)) ;
        
        if Numero_Image_Temoin <= data.indLastWitness
            index(index==0) = 1 ;
            pixels_tem = interfacePoints2Pixels_Temoin(index, 2) ;
            Fenetre_Img_Temoin = data.imStereo(pixels_tem, :, :, Numero_Image_Temoin);
            SAD_tem = sum(sum(abs(Fenetre_Img_Ref - Fenetre_Img_Temoin), 2), 3) ;
            SAD_tem = reshape(SAD_tem, size(index)) ;
        else
            SAD_tem = zeros(Nb_De_Pixels_A_Projeter, options.numberOfSteps) ;
        end
        SAD_tem(Bool==0) = Inf ;
        Score = Score + SAD_tem ;
    end
    [bestMatchScore, bestMatchIndex] = min(Score, [], 2) ;
    Nuage = Pk(:, sub2ind([Nb_De_Pixels_A_Projeter, options.numberOfSteps], 1:Nb_De_Pixels_A_Projeter, bestMatchIndex'))' ;
    Nuage(bestMatchScore == Inf, :) = [] ;
    Couleur(bestMatchScore == Inf, :) = [] ;
end
