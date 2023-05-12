clear all; 
close all;
clc;

th_fname_list{1} = 'IIR_MaxScar-repeated-voxels_prodStats.txt';
th_fname_list{2} = 'MplusSD_MaxScar-repeated-voxels_prodStats.txt';
method{1} = 'IIR';
method{2} = 'MplusSD';

X = 'both_';
which_method = 2;

th_fname = th_fname_list{which_method};
name_method = method{which_method};

p2f = 'D:\09-dnav_vs_inav\carmaf\batch_3_fixes';
sdirs = dir(p2f);
sdirs = {sdirs.name}';
sdirs([1 2]) = [];

output_dir = 'BATCH_3_OUTPUT';

st.cases = sdirs;
st.mean_bp = zeros(length(sdirs), 1, 'double');
st.std_bp = zeros(length(sdirs), 1, 'double');

error_count = 0;
for ix=1:length(sdirs)
    sweep_p = fullfile(p2f, sdirs{ix}, output_dir);
    fname = fullfile(sweep_p, th_fname);

    if exist(fname, "file")
        [mn, sd, thress, scores] = readParseProdStats(fname);
        st.mean_bp(ix) = mn;
        st.std_bp(ix) = sd;
        for jx=1:length(thress)
            st.(float2str(thress(jx)))(ix) = scores(jx);
        end
    else 
        error_count = error_count + 1;
        disp(sweep_p);
        st.mean_bp(ix) = nan;
        st.std_bp(ix) = nan;
        for jx=1:length(thress)
            st.(float2str(thress(jx)))(ix) = nan;
        end
    end
end

for jx=1:length(thress)
    st.(float2str(thress(jx))) = st.(float2str(thress(jx)))';
end


T = struct2table(st);
disp(sprintf('%sNav registration issue', X));
disp(T);

replyy = input(' save? [default = Y)', 's');
if isempty(replyy)
    replyy = 'y';
end
replyy = lower(replyy);
if replyy == 'y'
    writetable(T, fullfile(p2f, strcat(X,'Nav_scores_', name_method,'.xlsx')));
end


%% helper functions

function [mn, sd, thresholds, scores] = readParseProdStats(p2file)
fi = fopen(p2file, 'r');
fgetl(fi); % IIR_ line
mn_str=fgetl(fi); % BP mean
sd_str=fgetl(fi); % BP STDev
% line4=fgetl(fi); % MULTIPLE THRESHOLDS: (old version)

C=textscan(fi, 'V=%f, SCORE=%f');
carr = C{2};

mn = str2double(mn_str);
sd = str2double(sd_str);
thresholds = C{1};
scores = C{2};

fclose(fi);
end

function [nstr] = float2str(fl)
nstr = strcat('TH_', strrep(num2str(fl), '.', 'd'));
end
