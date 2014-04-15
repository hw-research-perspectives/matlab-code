function distance = calculate_distance(distances, clusters, location, topic1, orientations)
% orientations
% 
%      1    2
%   6   loc   3
%      5    4
%

distance = 0;
count = 1;

for o=1:1:size(orientations,2)
    oo = orientations(o);
    
    for i=1:1:size(clusters{location(1), location(2)},2)
       
      try
            if( oo == 1)
                topic2 = clusters{location(1)-1, location(2)}(i);
            elseif (oo == 2)
                topic2 = clusters{location(1)-1, location(2)+1}(i);
            elseif (oo == 3)
                topic2 = clusters{location(1), location(2)+1}(i);
            elseif (oo == 4)
                topic2 = clusters{location(1)+1, location(2)+1}(i);
            elseif (oo == 5)
                topic2 = clusters{location(1)+1, location(2)}(i);
            elseif (oo == 6)
                topic2 = clusters{location(1), location(2)-1}(i);
            end

            
            distance = distance + distances(topic1, topic2);
            count = count + 1;
       catch
            distance = distance + 0;
       end
        
        
        
    end
    
end


distance = distance ./ count;   