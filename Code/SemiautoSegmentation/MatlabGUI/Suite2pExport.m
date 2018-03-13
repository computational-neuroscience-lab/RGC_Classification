%% Visualize one ROI

function varargout = Suite2pExport(varargin)

    [filepath, name, ext] = fileparts(varargin{1});

    load(varargin{1});

    for id_cell = 1:length(stat)

        mask = zeros([ops.Lx ops.Ly]);

        for ipix=1:length(stat(id_cell).xpix)
            mask(ops.yrange(stat(id_cell).ypix(ipix)),ops.xrange(stat(id_cell).xpix(ipix))) = stat(id_cell).lambda(ipix);
        end

        mask = mask / max(mask(:));

        masknorm = mask;

        masknorm(:) = double(mask(:) > 0);

        [B,L] = bwboundaries(masknorm,'noholes');

%         MeanRadius = sqrt(length(find(masknorm(:)>0))/pi );
%         cont = GetContour(ops.yrange(round(stat(id_cell).med(1))),ops.xrange(round(stat(id_cell).med(2))),masknorm,imgradient(masknorm),40,MeanRadius,MeanRadius,4*MeanRadius,0.5,3);
% % 
% %         contmask = imgradient(masknorm,'CentralDifference');
% % 
% %         xcoor = (1:size(contmask,1))'*ones(1,size(contmask,2));
% %         ycoor = ones(size(contmask,1),1)*(1:size(contmask,2));
% % 
% %         xcont = xcoor(find(contmask(:)>0));
% %         ycont = ycoor(find(contmask(:)>0));
% % 
% %         xcont = xcont - ops.yrange(round(stat(id_cell).med(1)));
% %         ycont = ycont - ops.xrange(round(stat(id_cell).med(2)));
% % 
% %         thetacont = angle(xcont + i*ycont);
% % 
% %         [a,id_cont] = sort(thetacont,'ascend');
% %         xcont = xcont(id_cont) + ops.yrange(round(stat(id_cell).med(1)));
% %         ycont = ycont(id_cont) + ops.xrange(round(stat(id_cell).med(2)));

        %Scan contour

    %         mask(ops.yrange(round(stat(id_cell).med(1))) , ops.xrange(round(stat(id_cell).med(2)))) = 1;

        %figure;
        %imshow(map/max(map(:)))
    %         imshow(contmask)
        %title(int2str(id_cell))
        %hold on
        %plot( ops.xrange(round(stat(id_cell).med(2))),ops.yrange(round(stat(id_cell).med(1))),'r.')
        %plot(ycont(1:SmoothStep:end),xcont(1:SmoothStep:end),'r')

        Centers(id_cell,1) = ops.xrange(round(stat(id_cell).med(2)));
        Centers(id_cell,2) = ops.yrange(round(stat(id_cell).med(1)));

        Contour{id_cell}(:,1) = B{1}(:,2);%cont(:,2);%ycont(1:SmoothStep:end);
        Contour{id_cell}(:,2) = B{1}(:,1);%cont(:,1);%xcont(1:SmoothStep:end);

        MapId(:,:,id_cell) = mask;
    end

    save([filepath '/block_roi.mat'],'Centers','Contour','MapId','-mat')
