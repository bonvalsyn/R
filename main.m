function [ P, y, T_r , y1, timer, V,d]  = main( P, c_d, save_in_file, loop_repeats_quant, layers_quant,index, input_w, low_limit_for_trainning, timer, deep_of_search, mode, res_opt_new,struck)
    timer = timer + 1
    T = P{2};   
     z_i_w = size(input_w);
     for w = 1 : z_i_w(2)
        
        si = 1/2;         
        if ~isempty(P{1})
            z_P_i = size(P{1});
           % if z_P_i(2) > 0
                for k = 1 : z_P_i(2)
                    if isfloat(P{1}{w,k}) && ~isempty(P{1}{w,k})                       
                    si = si + (1/c_d)^(k+1) * (-1)^P{1}{w,k};
                    end
                end    
           % end
        end
    end
        si = si * P{3};    
    z_t = size(T);
    target = zeros(c_d,z_t(1));    
    index1 = cell(1);
    for j = 1 : z_t(2)
        index1 = [index1, index{1,j}(1,:)];
    end
    z_i = size(index1);
    input = zeros(z_i(2)-1,1);
    %v1 = ones(1,c_d);
   % n_tr_d = zeros(1,c_d);
    for i = 1 : z_t(1)
         input_col = [];         
        for j = 1 : z_t(2)
            z = size(index{1,j});      
            input_j = zeros(z(2),1);
            for k = 1 : z(2)                                
                if strcmp(index{1,j}{1,k}, T{i,j})
                    input_j(k,1) = 1; 
                    break
                end
            end
           input_col = [input_col; input_j];           
        end   
        input = [input, input_col];
        % t = P{10}{1,i}       
        if P{10}{1,i} <  si
            %fl_ind = 1;
            for u = 1 : c_d-1               
               % c_d > 1 ???
                   % n_tr_d(u) = n_tr_d(u) + 1;
                    target(u,i) = 1;                              
                    P{4}{u}{2} = P{2};                   
                    P{4}{u}{3} = P{3};
                    P{4}{u}{4} = cell(1,c_d);
                    P{4}{u}{10} = P{10};
                    P{4}{u}{11} = P{11};
                   % v1(u) = v1(u) + 1;                
            end
        else
            %fl_ind = 2;
           % n_tr_d(c_d) = n_tr_d(c_d) + 1;
            target(c_d,i) = 1;
            P{4}{c_d}{2} = P{2};
            P{4}{c_d}{3} = P{3};
            P{4}{c_d}{4} = cell(1,c_d);
            P{4}{c_d}{10} = P{10};
            P{4}{c_d}{11} = P{11}; 
           % v1(c_d) = v1(c_d) + 1;
        end
    end
    input(:,1) = [];
    z_i = size(input);
    for i = 1 : z_i(2)
        group = [i];        
        for j = i : z_i(2)            
            v = input(:,i) == input(:,j);
            if sum(v) == z_i(1) && i ~= j
                P{10}{i} = P{10}{i} + P{10}{j};
                group = [group, j];
            end
        end
        z_g = size(group);
        if z_g(2) > 1
            P{10}{group(1)}  =  P{10}{group(1)}/ z_g(2);        
            for m = 0 : z_g(2) - 1
                input(:,group(z_g(2) - m)) = [];
                target(:,group(z_g(2) - m)) = [];
                P{10}(:,group(z_g(2) - m)) = [];
            end
        end
        z_i = size(input);
    end
    z_i_5 = size(input);
    target = target(:, 1: z_i_5(2));    
    P{5} = input;
    P{6} = target;    
    [P, work_net, res, mi,list_res, q, q_sum ,y1] = create_work_patternnet(P, input, target, loop_repeats_quant, layers_quant); 
    if timer ==1
        if mode == "stable"
            P_opt = struck.P_opt;
            if P{8} > P_opt{8}
                P_opt = P;
                save(save_in_file, 'P_opt');
            else
                P = struck.P_opt;
            end
        elseif mode == "new"
            if P{8} > res_opt_new
                res_opt_new = P{8};
                P_opt = P;
                save(save_in_file, 'P_opt');
            end
        else
            
        end
    end
    [P, y, T_r, ind_t, V,W,d] =  run_patternnet(P, input_w, c_d, deep_of_search, timer);    
   V        
    P{9}(1,timer) = {V};
    [~,ind_t] = max(y);    
        P1 = P{4}{ind_t};
        z_P1 = size(P1{2});
        %z_P_1 = size(P{1})
        
        if  P{3}/c_d^timer >= 1 && timer < deep_of_search
            P1{1} = P{1};
             P1{9} = P{9};
            P = P1;
            [P ,y, timer, V] = main( P, 2,'res_inf_N',  loop_repeats_quant, layers_quant, index, input_w, low_limit_for_trainning, timer, deep_of_search, mode, res_opt_new, struck);
        else
           % P_res = P;
            %writetable(T_r, 'result.csv');
           % P{8} = T_r;
        end
end 
       
        
   
  




