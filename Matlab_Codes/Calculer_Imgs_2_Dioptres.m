%% Masques_Imgs_Projections_Pts_Dioptres = masques des points du dioptre se reprojetant dans chaque image
%% Imgs_2_Dioptres(i,j,k) = Point du dioptre se reprojetant au pixel i,j de l'image k
%% Dioptre_2_Img(i) = coordonées des pixels de l'image i dans lesquels se repojettent les points du dioptre

function [Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs, usedDiopterPoints] = Calculer_Imgs_2_Dioptres(camera, Masques_Imgs)
    [Nb_Lignes, Nb_Colonnes, Nb_Imgs] = size(Masques_Imgs);
    Masques_Imgs_Projections_Pts_Dioptres = zeros(size(Masques_Imgs), 'logical');
    Imgs_2_Dioptres = zeros(Nb_Lignes, Nb_Colonnes, 3, Nb_Imgs);
    Dioptres_2_Imgs = cell(Nb_Imgs, 1);

    for i = 1:Nb_Imgs
        [Masque_Img_Projections_Pts_Dioptre_i, Img_2_Dioptre_i, Dioptre_2_Img_i, usedDiopterPoints_i] = Calculer_Img_2_Dioptre(...
            camera.visiblePoints{i}, camera.R(:, :, i), camera.t(i, :)', camera.K, Masques_Imgs(:, :, i)) ;
        Masques_Imgs_Projections_Pts_Dioptres(:, :, i) = Masque_Img_Projections_Pts_Dioptre_i ;
        Imgs_2_Dioptres(:, :, :, i) = Img_2_Dioptre_i ;
        usedDiopterPoints{i} = usedDiopterPoints_i;
        Dioptres_2_Imgs(i) = {Dioptre_2_Img_i};
    end
end


function [diopter_mask, Img_2_Dioptre, Dioptre_2_Img, usedDiopterPoints] = Calculer_Img_2_Dioptre(Pts_Dioptre, R, t, Matrice_De_Calibrage, mask)
    
    Nb_Pts_Dioptre = size(Pts_Dioptre, 1) ;
  
    diopterPointsCamFrame = R*(Pts_Dioptre' - repmat(t, 1, Nb_Pts_Dioptre));
	diopterPointsImageFrame = Matrice_De_Calibrage*(diopterPointsCamFrame./diopterPointsCamFrame(3,:));
	Dioptre_2_Img = [round(diopterPointsImageFrame(2,:))' round(diopterPointsImageFrame(1,:))'];
    
    diopter_mask = zeros(size(mask), 'logical');
    [Nb_Lignes, Nb_Colonnes] = size(mask);
    
    usedPixels = sub2ind([Nb_Lignes Nb_Colonnes], Dioptre_2_Img(:,1),Dioptre_2_Img(:,2));
    diopter_mask(usedPixels) = 1;
    [usedPixels, usedDiopterPoints, ~] = unique(usedPixels,'rows','stable');
 
    diopter_mask = mask .* diopter_mask ;
    imask = find(diopter_mask);
    
    [usedPixels, indexes] = intersect(usedPixels, imask);
    usedDiopterPoints = usedDiopterPoints(indexes);

    Img_2_Dioptre = zeros(Nb_Lignes*Nb_Colonnes, 3);
    Img_2_Dioptre(usedPixels,:) = Pts_Dioptre(usedDiopterPoints,:);
    Img_2_Dioptre = reshape(Img_2_Dioptre, [Nb_Lignes, Nb_Colonnes, 3]);

	%Distances2Diopter_i = sqrt(sum((Pts_Dioptre(usedDiopterPoints,:)' - repmat(t,1,length(usedDiopterPoints))).^2, 1));
end
