%% Get the direction of the refracted vector based on the Snell-Decartes law

%% Input : 
%%    - incidentRay : direction of the incident ray
%%    - interfaceNormal : normal vector of the interface at the impact point
%%    - n_1, n_2, indexes of refraction of the both medium
%% Output : 
%%    - refractedRay : direction of the refracted ray

function refractedRay = applyRefraction(incidentRay, interfaceNormal, n_1, n_2)
	if isequal(cross(incidentRay, interfaceNormal), [0 ; 0 ; 0])
        refractedRay = incidentRay;
    else
        coeff = norm(cross(incidentRay, interfaceNormal))*sign(dot(incidentRay, interfaceNormal))/(tan(asin(norm(cross(incidentRay, interfaceNormal))*n_1/n_2)))-dot(incidentRay, interfaceNormal);
        refractedRay = incidentRay + coeff*interfaceNormal;
    end
    refractedRay = refractedRay/norm(refractedRay);
end
