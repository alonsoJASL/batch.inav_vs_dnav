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

sweep_scores = zeros(91, length(N)); % 91 data points 0.7:0.01:1.6
thres_vect = (0.7:0.01:1.6)';
mean_bp_vect = zeros(length(N), 1);
sdev_bp_vect = zeros(length(N), 1);
for n=1:length(N)
    sweep_folder=fullfile(DIR, subdirs{sd}, num2str(N(n)), 'LGE_iNAV', 'OUTPUT_SWEEP');
    sweep_file=fullfile(sweep_folder, 'IIR_MaxScar-single-voxel_prodStats.txt');
    
    [~, sweep_scores(:,n), mean_bp_vect(n), sdev_bp_vect(n)] = getSweepResults(sweep_file);
    
end

Td = T(contains(T.LGE_TYPE, 'dNAV'), :);
Ti = T(contains(T.LGE_TYPE, 'iNAV'), :);



repmat_fibscore_d = repmat(Td.FIB_SCORE', size(sweep_scores, 1), 1);
[minvals, minidx] = min(abs(sweep_scores-repmat_fibscore_d));
closest_inav_thres = thres_vect(minidx);

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

figure(3)
subplot(121)
boxplot(T.MEAN_BP, T.LGE_TYPE, 'Whisker', 1.2)
title('MEAN Bloodpool not significantly different (p=0.347)', 'FontSize', 15)
subplot(122)
boxplot(T.FIB_SCORE, T.LGE_TYPE, 'Whisker', 1.2)
title('FIBROSIS scores significantly different (p=0.011)', 'FontSize', 15)


%% 
function [thres_vect, scores_vect, m_bp, sd_bp] = getSweepResults(sweep_file)
fi=fopen(sweep_file, 'r');

line1=fgetl(fi);
m_bp_str=fgetl(fi);
sd_bp_str=fgetl(fi);
line4=fgetl(fi);

C=textscan(fi, 'V=%f, SCORE=%f');

fclose(fi);

m_bp = str2double(m_bp_str);
sd_bp = str2double(sd_bp_str);

thres_vect = C{1};
scores_vect = C{2};

end