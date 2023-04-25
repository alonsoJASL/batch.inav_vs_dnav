import argparse
import os 
import platform 
import numpy as np

def chooseplatform() :
    """Return the platform name"""
    return platform.system().lower() 
def fullfile(*args) :
    """Return the full path to a file"""
    return os.path.join(*args)
def log_to_file(log_file, log_str, log_status='INFO') :
    """Write a string to a file"""
    with open(log_file, 'a') as f:
        f.write('[' + log_status + '] ' + log_str + '\n')

def run_cmd(script_dir, cmd_name, arguments, debug = False ) :
    """ Return the command to execute""" 
    cmd = fullfile(script_dir, cmd_name) + ' '
    cmd += ' '.join(arguments)
    stst = 0
    if debug:
        print(cmd)
    else :  
        stst = os.system(cmd)

    return stst, cmd 

nav = lambda x: x+'Nav' # function to add Nav to the end of the string

# constants
# lists of the processes with an issue (run on PVeinsCroppedImage_new)
ISSUES = {'iNav' :['2022091601', '2022072202', '2021110501', '2021102901', '2021091001', 
             '2021081301', '2021070902', '2021062501', '2021061101', '2021052102', 
             '2021051401', '2021032601', '2020110601', '2020112701', '2021120301' ], 
         'dNav' : ['2022071502', '2022070102', '2022041301', '2022032501', '2022030401', 
             '2021121701', '2021101501', '2021100802', '2021092401', '2021091001', 
             '2021082701', '2021070902', '2021070901', '2021070202', '2021062501', 
             '2021061101', '2021052101', '2021051401', '2021041601', '2021032601', 
             '2021031902', '2020112701', '2021041601', 
             '2020092901', '2020102701', '2020110601', '2020111302', '2020121801',
             '2020121802', '2021011501', '2021112601', '2022012801', '2022030401',
             '2022031101', '2022032501', '2022041301', '2022052702', '2022061001',
             '2022061002', '2022061701', '2022061702', '2022071502', '2022072201',
             '2022072202', '2022080501', '2022081902', '2022082602', '2022090201']}

# all paths to dnav and inav folders 
PROJECT_FOLDERS = { 'dNav' : 'folders_dnav.txt', 'iNav' : 'folders_inav.txt'}
CEMRG_DIR = {'linux' : "$HOME/dev/build/CEMRG2-U20.04/MITK-build/bin", 
             'darwin' : "$HOME/dev/build/FORK.JASL.CEMRG/MITK-build/bin"}
MIRTK_DIR = {'linux' : "$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib", 
             'darwin' : "$HOME/dev/libraries/MLib"}
def main(args):
    """Main function"""


    #folder to process
    number = args.number
    x = args.x
    m = args.method
    debug = args.debug

    base_dic = {'windows': 'D:/', 'linux': '/media/jsl19/sandisk', 'darwin': '/Volumes/sandisk'}
    data_folder = '09-dnav_vs_inav/carmaf/carmaf_cemrg'
