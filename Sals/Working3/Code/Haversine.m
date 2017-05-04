function distance = Haversine(X1,X2)
    R = 6371e3;
    % All in format [lat,long]?
    phi1 = deg2rad(X1(1));
    lambda1 = deg2rad(X1(2));
    
    distance = [];
    for i =1:size(X2,1)
        
        phi2 = deg2rad(X2(i,1));
        lambda2 = deg2rad(X2(i,2));
        a = sin((phi2-phi1)/2)^2 + cos(phi1)*cos(phi2)*sin((lambda2 - lambda1)/2)^2;
        c = 2*atan2(sqrt(a),sqrt(1-a));
        distance = [distance;R*c];
    end

end