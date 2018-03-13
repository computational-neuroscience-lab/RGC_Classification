function Contour = GetContour(xc,yc,map,Gmag,NbDivAngle,MeanRprior,StdPrior,MaxR,PriorWeight,DevTol)

PossibleAngles = 2*3.14*linspace(0,1,NbDivAngle+1);
PossibleAngles = PossibleAngles(1:end-1);

Xcoor = ones(size(map,1),1)*(1:size(map,2));
Ycoor = (1:size(map,1))'*ones(1,size(map,2));


for iangle=1:NbDivAngle
    r = (0:MaxR);
    xr = xc + r*cos(PossibleAngles(iangle));
    yr = yc + r*sin(PossibleAngles(iangle));
    xr = round(xr);
    yr = round(yr);
    for ir=1:length(r)
        if yr(ir)>0 & yr(ir)<size(Gmag,1) & xr(ir)>0 & xr(ir)<size(Gmag,2)
            score(ir) = Gmag(yr(ir),xr(ir));%*abs(cos(pi*handles.Gangle(yr(ir),xr(ir))/180-(PossibleAngles(iangle)-pi)));
        else
            score(ir) = 0;
        end
    end
    score = score - PriorWeight*((r-MeanRprior)/StdPrior).^2;
    [m,GoodR] = max(score);

    ChosenRadius(iangle) = GoodR;

    Contour(iangle,1) = xr(GoodR);
    Contour(iangle,2) = yr(GoodR);
end
%     clear cr

cr(2:length(ChosenRadius)+1) = ChosenRadius;
cr(1) = ChosenRadius(end);
cr(end+1) = ChosenRadius(1);

d = cr(2:end-1) - (cr(1:end-2) + cr(3:end))/2;
d = d - mean(d);
d = d / std(d);
Dev = find(abs(d)>DevTol);

Contour(Dev,:) = [];
