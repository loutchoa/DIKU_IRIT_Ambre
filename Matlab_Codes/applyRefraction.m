%% Get the direction of the refracted vector based on the Snell-Decartes law

%% Input : 
%%    - incidentRay : direction of the incident ray
%%    - diopterNormal : normal vector of the diopter at the impact point
%%    - n_1, n_2, indexes of refraction of the both medium
%% Output : 
%%    - refractedRay : direction of the refracted ray

function refractedRay = applyRefraction(incidentRay, diopterNormal, n_1, n_2)
	if isequal(cross(incidentRay, diopterNormal), [0 ; 0 ; 0])
        refractedRay = incidentRay;
    else
        coeff = norm(cross(incidentRay, diopterNormal))*sign(dot(incidentRay, diopterNormal))/(tan(asin(norm(cross(incidentRay, diopterNormal))*n_1/n_2)))-dot(incidentRay, diopterNormal);
        refractedRay = incidentRay + coeff*diopterNormal;
    end
    refractedRay = refractedRay/norm(refractedRay);
end
