function [Cloud, Color] = MVS(data, camera, interface, options, param)
    
    [~, ~, ~, nb_pict] = size(data.Imgs) ;      % [nb_rows, nb_cols, nb_ch, nb_pict]
    Img_Ref = data.Imgs(:, :, :, 1);
    interfacePoints2Pixels_Ref = camera.interfacePoints2Pixels{1} ;
    nb_pixels_ref = size(interfacePoints2Pixels_Ref, 1) ;
    
    Img_Ref_R = Img_Ref(:, :, 1) ;
    Img_Ref_G = Img_Ref(:, :, 2) ;
    Img_Ref_B = Img_Ref(:, :, 3) ;
    pixels_ref = interfacePoints2Pixels_Ref(:, 2) ;
    Color = [Img_Ref_R(pixels_ref) Img_Ref_G(pixels_ref) Img_Ref_B(pixels_ref)] ;
    
    % Fenetre de (Taille_Fenetre_SAD*Taille_Fenetre_SAD) pixels autour
    % du pixel de l'Image De Reference        
    pixels_ref = repmat(pixels_ref, 1, options.numberOfSteps);
    Fenetre_Img_Ref = data.imStereo(pixels_ref, :, :, 1);
    
    points_ref = interfacePoints2Pixels_Ref(:, 1);
    P0 = interface.points(points_ref, :)';

    % Vecteur Directeur Unitaire du Rayon Incident
    t_Ref = camera.t(1, :)' ; % Position Camera de Reference
    VD_Unitaire_Rayon_Incident = P0 - repmat(t_Ref, 1, nb_pixels_ref);
    euclideanNorm = sqrt(sum(VD_Unitaire_Rayon_Incident.^2, 1)) ;
    VD_Unitaire_Rayon_Incident = VD_Unitaire_Rayon_Incident ./ euclideanNorm ;
    
    % Vecteur Directeur du Rayon Refracte
    Normale_Au_Dioptre_Reference = interface.normals(points_ref, :)' ;
    VD_Unitaire_Rayon_Refracte = ...
        Calculer_VD_Du_Rayon_Refracte(VD_Unitaire_Rayon_Incident, ...
        Normale_Au_Dioptre_Reference, param) ;
    
    Pmax = P0 + VD_Unitaire_Rayon_Refracte*options.depthMax ;
    Pas = (Pmax-P0) ./ options.numberOfSteps ;
    
    P0 = repmat(P0, 1, 1, options.numberOfSteps) ;
    Numero_Tranche = repmat(reshape(1:options.numberOfSteps, 1, 1, []), 3, nb_pixels_ref, 1)  ;
    Pas = repmat(Pas, 1, 1, options.numberOfSteps) ;
    Pk = P0 + Numero_Tranche.*Pas ;
    
    SAD = zeros(nb_pixels_ref, options.numberOfSteps, nb_pict-1) ;
    
    for Numero_Image_Temoin = 2:nb_pict
        P_bar = getPointOfRefraction(Numero_Image_Temoin, Pk, camera, interface, param) ;
        interfacePoints2Pixels_Temoin = camera.interfacePoints2Pixels{Numero_Image_Temoin} ;
        [Bool, index] = ismember(P_bar, interfacePoints2Pixels_Temoin(:, 1)) ;
        
        if Numero_Image_Temoin <= data.indLastWitness
            index(index==0) = 1 ;
            pixels_tem = interfacePoints2Pixels_Temoin(index, 2) ;
            % pixels_tem = reshape(pixels_tem, size(index)) ;
            Fenetre_Img_Temoin = data.imStereo(pixels_tem, :, :, Numero_Image_Temoin);
            SAD_tem = sum(sum(abs(Fenetre_Img_Ref - Fenetre_Img_Temoin), 2), 3) ;
            SAD_tem = reshape(SAD_tem, size(index)) ;
        else
            SAD_tem = zeros(nb_pixels_ref, options.numberOfSteps) ;
        end
        SAD_tem(Bool==0) = Inf ;
        SAD(:, :, Numero_Image_Temoin-1) = SAD_tem ;
    end
    Score = sum(SAD, 3) ;
    [bestMatchScore, bestMatchIndex] = min(Score, [], 2) ;
    Cloud = Pk(:, sub2ind([nb_pixels_ref, options.numberOfSteps], 1:nb_pixels_ref, bestMatchIndex'))' ;
    Cloud(bestMatchScore == Inf, :) = [] ;
    Color(bestMatchScore == Inf, :) = [] ;
end
