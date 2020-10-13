function P_bar = getPointOfRefraction(...
    witnImg_number, Pk, camera, interface, param)

    interfacePoints = interface.points(camera.visiblePoints{witnImg_number}, :)' ;
    nbInterfacePoints = size(interfacePoints, 2) ;
    Pk = repmat(Pk, 1, 1, 1, nbInterfacePoints) ;
    [~, nbPixels, nbOfSteps, ~] = size(Pk) ;
    interfacePoints = repmat(reshape(interfacePoints, 3, 1, 1, nbInterfacePoints), 1, nbPixels, nbOfSteps, 1) ;
    Cj = repmat(camera.t(witnImg_number, :)', 1, nbPixels, nbOfSteps, nbInterfacePoints) ;
    
    distanceAmber = sqrt(dot((interfacePoints-Pk), (interfacePoints-Pk))) ;
    distanceAir = sqrt(dot((interfacePoints-Cj), (interfacePoints-Cj))) ;
    opticalPath = param.IOR_2*distanceAmber + param.IOR_1*distanceAir ;
    opticalPath = squeeze(opticalPath) ;
    
    [~, minimumIndex] = min(opticalPath, [], 3) ;
    
    P_bar = camera.visiblePoints{witnImg_number}(minimumIndex) ;
    % P_barCoord = interface.points(P_bar(:), :) ;
    % P_barCoord = reshape(P_barreCoord, nbPixels, nbOfSteps, 3) ;
end