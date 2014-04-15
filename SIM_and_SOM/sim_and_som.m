% Start of SIM code

% clear all stored data in workspace
clear all;

% read CSV file with each document including the topic and weight
data = read_mixed_csv('topicmap_papers.csv', ',');

papers = unique(data(:,1));

noTopics = 100;

% create vectors of papers for each topic.
vectors(1:noTopics, 1:size(papers)) = 0;
for i=1:1:size(data,1)
    index = strmatch(data(i,1), papers, 'exact');
    vectors(str2num(char(data(i,3)))+1, index) = str2double(data(i,2));
    
    % Some debugging output
    if (mod(i,1000) == 0)
        strcat('Processed project number ', num2str(i), ' from ', num2str(size(data,1)))
    end
end

% calculate cosine distance betwen vectors between topics
pp = pdist(vectors,'cosine');
pp_min = min(min(pp)); pp_max = max(max(pp));

% normalize (0-1)
pp = pp - pp_min;
pp = pp ./ ( pp_max - pp_min );

% change from distances to similarities and create a similarity matrix
% (squareform)
simmat = 1.0 - squareform(pp);

% save as csv file
% dlmwrite('topicmap_similarity_matrix_nor.csv',simmat,'delimiter',',');
dlmwrite(strcat('topicmap_similarity_matrix_', num2str(noTopics), '.csv'),simmat,'delimiter',',');


%remove certain topics - Maybe not used in your project.
remaining = 1:100; 
%exclude = [2 5 8 9 12 13 15 20 21 24 27 29 32 33 38 41 43 46 60 67 86 91 94 99 47];
exclude = [];
exclude = exclude +1; %index in mallet starts at 0, index at matlab starts at 1. So add 1.
for i=1:size(exclude,2)
   remaining = remaining(find(remaining ~= exclude(i))); 
end
simmat_reduced = simmat(remaining,remaining);
%dlmwrite('topicmap_similarity_matrix_small_nor.csv',simmat_reduced,'delimiter',',');
%dlmwrite('topicmap_similarity_matrix_small_nor_labels.csv',remaining-1,'delimiter',',');

% End of SIM code



% Start of SOM code

% A SCRIPT THAT GENERATES A SOM FROM OUR SIMILARITY DATA
addpath('somtoolbox')

% START TIMER
tic;

% BURN EXISTING VARIABLES AND FIGURES
% close all; 
clear all;
samples = 100;

remaining = 1:samples; 
exclude = [17 26 66 18 31 28 48 75 60 99 0 41 2 61 44 96 24 4 20 14];
exclude = exclude +1; %index in mallet starts at 0, index at matlab starts at 1. So add 1.

for i=1:size(exclude,2)
   remaining = remaining(find(remaining ~= exclude(i))); 
end

