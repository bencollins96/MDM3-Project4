%Haversine formula

function dist_mat = dist_matrix(lat,lng)

    dist_mat = zeros(length(lat));
    dist_mat(:) = inf;
    
    for n=1:length(lat)
        for m =1:length(lng)
            dist_mat(n,m) = Haversine(lat(n),lat(m),lng(n),lng(m));
        end
    end    
end


function distance = Haversine(phi1,phi2,lambda1,lambda2)

    R = 6371e3;
    
    phi1 = deg2rad(phi1);
    phi2 = deg2rad(phi2);
    lambda1 = deg2rad(lambda1);
    lambda2 = deg2rad(lambda2);

    a = sin((phi2-phi1)/2)^2 + cos(phi1)*cos(phi2)*sin((lambda2 - lambda1)/2)^2;
    c = 2*atan2(sqrt(a),sqrt(1-a));
    distance = R*c;
    
    
end
