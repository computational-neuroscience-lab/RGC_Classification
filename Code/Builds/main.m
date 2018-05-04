function main()
% For each experiment

experimentsPath = strcat(projectPath(), '/Experiments/');
experiments = dir(experimentsPath);

fprintf('Traces will be generated for %d experiments\n\n', length(experiments) - 2);
for i = 3 : length(experiments) % exclude current(1) and parent (2) directories
    buildData_to_h5(experiments(i).name);
end

fprintf('\n\n\nOperation Completed\n\n');
displayDataInfos;


