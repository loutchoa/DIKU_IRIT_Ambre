function [Masques_Imgs_Projections_Pts_Dioptres, Imgs_2_Dioptres, Dioptres_2_Imgs] = Calculer_Imgs_2_Dioptres(...
    Pts_Dioptres, camera, Masques_Imgs)
    [Nb_Lignes, Nb_Colonnes, Nb_Imgs] = size(Masques_Imgs) ;
    Masques_Imgs_Projections_Pts_Dioptres = zeros(size(Masques_Imgs), 'logical') ;
    Imgs_2_Dioptres = zeros(Nb_Lignes, Nb_Colonnes, 3, Nb_Imgs) ;
    Dioptres_2_Imgs = cell(Nb_Imgs, 1) ;
    for i = 1:Nb_Imgs
        [Masque_Img_Projections_Pts_Dioptre_i, Img_2_Dioptre_i, Dioptre_2_Img_i] = Calculer_Img_2_Dioptre(...
            Pts_Dioptres{i}, camera.R(:, :, i), camera.t(i, :)', camera.K, Masques_Imgs(:, :, i)) ;
        Masques_Imgs_Projections_Pts_Dioptres(:, :, i) = Masque_Img_Projections_Pts_Dioptre_i ;
        Imgs_2_Dioptres(:, :, :, i) = Img_2_Dioptre_i ;
        Dioptres_2_Imgs(i) = {Dioptre_2_Img_i} ;
    end
end


function [interface_mask, Img_2_Interf, Interf_2_Img] = Calculer_Img_2_Dioptre(...
    Pts_Dioptre, R, t, K, Masque_Img)
    
    Nb_Pts_Dioptre = size(Pts_Dioptre, 1) ;

    interfacePointsCamFrame = R*(Pts_Dioptre' - repmat(t, 1, Nb_Pts_Dioptre));
	interfacePointsCamFrame = K*(interfacePointsCamFrame./interfacePointsCamFrame(3,:));
	Interf_2_Img = [round(interfacePointsCamFrame(2,:))' round(interfacePointsCamFrame(1,:))'];

    interface_mask = zeros(size(Masque_Img), 'logical') ;
    [Nb_Lignes, Nb_Colonnes] = size(Masque_Img) ;
    
    usedPixels = sub2ind([Nb_Lignes Nb_Colonnes], Interf_2_Img(:,1),Interf_2_Img(:,2));
    interface_mask(usedPixels) = 1;
    [usedPixels, usedDiopterPoints, ~] = unique(usedPixels,'rows','stable');
 
    interface_mask = Masque_Img .* interface_mask ;
    imask = find(interface_mask);
    
    [usedPixels, indexes] = intersect(usedPixels, imask);
	usedDiopterPoints = usedDiopterPoints(indexes);
	
    Img_2_Interf = zeros(Nb_Lignes*Nb_Colonnes, 3);
    Img_2_Interf(usedPixels,:) = Pts_Dioptre(usedDiopterPoints,:);
    Img_2_Interf = reshape(Img_2_Interf, [Nb_Lignes, Nb_Colonnes, 3]);
end
