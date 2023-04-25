clear all; 
close all;
clc;

th_fname_list{1} = 'IIR_MaxScar-repeated-voxels_prodStats.txt';
th_fname_list{2} = 'MplusSD_MaxScar-repeated-voxels_prodStats.txt';
method{1} = 'IIR';
method{2} = 'MplusSD';

X = 'd';
which_method = 2;

th_fname = th_fname_list{which_method};
name_method = method{which_method};

p2f = '/media/jsl19/sandisk/09-dnav_vs_inav/carmaf/carmaf_cemrg/';
% p2f = uigetdir('/media/jsl19/sandisk/', 'Select the main folder');
fi = fopen(fullfile(p2f, ['folders_' X 'nav.txt']), 'r');

C =  textscan(fi, '%s\n');
cases = C{1};
output_dir = 'OUTPUT_SWEEP';

st.cases = cases;
st.mean_bp = zeros(length(cases), 1, 'double');
st.std_bp = zeros(length(cases), 1, 'double');

error_count = 0;
for ix=1:length(cases)
    sweep_p = fullfile(p2f, cases{ix}, output_dir);
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
cemrg_info(sprintf('%sNav registration issue', X));
disp(T);

writetable(T, fullfile(p2f, strcat(X,'Nav_scores_', name_method,'.xlsx')));


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
