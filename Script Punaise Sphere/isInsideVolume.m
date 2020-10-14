function Bool = isInsideVolume(Pk, interface)

[~, nbPixels, nbOfSteps, ~] = size(Pk) ;

switch interface.shape
	case 'sphere'
        center = repmat(interface.center, 1, nbPixels, nbOfSteps) ;
        point = center-Pk ; % center on origine
        Bool = (squeeze(dot(point, point)) < interface.radius^2) ;
    case 'ellipsoide'
        center = repmat(interface.center, 1, nbPixels, nbOfSteps) ;
        point = center-Pk ; % center on origine
        point = reshape(point, 3, []) ;                     % ***
        point = interface.rotation * point ; % rotate
        point = reshape(point, 3, nbPixels, nbOfSteps) ;    % ***
        % normalise
        point(1, :, :) = (1/interface.semiAxisA) * point(1, :, :) ;
        point(2, :, :) = (1/interface.semiAxisB) * point(2, :, :) ;
        point(3, :, :) = (1/interface.semiAxisC) * point(3, :, :) ;
        Bool = (squeeze(dot(point, point)) < 1) ;
	otherwise
		disp('This case has not been implemented yet')
end
end