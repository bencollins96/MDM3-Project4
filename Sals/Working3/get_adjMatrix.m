function [adjMatrix] = get_adjMatrix(numSource,numTarget,numChrg)
    n1 = numSource+numTarget+numChrg;
    n2 = numSource;
    graph1 = ones(n1,n1);
    diagonal = diag(ones(1,n1));
    adjMatrix = graph1 -diagonal;
    graph2sub = ones(n2,n2) - diag(ones(1,n2));
    graph2 = zeros(n1,n1);
    graph2(1:n2,1:n2)  = graph2sub;
    adjMatrix = adjMatrix - graph2;
    adjMatrix(n2 +1:n2+numTarget,:) =0; %No target -> elsewhere
    adjMatrix(n2 + 1: n2 + numTarget,n2 + 1: n2 + numTarget) = 0; %No target to target
    adjMatrix(n2+1:n2+ numTarget + numChrg,1:n2) = 0;
end


