function [Nuage, Couleur] = MVS_Boule(data, camera, params, options, diopter);

	%% On récupère les différentes variables : à faire propre !
	Liste_Num_Img_Ctrl = data.Liste_Num_Img_Ctrl;
	Liste_Num_Imgs_Temoins = data.Liste_Num_Imgs_Temoins;

	Profondeur = options.Profondeur;	
    Masques_Imgs = data.Masques_Imgs;
    
    Masques_Imgs_Projections_Pts_Dioptres = data.Masques_Imgs_Projections_Pts_Dioptres;
    Imgs_2_Dioptres = data.Imgs_2_Dioptres;

	Pts_Dioptres = diopter.pointsCELL;
	Dioptre_2_Img = data.Dioptres_2_Imgs;
	
    t = camera.t;
    
	Masque_Img_Ref = data.Masques_Imgs;
	Masque_Proj_Ref = data.Masque_Proj_Ref;
        
    indexes = find(Masque_Proj_Ref);
    Nb_De_Pixels_A_Projeter = length(indexes);
    
    [Nb_De_Lignes, Nb_De_Colonnes, ~, ~] = size(data.Imgs) ;
    Nuage = zeros(Nb_De_Pixels_A_Projeter, 3) ;
    Couleur = zeros(Nb_De_Pixels_A_Projeter, 3) ;
    
    selectedPixels = data.imStereo(indexes, :, :, 1);
    usedDiopterPointsMain = diopter.usedDiopterPoints{1};
    P0 = diopter.points(usedDiopterPointsMain,:);
    
    t_Ref = t(1,:);
    
    % On évalue les rayons incidents :
    incidentRays = P0 - t_Ref;
	normIR = sqrt(sum(incidentRays.^2,2));
	incidentRays = incidentRays./normIR;
	
	% On évalue l'ensemble des rayons réfractés 
	refractedRays = zeros(size(incidentRays));
    for i = 1:length(usedDiopterPointsMain)
		refractedRays(i,:) = Calculer_VD_Du_Rayon_Refracte(incidentRays(i,:)', diopter.normals(usedDiopterPointsMain(i),:)', params.n1, params.n2);
	end
	
	
    Pmax = diopter.points(usedDiopterPointsMain,:) + refractedRays*Profondeur;
    Pas = (Pmax - diopter.points(usedDiopterPointsMain,:))/options.nb_steps;
    Scores = Inf*ones(Nb_De_Pixels_A_Projeter, options.nb_steps);     
    
    % Pour chaque profondeur :
    for Numero_Tranche = 1:options.nb_steps
        
		% On calcue les points projetés :
        all_Pj = diopter.points(usedDiopterPointsMain,:) + Numero_Tranche*Pas; % j = Numero_Tranche
        
        Booleen_Break = zeros(length(usedDiopterPointsMain),1);
        Scores_values = zeros(Nb_De_Pixels_A_Projeter, 1); 

		% Pour chaque point de l'image : (boucle à supprimer !)
        for currentIndex = 1:length(usedDiopterPointsMain)
        
			Pj = all_Pj(currentIndex,:);
			% Le voisinage du pixel de l'image principal est directement lisible de par la disposition 
			Fenetre_Img_Ref = selectedPixels(currentIndex, :, :);
        
			% Pour chaque image :           
			for Numero_Image_Temoin = [Liste_Num_Img_Ctrl Liste_Num_Imgs_Temoins]
			
				% on évalue le point reprojeté :
				currentUsedDiopterPoints = diopter.usedDiopterPoints{Numero_Image_Temoin};
				
                [~, Indice_pij_prime] = Calcul_de_pij_prime_Discret(t(Numero_Image_Temoin, :)', Pj, Pts_Dioptres{Numero_Image_Temoin}, params.n1, params.n2);
                currentDioptre_2_Img = Dioptre_2_Img{Numero_Image_Temoin};
                
				pij = currentDioptre_2_Img(Indice_pij_prime, :)';
				ind_temoin = sub2ind([Nb_De_Lignes, Nb_De_Colonnes],pij(1),pij(2));

				% on évalue l'erreur :
				if (0 < pij(1)) && (pij(1) <= Nb_De_Lignes) && ...
				(0 < pij(2)) && (pij(2) <= Nb_De_Colonnes) && ...
                   (Masques_Imgs(pij(1), pij(2), Numero_Image_Temoin))
					
					if ismember(Numero_Image_Temoin, Liste_Num_Img_Ctrl)
						% Ne pas calculer de score
					else
						% On retrouve le pixel 
						ind_temoin = sub2ind([Nb_De_Lignes, Nb_De_Colonnes],pij(1),pij(2));
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
	Nuage = diopter.points(usedDiopterPointsMain(test),:) + min_idx(test).*Pas(test,:);
    Couleur = ones(size(Nuage));
end
