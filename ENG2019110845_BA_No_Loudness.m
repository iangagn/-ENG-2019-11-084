
% Run parameters
nb_runs = 1000;

% Objective funtions
% fun = {@sphere, @rosenbrock, @linear_step, @noisy_quartic, @foxholes};
fun = {@foxholes};

% Domain limits
lb = [-5.12, -5.12, -5.12, -1.28, -65.536];
lb = [-65.536];
ub = abs(lb);

% Global minima
min_values = [0, 0, 0, 0, 0.998];
min_values = [0.998];

% Initialization
nb_functions = numel(fun);
for i = 1 : nb_functions
   results_ba_1.(func2str(fun{i})).fht = nan(nb_runs,1);
   results_ba_2.(func2str(fun{i})).fht = nan(nb_runs,1);
end

%% Run

% Parameter set generating function
fparams1 = @(lb, ub, f, minval) struct('fun',                  f,      ...
                                       'nb_dim',               2,      ...
                                       'initial_positions',    [],     ...
                                       'lower_bound',          lb,     ...
                                       'upper_bound',          ub,     ...
                                       'fmin',                 0,      ...
                                       'fmax',                 2,      ...
                                       'r0',                   0.7,    ...
                                       'a',                    0.9,    ...
                                       'g',                    0.1,    ...
                                       'loudness',             1,      ...
                                       'epsilon',              1e-3,   ...
                                       'nb_bats',              20,     ...
                                       'max_iter',             5000,   ...
                                       'known_best_fitness',   minval, ...
                                       'tol',                  1e-2,   ...
                                       'positions_hist_flag',  false);           

fparams2 = @(lb, ub, f, minval) struct( 'fun',                 f,      ...
                                       'nb_dim',               2,      ...
                                       'initial_positions',    [],     ...
                                       'lower_bound',          lb,     ...
                                       'upper_bound',          ub,     ...
                                       'fmin',                 0,      ...
                                       'fmax',                 2,      ...
                                       'r0',                   0.7,    ...
                                       'a',                    0.9,    ...
                                       'g',                    0.1,    ...
                                       'loudness',             1,      ...
                                       'epsilon',              1e-3,   ...
                                       'nb_bats',              20,     ...
                                       'max_iter',             5000,   ...
                                       'known_best_fitness',   minval, ...
                                       'tol',                  1e-2,   ...
                                       'positions_hist_flag',  false);  
                                   
count = 0;
nb_total_runs = nb_functions * nb_runs;
for i = 1 : nb_functions
    for j = 1 : nb_runs
        results_ba_1.(func2str(fun{i})).fht(j) = bat(fparams1(lb(i), ub(i), fun{i}, min_values(i)));
        results_ba_2.(func2str(fun{i})).fht(j) = bat_no_loudness(fparams2(lb(i), ub(i), fun{i}, min_values(i)));
        count = count + 1;
        if mod(count, 1) == 0
            disp(['Completed : ' num2str(count/nb_total_runs*100) ' %'])
        end
    end
end

%% Compare distributions

function_name = 'sphere';

boxplot([results_ba_1.(function_name).fht, results_ba_2.(function_name).fht], {'BA1', 'BA2'});
set(gca, 'color', [253,245,230]/255, 'fontname', 'times', 'fontsize', 14)

text_handles = findall(gca, 'type', 'text');
for i = 1 : numel(text_handles)
   temp = get(text_handles(i)); 
   if strcmpi(temp.String, 'BA') || strcmpi(temp.String, 'Simplified BA')
       position = get(text_handles(i), 'position');
       position(2) = position(2) - 10;
       set(text_handles(i), 'fontname', 'times', 'fontsize', 12, 'position', position)
   end
end

disp(['BA1 = ', num2str(sum(isnan(results_ba_1.(function_name).fht)))]); 
disp(['BA2 = ', num2str(sum(isnan(results_ba_2.(function_name).fht)))]); 

nanmedian(results_ba_1.(function_name).fht)
nanmedian(results_ba_2.(function_name).fht)

%% Test

ba1 = results_ba_1.(function_name).fht(~isnan(results_ba_1.(function_name).fht));
ba2 = results_ba_2.(function_name).fht(~isnan(results_ba_2.(function_name).fht));

[h, p] = kstest2(ba1, ba2);

