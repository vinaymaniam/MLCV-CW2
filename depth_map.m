function map = depth_map(dispMap,f,b)      
    sz = size(dispMap);
    szCCD = 0.236;
    map = zeros(sz);
    for y = 1:sz(1)
        for x = 1:sz(2)   
            p = (x-sz(2)/2)/(sz(2)*szCCD);
            q = (x-dispMap(y,x)-sz(2)/2)/(sz(2)*szCCD);
            if q == 0
                continue
            end
            m1 = f/p;
            m2 = f/q;
            if p == 0
                map(y,x) = m2*b;
                continue
            end
            if p-q ~= 0
                map(y,x) = (f*b)/(p-q); 
            end            
        end
    end
    % Clip outlying results
    map(map>1) = 1;
    map(map<0) = 0;
%     map = 1-map;
end