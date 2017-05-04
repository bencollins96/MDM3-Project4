function y = multiOptim(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind)

% Initialize for two objectives 
y = zeros(3,1);


y(1) = eaOptim(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind);
y(2) = eaOptim2(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind);
y(3) = eaOptim3(x,sourceCoordinates,targetCoordinates,adjMatrix,impossible,xind,yind);
end