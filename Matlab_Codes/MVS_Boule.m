function [reconstructedPoints, colors] = MVS_Boule(data, camera, params, options, diopter);

    [nb_rows, nb_col, nb_ch, nb_im] = size(data.Imgs);

	% We focus on pixels of the diopter that are visible in the reference image :
	indexes = find(data.Masque_Proj_Ref);
    numPixels = length(indexes);
    selectedPixels = data.imStereo(indexes, :, :, 1);
    
    reconstructedPoints = zeros(numPixels, 3);
    colors = zeros(numPixels, 3);





	%% On récupère les différentes variables : à faire propre !
	Profondeur = options.Profondeur;
    Imgs_2_Dioptres = data.Imgs_2_Dioptres;
	Dioptre_2_Img = data.Dioptres_2_Imgs;
    
    usedDiopterPointsMain = diopter.usedDiopterPoints{1};
    P0 = diopter.points(usedDiopterPointsMain,:);





    % Incident rays :
    incidentRays = P0 - camera.t(1,:);
	normIR = sqrt(sum(incidentRays.^2,2));
	incidentRays = incidentRays./normIR;
	
	% Refracted rays :
	refractedRays = zeros(size(incidentRays));
    for i = 1:length(usedDiopterPointsMain)
		refractedRays(i,:) = applyRefraction(incidentRays(i,:)', diopter.normals(usedDiopterPointsMain(i),:)', params.n1, params.n2);
	end
	
	% Find steps for each rays
    Pmax = diopter.points(usedDiopterPointsMain,:) + refractedRays*Profondeur;
    step = (Pmax - diopter.points(usedDiopterPointsMain,:))/options.nb_steps;
    
    % Score array for the MVS :
    Scores = Inf*ones(numPixels, options.nb_steps);     
    
    
    
    
    
    %% Heart of the MVS :
    %%%%%%%%%%%%%%%%%%%%%    
    for currentStep = 1:options.nb_steps
        
		% 3D points corresponding to the image pixels associated with the current depth :
        all_Pj = diopter.points(usedDiopterPointsMain,:) + currentStep*step;

        Boolean_Break = zeros(length(usedDiopterPointsMain),1); % will be set to one if a 3D pixel fall outside of the witness mask in one of the images :
        Scores_values = zeros(numPixels, 1); % used to build Scores array

		% Pour chaque point de l'image : (boucle à supprimer !)
        for currentIndex = 1:numPixels
        
			Pj = all_Pj(currentIndex,:);
			% Le voisinage du pixel de l'image principal est directement lisible de par la disposition 
			Fenetre_Img_Ref = selectedPixels(currentIndex, :, :);
        
			% We project the points in each witness image :           
			for currentWitn = [data.ctrlImgs_list data.witnImgs_list]
			
				% on évalue le point reprojeté :
				currentUsedDiopterPoints = diopter.usedDiopterPoints{currentWitn};
				
                [~, Indice_pij_prime] = Calcul_de_pij_prime_Discret(camera.t(currentWitn, :)', Pj, camera.visiblePoints{currentWitn}, params.n1, params.n2);
                currentDioptre_2_Img = Dioptre_2_Img{currentWitn};
                
				pij = currentDioptre_2_Img(Indice_pij_prime, :)';
				
				if(pij(1) <= 0 && pij(2) <= 0)
					Boolean_Break(currentIndex) = 1 ;
					break
				end
				
				ind_temoin = sub2ind([nb_rows, nb_col],pij(1),pij(2));

				% Check if the projection is in the mask :
				if (data.mask(pij(1), pij(2), currentWitn))
					if ismember(currentWitn, data.ctrlImgs_list)
						% Ne pas calculer de score
					else
						% On retrouve le pixel 
						ind_temoin = sub2ind([nb_rows, nb_col],pij(1),pij(2));
						Fenetre_Img_Temoin_ij = data.imStereo(ind_temoin, :, :, currentWitn);
						Score_j = sum(abs(Fenetre_Img_Ref(:)-Fenetre_Img_Temoin_ij(:)));                          
						Scores_values(currentIndex) = Scores_values(currentIndex) + Score_j ;
					end
				else
					Boolean_Break(currentIndex) = 1 ;
					break
				end
            
			end
        end
	
		valid = find(~Boolean_Break);
		Scores(valid, currentStep) = Scores_values(valid);
        
    end
    
    [min_vals,min_idx] = min(Scores,[],2);
	test = find(min_vals<Inf);
	reconstructedPoints = diopter.points(usedDiopterPointsMain(test),:) + min_idx(test).*step(test,:);
    colors = ones(size(reconstructedPoints));
end
