%% Script -- transform prodCutter[]TNormals.txt
% Select transformation file
clc

% DIR='/media/jsl19/sandisk/09-dnav_vs_inav/umc';
DIR='/Volumes/sandisk/09-dnav_vs_inav/umc';
subdirs={'local', 'docker'};
N=1:26;
X={'d', 'i'};

%mirtk_dir='~/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib';
mirtk_dir='~/dev/libraries/MLib'

mycommand = fullfile(mirtk_dir, 'info');
for sd=1:length(subdirs)
    for n=1:length(N)
        for x=1:length(X)
            p2dof = fullfile(DIR, subdirs{sd}, num2str(N(n)), sprintf('LGE_%sNAV', X{x}));
            if (isfolder(p2dof))
                disp(p2dof);
                dof = sprintf('mra2%snav.dof', X{x});
                myargs = fullfile(p2dof, dof);

                [~, res] = system([mycommand 32 myargs]);
                l = strsplit(res);

                T = [str2double(l{3}) str2double(l{6}) str2double(l{9})];
                R = [str2double(l{12}) str2double(l{15}) str2double(l{18})];
                Rdeg = rad2deg(R);

                Rot = rotx(R(1))*roty(R(2))*rotz(R(3));
                RotDeg = rotx(Rdeg(1))*roty(Rdeg(2))*rotz(Rdeg(3));

                clear myargs res l
                %% Select prodCutter
                p2f = fullfile(DIR, subdirs{sd}, num2str(N(n)), 'MRA');
                list = dir(p2f);
                fnames = {list.name};
                fnames(~contains(fnames, 'TNormal')) = [];

                for ix=1:length(fnames)
                    fx = fopen(fullfile(p2f, fnames{ix}), 'r');
                    nx = zeros(3,1);
                    for jx=1:3
                        nx(jx) = str2double(fgetl(fx));
                    end
                    nx_mag = norm(nx);
                    nx = nx./nx_mag;
                    fclose(fx);

                    fo = fopen(fullfile(p2dof, ['' fnames{ix}]), 'w');
                    nrx = Rot*nx;
                    fprintf(fo, '%f\n%f\n%f\n0', nrx.*nx_mag);
                    fclose(fo);

                    %fod = fopen(fullfile(p2dof, ['deg_out_' fnames{ix}]), 'w');
                    %nrdx = RotDeg*nx;
                    %fprintf(fod, '%f\n%f\n%f\n0', nrdx.*nx_mag);
                    %fclose(fod);

                end
            end
        end
    end
end


disp('Finished');