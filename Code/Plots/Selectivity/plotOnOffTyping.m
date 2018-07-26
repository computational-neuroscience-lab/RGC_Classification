function plotOnOffTyping(expID, idCell)
figure('Name', strcat('Cell #', int2str(idCell),' from experiment_', expID));
subplot(2,1,1)
plotOnOffTypingEuler(expID, idCell)
subplot(2,1,2)
plotOnOffTypingBars(expID, idCell)

% set figure position and scaling
ss = get(0,'screensize');
width = ss(3);
height = ss(4);

vert = 800;
horz = 1600;

set(gcf,'Position',[(width/2)-horz/2, (height/2)-vert/2, horz, vert]);

