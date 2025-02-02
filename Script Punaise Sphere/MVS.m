function [Cloud, Color] = MVS(data, camera, interface, options, param)
    Img_ref = data.Imgs(:, :, :, 1);
    Img_ref_R = Img_ref(:, :, 1) ;
    Img_ref_G = Img_ref(:, :, 2) ;
    Img_ref_B = Img_ref(:, :, 3) ;
    
    interfacePoints2Pixels_ref = camera.interfacePoints2Pixels{1} ;
    nb_pixels_ref = size(interfacePoints2Pixels_ref, 1) ;
    pixels_ref = interfacePoints2Pixels_ref(:, 2) ;
    
    Color = [Img_ref_R(pixels_ref) Img_ref_G(pixels_ref) Img_ref_B(pixels_ref)] ;
    clear Img_ref Img_ref_R Img_ref_G Img_ref_B ;
    
    % Fenetre de (Taille_Fenetre_SAD*Taille_Fenetre_SAD) pixels autour
    % du pixel de l'Image De Reference        
    pixels_ref = repmat(pixels_ref, 1, options.numberOfSteps);
    Fenetre_Img_Ref = data.imStereo(pixels_ref, :, :, 1);
    clear pixels_ref ;
    
    points_ref = interfacePoints2Pixels_ref(:, 1);
    clear interfacePoints2Pixels_ref ;
    P_tilde = interface.points(points_ref, :)';

    % Vecteur Directeur Unitaire du Rayon Incident
    t_ref = camera.t(1, :)' ; % Position Camera de Reference
    directionIncidentRay = P_tilde - repmat(t_ref, 1, nb_pixels_ref);
    clear t_ref ;
    euclideanNorm = sqrt(sum(directionIncidentRay.^2, 1)) ;
    directionIncidentRay = directionIncidentRay ./ euclideanNorm ;
    clear euclideanNorm ;
    
    % Vecteur Directeur Unitaire du Rayon Refracte
    interfaceNormals = interface.normals(points_ref, :)' ;
    clear points_ref ;
    directionRefractedRay = getDirectionRefractedRay(directionIncidentRay, interfaceNormals, param) ;
    clear directionIncidentRay interfaceNormals ;
    
    P_max = P_tilde + directionRefractedRay*options.depthMax ;
    clear directionRefractedRay ;
    stepVector = (P_max-P_tilde) ./ options.numberOfSteps ;
    clear P_max ;
    
    P_tilde = repmat(P_tilde, 1, 1, options.numberOfSteps) ;
    stepNumber = repmat(reshape(1:options.numberOfSteps, 1, 1, []), 3, nb_pixels_ref, 1)  ;
    stepVector = repmat(stepVector, 1, 1, options.numberOfSteps) ;
    Pk = P_tilde + stepNumber.*stepVector ;
    clear P_tilde stepVector stepNumber ;
    
    [~, ~, ~, nb_pict] = size(data.Imgs) ;      % [nb_rows, nb_cols, nb_ch, nb_pict]
    SAD = zeros(nb_pixels_ref, options.numberOfSteps, nb_pict-1) ;
    
    for witnImg_number = 2:nb_pict
        P_bar = getPointOfRefraction(witnImg_number, Pk, camera, interface, param) ;
        interfacePoints2Pixels_witn = camera.interfacePoints2Pixels{witnImg_number} ;
        [ismemberBool, index] = ismember(P_bar, interfacePoints2Pixels_witn(:, 1)) ;
        
        if witnImg_number <= data.indLastWitness % Witness Img
            index(index==0) = 1 ;
            pixels_witn = interfacePoints2Pixels_witn(index, 2) ;
            % Usefull for debugging :
            % pixels_tem = reshape(pixels_tem, size(index)) ;
            Fenetre_Img_Temoin = data.imStereo(pixels_witn, :, :, witnImg_number);
            SAD_witn = sum(sum(abs(Fenetre_Img_Ref - Fenetre_Img_Temoin), 2), 3) ;
            SAD_witn = reshape(SAD_witn, size(index)) ;
        else % Control Img
            SAD_witn = zeros(nb_pixels_ref, options.numberOfSteps) ;
        end
        SAD_witn(ismemberBool==0) = Inf ;
        SAD(:, :, witnImg_number-1) = SAD_witn ;
    end
    clear Fenetre_Img_Ref nb_pict witnImg_number interfacePoints2Pixels_witn ismemberBool index pixels_witn Fenetre_Img_Temoin SAD_witn ;
    Score = sum(SAD, 3) ;
    isinsideBool = isInsideVolume(Pk, interface) ;
    Score(isinsideBool==0) = Inf ;
    clear isinsideBool ;
    [bestMatchScore, bestMatchIndex] = min(Score, [], 2) ;
    Cloud = Pk(:, sub2ind([nb_pixels_ref, options.numberOfSteps], 1:nb_pixels_ref, bestMatchIndex'))' ;
    clear nb_pixels_ref Pk ;
    Cloud(bestMatchScore == Inf, :) = [] ;
    Color(bestMatchScore == Inf, :) = [] ;
end
