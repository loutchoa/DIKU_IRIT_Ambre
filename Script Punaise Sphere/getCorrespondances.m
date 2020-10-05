function [visiblePoints, interfacePoints2Pixels] = getCorrespondances(camera, interface, data)
    Nb_Imgs = size(camera.t, 1);
    visiblePoints = cell(Nb_Imgs, 1);
    interfacePoints2Pixels = cell(Nb_Imgs, 1);
    for i = 1:Nb_Imgs
		center2cam = camera.t(i, :)' - interface.center;
		scalarProduct = interface.normals*center2cam;
		visiblePoints{i} = find(scalarProduct > 0);
        visiblePointsCoord = interface.points(visiblePoints{i}, :);
        Nb_visiblePoints = size(visiblePoints{i}, 1);
        interfacePointsCamFrame = camera.R(:, :, i)*(visiblePointsCoord' - repmat(camera.t(i, :)', 1, Nb_visiblePoints));
        interfacePointsCamFrame = camera.K*(interfacePointsCamFrame./interfacePointsCamFrame(3,:));
        usedPixelsCoord = [round(interfacePointsCamFrame(2,:))' round(interfacePointsCamFrame(1,:))'];
        [nb_rows, nb_col] = size(data.Masques_Imgs(:, :, i)) ;
        usedPixels = sub2ind([nb_rows nb_col], usedPixelsCoord(:,1),usedPixelsCoord(:,2));
        maskPixels = find(data.Masques_Imgs(:, :, i));
        [usedPixels, indexes, ~] = intersect(usedPixels, maskPixels, 'stable');
        % PB : intersect supprime les répétitions donc PB si +sieurs pts 3D
        % se projetent dans le même pixel, alors on en garde qu'un.
        interfacePoints2Pixels{i} = [visiblePoints{i}(indexes) usedPixels] ;
    end
end


%% BROUILLON

% interface_mask = zeros(nb_rows, nb_col, 'logical') ;
% interface_mask(usedPixels) = 1;
% interface_mask = data.Masques_Imgs(:, :, i) .* interface_mask ;
% imask = find(interface_mask);
% [usedPixels, indexes] = intersect(usedPixels, imask);
% [usedPixels, usedDiopterPoints, ~] = unique(usedPixels,'rows','stable');
% usedDiopterPoints = usedDiopterPoints(indexes);
% Img_2_Interf = zeros(nb_rows*nb_col, 1);
% Img_2_Interf(usedPixels,:) = visiblePointsIdx(usedDiopterPoints);
% Img_2_Interf = reshape(Img_2_Interf, [nb_rows, nb_col]);