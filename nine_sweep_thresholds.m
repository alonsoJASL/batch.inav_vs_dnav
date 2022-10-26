%% Place all results in the same table (stats)
clc

%% Process results from table

% DIR='/Volumes/sandisk/09-dnav_vs_inav/umc';
DIR = '/media/jsl19/sandisk/09-dnav_vs_inav/umc';
subdirs={'local', 'docker'};
N=sort([10 11 12 13 14 15 16 17 18 19 2  20 21 22 23 24 25 26 5  6  7  8  9]);

sd=1; % choose local

resfolder= fullfile(DIR, ['results_' subdirs{sd}]);
T=readtable(fullfile(resfolder,'stats.csv'));

exp_struc(1).odir_sub='SWEEP';
exp_struc(1).thres_vect=(0.7:0.01:1.59)';
exp_struc(2).odir_sub='AVG_MEDIAN';
exp_struc(2).thres_vect=[1.13; 1.1504];
exp_struc(3).odir_sub='OPTIM_THRES';
exp_struc(3).thres_vect=(1.05:0.0001:1.2901)';

exp_number = 3;

odir_sub = exp_struc(exp_number).odir_sub;
thres_vect = exp_struc(exp_number).thres_vect;
tot_test_vals = length(thres_vect);

sweep_scores = zeros(tot_test_vals, length(N));

mean_bp_vect = zeros(length(N), 1);
sdev_bp_vect = zeros(length(N), 1);
for n=1:length(N)
    output_dir = strcat('OUTPUT_', odir_sub);
    sweep_folder=fullfile(DIR, subdirs{sd}, num2str(N(n)), 'LGE_iNAV', output_dir);
    sweep_file=fullfile(sweep_folder, 'IIR_MaxScar-single-voxel_prodStats.txt');

    [~, sweep_scores(:,n), mean_bp_vect(n), sdev_bp_vect(n)] = getSweepResults(sweep_file);

end

Td = T(contains(T.LGE_TYPE, 'dNAV'), :);
Ti = T(contains(T.LGE_TYPE, 'iNAV'), :);

%%
switch exp_number
    case 1 % minimise errors individually
        repmat_fibscore_d = repmat(Td.FIB_SCORE', size(sweep_scores, 1), 1);
        [minerrors, minidx] = min(abs(sweep_scores-repmat_fibscore_d));
        closest_inav_thres = thres_vect(minidx);
        scores_closest_thres = zeros(size(closest_inav_thres));
        for ix=1:length(scores_closest_thres)
            scores_closest_thres(ix) = sweep_scores(minidx(ix), ix);
        end

        mean_c_inav_threshold = mean(closest_inav_thres);
        median_c_inav_threshold = median(closest_inav_thres);
    case 2 % try mean and median of exp=1 output
        scores_w_mean_thres_1d504 = sweep_scores(1,:)';
        scores_w_median_thres_1d13 = sweep_scores(2,:)';

        errors_mean_thres = abs(scores_w_mean_thres_1d504-Td.FIB_SCORE);
        errors_median_thres = abs(scores_w_median_thres_1d13-Td.FIB_SCORE);

    case 3 % optimise threshold randomly
        close all

        num_attempts=10000;
        RESULT = zeros(num_attempts, 5);

        scale=100;
        dnav_scores = Td.FIB_SCORE'./scale;
        repmat_fibscore_d = repmat(dnav_scores, size(sweep_scores, 1), 1);
        srch_sqrt_err = (sweep_scores./scale-repmat_fibscore_d).^2;

        for attempt=1:num_attempts
            lenN = length(N);
            num_picks = 18;
            num_test = lenN - num_picks;
            perm_indx = randperm(lenN, num_picks);
            test_indx = find(~ismember(N,N(perm_indx)));

            cases_picked = N(perm_indx);
            cases_test = N(test_indx);

            train_sqrt_err = srch_sqrt_err(:,perm_indx);
            avg_srch_sqrt_err = sum(train_sqrt_err,2)./num_picks;
            [~, optim_thres_idx] = min(avg_srch_sqrt_err);

            picked_threshold = thres_vect(optim_thres_idx);
            train_sqrt_err_picked = train_sqrt_err(optim_thres_idx, :);
            test_sqrt_err_picked = srch_sqrt_err(optim_thres_idx,test_indx);

            RESULT(attempt, :) = [picked_threshold ...
                mean(train_sqrt_err_picked) ...
                std(train_sqrt_err_picked) ...
                mean(test_sqrt_err_picked) ...
                std(test_sqrt_err_picked)];
        end
        disp('finished');

        [a,b] = min(sum(RESULT(:,[2 4]),2));
        fprintf('Score is: %f\n', RESULT(b,1));

        boxplot(RESULT(:,2), RESULT(:,1));


end

%% Collect data


%% FIGURES
figure(1)
subplot(212)
hold on
for ix=1:length(Td.CASE)
    plot([Td.CASE(ix) Td.CASE(ix)], [Td.FIB_SCORE(ix) Ti.FIB_SCORE(ix)], 'k:')
end
plot(Td.CASE, Td.FIB_SCORE, 'ob', Ti.CASE, Ti.FIB_SCORE, 'dr')
xticks(Td.CASE)
grid on
title('FIBROSIS scores significantly different (p=0.011)', 'FontSize', 20)

subplot(211)
errorbar(Td.CASE, Td.MEAN_BP, Td.SDEV_BP, 'ob')
hold on
errorbar(Ti.CASE, Ti.MEAN_BP, Ti.SDEV_BP, 'dr')
xticks(Td.CASE)
grid on
legend('dNAV', 'iNAV')
title('MEAN Bloodpool not significantly different (p=0.347)', 'FontSize', 20)

figure(2)
subplot(121)
boxplot(T.MEAN_BP, T.LGE_TYPE, 'Whisker', 1.2)
title('MEAN Bloodpool not significantly different (p=0.347)', 'FontSize', 15)
subplot(122)
boxplot(T.FIB_SCORE, T.LGE_TYPE, 'Whisker', 1.2)
title('FIBROSIS scores significantly different (p=0.011)', 'FontSize', 15)

figure(3)
scatter(Td.CASE, closest_inav_thres)
ylim([0.97 1.61])
xticks(Td.CASE)
grid on
plotHorzLine([2 26], [1.2 mean(closest_inav_thres) median(closest_inav_thres)])
legend({'closest_inav', 'dnav=1.2', 'mean', 'median'})
title('closest inav thresholds per case', 'FontSize', 20)

figure(4)
plot(Td.CASE, Td.FIB_SCORE, 'ob', Ti.CASE, scores_closest_thres, 'dr');
hold on
stem(Td.CASE, minerrors, 'k.');
legend({'dnav', 'closest_inav', 'error'})
title('Fibrosis score comparison with closest inav', 'FontSize', 20)
hold off

%%
function [thres_vect, scores_vect, m_bp, sd_bp] = getSweepResults(sweep_file)
fi=fopen(sweep_file, 'r');

line1=fgetl(fi); % IIR_ line
m_bp_str=fgetl(fi); % BP mean
sd_bp_str=fgetl(fi); % BP STDev
% line4=fgetl(fi); % MULTIPLE THRESHOLDS: (old version)

C=textscan(fi, 'V=%f, SCORE=%f');

fclose(fi);

m_bp = str2double(m_bp_str);
sd_bp = str2double(sd_bp_str);

thres_vect = C{1};
scores_vect = C{2};

end