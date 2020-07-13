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
    
    
    
    
    
    
    % Pour chaque profondeur :
    for Numero_Tranche = 1:options.nb_steps
        
		% On calcue les points projetés :
        all_Pj = diopter.points(usedDiopterPointsMain,:) + Numero_Tranche*step; % j = Numero_Tranche
        
        Booleen_Break = zeros(length(usedDiopterPointsMain),1);
        Scores_values = zeros(numPixels, 1); 

		% Pour chaque point de l'image : (boucle à supprimer !)
        for currentIndex = 1:length(usedDiopterPointsMain)
        
			Pj = all_Pj(currentIndex,:);
			% Le voisinage du pixel de l'image principal est directement lisible de par la disposition 
			Fenetre_Img_Ref = selectedPixels(currentIndex, :, :);
        
			% Pour chaque image :           
			for Numero_Image_Temoin = [data.ctrlImgs_list data.witnImgs_list]
			
				% on évalue le point reprojeté :
				currentUsedDiopterPoints = diopter.usedDiopterPoints{Numero_Image_Temoin};
				
                [~, Indice_pij_prime] = Calcul_de_pij_prime_Discret(camera.t(Numero_Image_Temoin, :)', Pj, camera.visiblePoints{Numero_Image_Temoin}, params.n1, params.n2);
                currentDioptre_2_Img = Dioptre_2_Img{Numero_Image_Temoin};
                
				pij = currentDioptre_2_Img(Indice_pij_prime, :)';
				ind_temoin = sub2ind([nb_rows, nb_col],pij(1),pij(2));

				% on évalue l'erreur :
				if (0 < pij(1)) && (pij(1) <= nb_rows) && ...
				(0 < pij(2)) && (pij(2) <= nb_col) && ...
                   (data.mask(pij(1), pij(2), Numero_Image_Temoin))
					
					if ismember(Numero_Image_Temoin, data.ctrlImgs_list)
						% Ne pas calculer de score
					else
						% On retrouve le pixel 
						ind_temoin = sub2ind([nb_rows, nb_col],pij(1),pij(2));
						% 
						Fenetre_Img_Temoin_ij = data.imStereo(ind_temoin, :, :, Numero_Image_Temoin);
						Score_j = sum(abs(Fenetre_Img_Ref(:)-Fenetre_Img_Temoin_ij(:)));                          
						Scores_values(currentIndex) = Scores_values(currentIndex) + Score_j ;
					end
				else
					Booleen_Break(currentIndex) = 1 ;
				end
            
			end
        end
	
		valid = find(~Booleen_Break);
		Scores(valid, Numero_Tranche) = Scores_values(valid);
        
    end
    
    [min_vals,min_idx] = min(Scores,[],2);
	test = find(min_vals<Inf);
	reconstructedPoints = diopter.points(usedDiopterPointsMain(test),:) + min_idx(test).*step(test,:);
    colors = ones(size(reconstructedPoints));
end
