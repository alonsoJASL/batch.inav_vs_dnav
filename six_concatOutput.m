%% Place all results in the same table (stats) 
clc

% DIR='/media/jsl19/sandisk/09-dnav_vs_inav/umc';
DIR='/Volumes/sandisk/09-dnav_vs_inav/umc';
%subdirs={'local', 'docker'};
subdirs = {'local'};
N=1:26;
X={'d', 'i'};

prod='prodThresholds.txt';
for sd=1:length(subdirs)
    outfolder = fullfile(DIR, ['results_' subdirs{sd}]);
    if(~isdir(outfolder))
        mkdir(outfolder)
    end 
    fo=fopen(fullfile(outfolder, 'stats.csv'), 'w');
    fprintf(fo, 'CASE, LGE_TYPE, MEAN_BP, SDEV_BP, FIB_SCORE \n');
    for n=1:length(N)
        for x=1:length(X)
            prodThresDir = fullfile(DIR, subdirs{sd}, num2str(N(n)), sprintf('LGE_%sNAV', X{x}), 'OUTPUT');
            if (isfolder(prodThresDir))
                fname=fullfile(prodThresDir, prod);
                disp(fname);
                fi=fopen(fname, 'r');
                CR=textscan(fi, '%s');
                C=CR{1};
                fclose(fi);

                p = N(n); % patient 
                type = X{x}; % 
                m = C{3};
                sdev = C{4};
                score = C{7}; 

                fprintf(fo, '%d, %sNAV, %s, %s, %s \n', p, type, m, sdev, score);
            end
        end
    end
    fclose(fo);
end

%% Process results from table 
DIR='/Volumes/sandisk/09-dnav_vs_inav/umc';
subdirs={'local', 'docker'};

sd=1;
resfolder= fullfile(DIR, ['results_' subdirs{sd}]);
T=readtable(fullfile(resfolder,'stats.csv'));

Td = T(contains(T.LGE_TYPE, 'dNAV'), :);
Ti = T(contains(T.LGE_TYPE, 'iNAV'), :);

[Hm,Pm,CIm] = ttest2(Td.MEAN_BP, Ti.MEAN_BP);
[Hf,Pf,CIf] = ttest2(Td.FIB_SCORE, Ti.FIB_SCORE);

figure(1)
errorbar(Td.CASE, Td.MEAN_BP, Td.SDEV_BP)
hold on
errorbar(Ti.CASE, Ti.MEAN_BP, Ti.SDEV_BP)
hold off
grid on
title('Mean +/- SDEV : ttest cannot reject (p=0.347)')

figure(2)
plot(Td.CASE, Td.FIB_SCORE, 'o-', Ti.CASE, Ti.FIB_SCORE, 'd-')
title('Fibrosis score : ttest rejects (p=0.011) ')