% Read Hype Values
%hype_data = dlmread('hype_data_stefano.csv', ','); %index starts at 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mapShape = [14 10]; %SET MAP SHAPE (OR NOT)%
%path = strcat(pwd, strcat('\SOM_CHI_' , num2str(samples) , '\'));
rotateMap = true;
features = false;
title = 'SOM2';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ IN THE APPROPRIATE DATA FILE
data_raw = 1 - dlmread(strcat('topicmap_similarity_matrix_', num2str(samples), '.csv'));

% NOT DOING THIS NOW AS USING INTERSECT LATER
data = data_raw(remaining,remaining);

% MAKE A LABELS MATRIX
labels = num2str(reshape(remaining,size(remaining,2),1),'%d');

% GENERATE THE SOM DATA STRUCTURE
sD = som_data_struct(data,'labels',labels);

% MAKE THE SOM
if (exist('mapShape','var') == 1)
    sM = som_make(sD, 'name', 'Colour Chart for Texture', 'training', 'long', 'lattice', 'hexa', 'msize', mapShape);
else
    sM = som_make(sD, 'name', 'Colour Chart for Texture', 'training', 'long', 'lattice', 'hexa');
end

sM = som_autolabel(sM,sD,'vote');

% SHOW THE MAP 
%som_show(sM,'comp','all','norm','d');
%som_show(sM,'umat','all','comp',1:size(data,2),'empty','Examples','norm','d');
%som_show_add('label',sM,'subplot',8);

% NOW RE AUTOLABEL

sM = som_autolabel(sM,sD);

sM.labels = sM.labels(:,2:end);

%som DISTANCES
U = som_umat(sM.codebook,sM.topol);
% Order into stacks for OUTPUT
maxMembers = size(sM.labels,2);
disp(maxMembers);

clusters = [];
for i = 1:size(sM.labels,1)
    j = 1;
    cluster = [];
    while j <= maxMembers & size(sM.labels{i,j},2) > 0
        cluster(j) = str2num(sM.labels{i,j});
        j = j + 1;
    end
    
    % FIND CENTROID, AND DISTANCES THEREFROM
    if (features)
        dimensions = data_raw(cluster(:),:); % FOR FEATURE VECTORS
    else
        %hack
        dimensions = data_raw(cluster(:),cluster(:)); % FOR SIM MATRIX
    end

    centre = mean(dimensions);

    distances = [];
    for j = 1:size(cluster,2)
        distances(j) = sum((dimensions(j,:) - centre).^2);
    end
    
    % ORDER CLUSTER BY DISTANCE FROM CENTROID AND ADD TO CLUSTERS
    [ans ordered] = sort(distances);
    cluster = cluster(ordered);
    
    % THIS LINE REMOVES THE TEXTURES FOR THE SOMR INTERFACE
    %cluster(~ismember(cluster,remaining)) = [];

    clusters{i} = cluster;
end

% RESHAPE THE RESULTS
clusters = reshape(clusters,sM.topol.msize);
if rotateMap
    clusters = clusters';
end;

filename = 'SOM.csv';
fid = fopen(filename, 'w');

%reorder when showing all items of neuron - MAX FIVE PER CLUSTER
for i = 1:size(clusters,1)
    for j = 1:size(clusters,2)
        
        if (size(clusters{i,j},2) > 1)  %if not empty neuron
            
             
            cc = size(clusters{i,j},2); %number of items in a a cluster 
            
            permutations = perms(clusters{i,j});    % calculate all posible locations
       
            distances_p(1:size(permutations,1)) = 0;    %record overall permutations distance;
            for p=1:1:size(permutations, 1)
                if(cc == 2)
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 1), [6 1 2 3]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 2), [6 5 4 3]);
                elseif(cc == 3)
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 1), [1 2 3]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 2), [1 6 6]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 3), [4 5 3]);
                elseif(cc == 4)
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 1), [6 1 2 3]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 2), [1 6 6]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 3), [2 3 4]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 4), [5 6 4 3]);
                elseif(cc == 5)
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 1), [1 2 3 4 5 6]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 2), [6 1 2]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 3), [1 2 3]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 4), [6 5 4]);
                   distances_p(p) = distances_p(p) + calculate_distance(data_raw, clusters, [i j], permutations(p, 5), [5 4 3]);
                end
            end
            
            min_p_order = find(distances_p == min(distances_p));
            
            clusters(i,j) = {permutations(min_p_order(1), :)}; %save reoredered clusters
            
            if(j==1)
                fprintf(fid, '%s', num2str(clusters{i,j}));
            else
                fprintf(fid, ',%s', num2str(clusters{i,j}));
            end
            
            clear distances_p;
        elseif(size(clusters{i,j},2) == 1)
            if (j==1)
                fprintf(fid, '%s', num2str(clusters{i,j}));
            else
                fprintf(fid, ',%s', num2str(clusters{i,j}));
            end
        else
            if (j==1)
                fprintf(fid, '%s', '[]');
            else
                fprintf(fid, ',%s', '[]');
            end
        end
    end
    fprintf(fid, '%s\n', '');
end

fclose(fid);

type SOM.csv

toc;

'done'

% End of SOM code