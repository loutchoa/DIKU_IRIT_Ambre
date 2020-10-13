function Bool = isInsideVolume(Pk, interface)

switch interface.shape

	case 'sphere'
        [~, nbPixels, nbOfSteps, ~] = size(Pk) ;
        sphereCenter = repmat(interface.center, 1, nbPixels, nbOfSteps) ;
        Bool = (squeeze(dot((sphereCenter-Pk), (sphereCenter-Pk))) < interface.radius^2) ;
	otherwise
		disp('This case has not been implemented yet')
	end