%tr - trainning; w - working; y - output of net;

tr_table_original = readtable('data_for_training.csv');
w_table_original_1 = readtable('data_for_work.csv');

%tr_table_original = table_bugs_29_06_100; 
%w_table_original_1 = table_bugs_29_06_100_one; %table_work_one; %table_work_one; %table_work_one; %table_work_one; %table_bugs_29_06_100_one;% data_for_test_onetickets; %

mode = "exp"; % "exp", "new" or "stable" ("stable"  - only after "new")
save_in_file = 'stat_inf.mat'; %   file - stat_inf.mat
predict_period = 512; % the duration of the predictable interval
dinamik_target_parameter = []; % dinamik target parameter - d_t_p
min_trulity_level = 0.5;
predictation = ''; % the starting settings for result
step_repeat = 5; % the quantity for the repetitions of searching
deep_of_search = 6; % quantity of the dividings of the dinamik target parameter
deep_of_check = 6; % not more than deep_of_search
loop_repeats_quant = 5; % the quantity of the repetitions during training the net 
layers_quant = 10;  % parameter for NN
c_d = 2; % the coefficient for dividing of the predict interval at passing to the next iteration, it may be 3,and more


z_t_t_o = size(tr_table_original);
z_w_t_o = size(w_table_original_1);
res_opt_new = -1;
struck.vr = {};
if mode == "stable"
    struck = load(save_in_file, 'P_opt');
elseif mode == "new"
    res_opt_new = -1;
else 
   r = randi([1 z_t_t_o(1)-min(200, z_t_t_o(1)-1)],1,1);
   r_w = randi([1 z_w_t_o(1)],1,1);
   tr_table_original = tr_table_original(r:min(r+min(200, z_t_t_o(1)-1)),:);
   w_table_original_1 = w_table_original_1(r_w,:);
   z_t_t_o = size(tr_table_original);
   z_w_t_o(1) = 1;
end
predict = '';
Result = {};          
predictation = cell(z_w_t_o(1),3);
for t = 1 : z_w_t_o(1)
    t
    w_table_original = w_table_original_1(t,:);
    [tr_duration, w_start_time] = duration_cell(tr_table_original, w_table_original);
    table = table2cell(tr_table_original);
    [index, modif_table, w_modif_table] = create_index_of_keywords(table, 60,[], w_table_original);
    [input_w] = create_data_for_work_input( w_modif_table, index);      
    list_of_valeus_by_steps = cell(1,step_repeat);
    for s = 1 : step_repeat    
        repetition_of_step = s        
        P = {{}, modif_table, predict_period, cell(1,6)}; % cell with all information
        P{10} = tr_duration;
        P{11} = w_start_time;
        [ P, y, T_r , y1, timer, V, d] = main( P, c_d, save_in_file, 5, 10, index, input_w, 5, 0, deep_of_search, mode,res_opt_new, struck );
        list_of_valeus_by_steps{1,s} = P{9};       
    end
    h_lim = 1;
    M = 0;
    for h = 1 : deep_of_check
        list_of_valeus_by_steps_1 = {};
        vr1 = list_of_valeus_by_steps;
        z_l_v_s  = size(list_of_valeus_by_steps);
        group_2 = {};
        group_3 = [];
        group_ = [];
        z_g_2 = size(group_2);          
        group_1 = [];
        for v = 1 : z_l_v_s(2)
            group_1 = [v];            
        for v1 = 1 : z_l_v_s(2)
            z_l_v_b_s_v  = size(list_of_valeus_by_steps{v});
            z_l_v_b_s_v1 = size(list_of_valeus_by_steps{v1});
            if  h < z_l_v_b_s_v(2) & h < z_l_v_b_s_v1(2) &  list_of_valeus_by_steps{v}{h} == list_of_valeus_by_steps{v1}{h}    
                group_1  = [group_1, v1];            
            end             
        end
        group_1(1) = [];
        group_2{z_g_2(2) + 1} = group_1;
        z_g_2 = size(group_2);                            
        end     
        gr2 = group_2
        z_g_2 = size(group_2);    
        for g = 1 : z_g_2(2)
            z_g_2_g = size( group_2{g});
            group_3(1,g) = z_g_2_g(2);
        end
        gr3 = group_3
        [M,I] = max( group_3);
        if M > min_trulity_level * step_repeat
            h_lim = h
            trulity_level = min([M/step_repeat, 0.97]);
        end
        group_ = group_2{I}
        z_g_ =size(group_);
        if z_g_(2) > 0
            list_of_valeus_by_steps_1 = {};
            for v = 1 :  z_g_(2)
                list_of_valeus_by_steps_1(v) =  list_of_valeus_by_steps(group_(v));
            end
            list_of_valeus_by_steps = list_of_valeus_by_steps_1;
            z_l_v_s  = size(list_of_valeus_by_steps);
        else
            break;
        end
    end
    V_res = list_of_valeus_by_steps{1}{h_lim}
    W = V_res - d;
    if h_lim <= 2
        formatOut = 'yyyy';
        result = datestr(now +  W, formatOut);
        beginning =  datestr(now +  W - 0.5^(h_lim +1) * predict_period, formatOut);
        ending = datestr(now +  W + 0.5^(h_lim +1) * predict_period, formatOut);
        %predict = ['from ', beginning, ' till ', ending];
        %C = datestr(now +  W, formatOut);
    elseif  h_lim <=  5 
        formatOut = 'mmm yyyy';
        result = datestr(now +  W, formatOut);
        beginning =  datestr(now +  W - 0.5^(h_lim +1) * predict_period, formatOut);
        ending = datestr(now +  W + 0.5^(h_lim +1) * predict_period, formatOut);
       % predict = [ beginning, ' till ', ending];
        %C{1,i} = datestr(now +  W, formatOut);
    else
        formatOut = 'dd mmm yyyy';
        result = datestr(now +  W, formatOut);            
        beginning =  datestr(now +  W - 0.5^(h_lim +1) * predict_period, formatOut);
        ending = datestr(now +  W + 0.5^(h_lim +1) * predict_period, formatOut);
       % predict = ['from ', beginning, ' till ', ending];

       % C{1,i} = datestr(now +  W, formatOut);
    end                
    Result{t} = {result, trulity_level, h_lim};
end
z_R = size(Result);
for r = 1 : z_R(2)
    z_R_r = size(Result{r});
    for c = 1 : z_R_r(2)
        predictation{r,c} = Result{r}{c};
    end
    table_predictation = cell2table(predictation, 'VariableNames',{'Date' 'Trulity_level' 'Depth_of_search'});
     writetable(table_predictation,'predictation.csv');
end
