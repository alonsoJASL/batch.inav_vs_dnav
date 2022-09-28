clc

% DIR='/media/jsl19/sandisk/09-dnav_vs_inav/umc';
DIR='/Volumes/sandisk/09-dnav_vs_inav/umc';
subdirs={'local', 'docker'};
N=1:26;
X={'d', 'i'};

prod='prodThresholds.txt';
for sd=1:length(subdirs)
    outfolder = fullfile(DIR, subdirs{sd});
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