#    data_folder = f'09-dnav_vs_inav/carmaf/outstanding/{x}Nav' # outstanding cases
    method_str = 'IIR' if (m == 1) else 'MxSD'

    dir = fullfile(base_dic[chooseplatform()], data_folder)
    date_str = np.datetime_as_string(np.datetime64('today'), unit='D')
    log_file = fullfile(dir, 'log_' + nav(x) + '_' + method_str + '_' + date_str +'.txt')
    print('Log file: ' + log_file)

    os.system('echo "Starting batch_carmaf.py" >> ' + log_file)

    # read the list of folders
    with open(fullfile(dir, PROJECT_FOLDERS[nav(x)]), 'r') as f: 
        folders_xnav = f.readlines()

    list_of_numbers = []
    if number >= 0 : 
        list_of_numbers = [number]
    else: # process all folders
        list_of_numbers = range(len(folders_xnav))

    if args.folder != '':
        folderlist = args.folder.split(',')
        list_of_numbers = []
        # find if folder is contained in the list
        for idx, fx in enumerate(folders_xnav):
            for f in folderlist:
                if f in folders_xnav[idx]:
                    list_of_numbers.append(idx)

    total = len(folders_xnav)

    log_to_file(log_file, 'Processing ' + str(total) + ' folders')

    # prepare paths 
    paths_xnav = [fullfile(dir, q.strip()) for q in folders_xnav]
    for n in list_of_numbers:

        # extract case from this_folder
        this_case = folders_xnav[n].strip().split('/')[0]
        this_folder = paths_xnav[n]
    
        # remove files that start with ._ (macOS)
        for f in os.listdir(this_folder):
            if f.startswith('._'):
                os.remove(fullfile(this_folder, f))

        mvi = 'tx_prodMVI-by-mra2' + nav(x).lower() + '.vtk'
        pveins = 'PVeinsCroppedImage_new' if (this_case in ISSUES[nav(x)]) else 'PVeinsCroppedImage' 
        pveins += '.nii'
        output_sdir = 'OUTPUT_SWEEP'
        sweep = '0.7:0.01:1.5' if (m == 1) else '2.5:0.1:4'
    
        # find file in this_folder that starts with dcm-LGE
        lge = ''
        for f in os.listdir(this_folder):
            if f.startswith('dcm-LGE'):
                lge = f
                break
        
        # stop script if lge file is not found
        if lge == '':
            print('LGE file not found in ' + this_folder)
            log_to_file(log_file, 'LGE file not found in ' + this_folder)
            return

        # extract segmentation.vtk 
        arguments = [fullfile(this_folder, pveins)]
        arguments.append(fullfile(this_folder, 'segmentation.s.nii'))
        arguments.append('-iterations')
        arguments.append('1')
        seg_1_out, cmd_seg_1 = run_cmd(MIRTK_DIR[chooseplatform()], 'close-image', arguments, debug)
        if seg_1_out != 0: 
            print('Error in close image')
            log_to_file(log_file, 'Error in close image')
            continue

        arguments.clear()

        arguments = [fullfile(this_folder, 'segmentation.s.nii')]
        arguments.append(fullfile(this_folder, 'segmentation.vtk'))
        arguments.append('-isovalue')
        arguments.append('0.5')
        arguments.append('-blur')
        arguments.append('0')
        seg_2_out, cmd_seg_2 = run_cmd(MIRTK_DIR[chooseplatform()], 'extract-surface', arguments, debug)

        if seg_2_out != 0: 
            print('Error in extract surface')
            log_to_file(log_file, 'Error in extract surface')
            continue

        arguments.clear()

        arguments = [fullfile(this_folder, 'segmentation.vtk')]
        arguments.append(fullfile(this_folder, 'segmentation.vtk'))
        arguments.append('-iterations')
        arguments.append('10')
        seg_3_out, cmd_seg_3 = run_cmd(MIRTK_DIR[chooseplatform()], 'smooth-surface', arguments, debug) 

        if seg_3_out != 0:
            print('Error in smooth surface')
            log_to_file(log_file, 'Error in smooth surface')
            continue

        arguments.clear()

        arguments = ['-i']
        arguments.append(fullfile(this_folder, pveins))
        arguments.append('-mv')
        arguments.append('-mvname')
        arguments.append(mvi)
        if args.verbose:
            arguments.append('-v')

        mvi_out, cmd_mvi = run_cmd(CEMRG_DIR[chooseplatform()], 'MitkCemrgApplyExternalClippers', arguments, debug)
        
        if mvi_out != 0:
            print('MVI clipper failed for ' + this_folder)
            log_to_file(log_file, 'MVI clipper failed for ' + this_folder, 'ERROR')
            continue

        arguments.clear()

        arguments = ['-i']
        arguments.append(fullfile(this_folder, lge))
        arguments.append('-seg')
        arguments.append(pveins)
        arguments.append('-o')
        arguments.append(output_sdir)
        arguments.append('-m')
        arguments.append(str(m))
        arguments.append('-tv')
        arguments.append(sweep)
        arguments.append('-v')

        scar_out, cmd_scar = run_cmd(CEMRG_DIR[chooseplatform()], 'MitkCemrgScarProjectionOptions', arguments, debug)

        if scar_out != 0 :
            print('Scar projection failed for ' + this_folder)
            log_to_file(log_file, 'Scar projection failed for ' + this_folder, 'ERROR')
                

if __name__ == '__main__':
    
    input_parser = argparse.ArgumentParser(description='Batch processing of carmaf')
    input_parser.add_argument("-n", "--number", type=int, required=False, help="Number of the folder to process", default=-1)
    input_parser.add_argument("-f", "--folder", type=str, required=False, help="Folder(s) to process", default='')
    input_parser.add_argument("-x", "--x", type=str,choices=['d', 'i'], required=True, help="dNav or iNav") 
    input_parser.add_argument("-m", "--method", type=int, choices=[1, 2], required=True, help="Method (IIR=1, M+x*SD=2)")
    input_parser.add_argument("-d", "--debug", action="store_true", help="Debug mode")
    input_parser.add_argument("-v", "--verbose", action="store_true", help="Verbose mode")
    args = input_parser.parse_args()
    
    main(args)
