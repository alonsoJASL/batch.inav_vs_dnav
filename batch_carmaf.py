import argparse
import os 
import platform 
import numpy as np
import pathlib 

def chooseplatform() :
    """Return the platform name"""
    return platform.system().lower() 
def fullfile(*args) :
    """Return the full path to a file"""
    return os.path.join(*args)
def log_to_file(log_file, log_str, log_status='INFO', print_to_console=False) :
    """Write a string to a file"""
    out_str = f'[{log_status}] {log_str} \n'
    try: 
        with open(log_file, 'a') as f:
            f.write(out_str)
    except FileNotFoundError : 
        print('File not found. Creating new file')
        with open(log_file, 'w') as f:
            out_str = f'{out_str} - File Created'
            f.write(out_str)
    
    if print_to_console:
        print(out_str)

def error_log(log_file, log_str) :
    """Write an error string to a file"""
    log_to_file(log_file, log_str, log_status='ERROR', print_to_console=True)

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
ISSUES = {
    'iNav': ['2022042201', '2022082602', '2021081301', '2021032601', '2020121802', '2021051401', 
             '2021111201', '2022090201', '2022052701', '2022080502', '2021112601', '2022070101', 
             '2022020401', '2022061702', '2022081201', '2022091601', '2021110501', '2021091001', 
             '2022092301', '2020112701', '2021070902', '2022072202', '2021061101', '2020110601', 
             '2022081902', '2020111302', '2020121801', '2022081202', '2022061001', '2022080501', 
             '2022092302', '2021102901', '2022050601', '2021062501', '2020102702', '2022070801', 
             '2022093001', '2021120301', '2022052001', '2022041301', '2022061701', '2022061002', 
             '2022030401', '2021052102', '2022031101', '2021112602', '2022032501', '2021011501', 
             '2021043002', 
             '2020112701', '2021120301'], # issues with outstanding cases 
    'dNav': ['2021011501', '2022070102', '2022061702', '2022090201', '2021091001', '2021032601', 
             '2021031902', '2021062501', '2021070202', '2021061101', '2022072202', '2021100802', 
             '2022061001', '2020092901', '2022041301', '2020110601', '2020112701', '2021082701', 
             '2020121802', '2021052101', '2021070901', '2021092401', '2022032501', '2021070902', 
             '2022052702', '2022031101', '2021121701', '2022012801', '2020102701', '2020111302', 
             '2020121801', '2022081902', '2021051401', '2022030401', '2022082602', '2021112601', 
             '2022071502', '2021041601', '2022072201', '2022061701', '2022061002', '2022080501', 
             '2021101501', 
             '2020112701', '2021041601']  # issues with outstanding cases
}

GOOD_FILES = ['2022093001', '2022092301', '2022091602', '2022091601', '2022081901', '2022080502', 
              '2022071502', '2022071501', '2022070102', '2022052702', '2022051301', '2022050601', 
              '2022042901', '2022040801', '2022040101', '2022012101', '2021111901', '2021102201', 
              '2021101501', '2021100802', '2021100801', '2021100101', '2021092401', '2021091701', 
              '2021091002', '2021091001', '2021090301', '2021082701', '2021080601', '2021073001', 
              '2021070902', '2021070901', '2021070202', '2021070201', '2021062501', '2021061802', 
              '2021061101', '2021052801', '2021052102', '2021051401', '2021043001', '2021032601', 
              '2021031902', '2021031901', '2020112001']

# all paths to dnav and inav folders 
PROJECT_FOLDERS = { 
    'dNav' : 'folders_dnav.txt', 
    'iNav' : 'folders_inav.txt'
}
CEMRG_DIR = {
    'linux' : "$HOME/dev/build/CEMRG2-U20.04/MITK-build/bin", 
    'darwin' : "$HOME/dev/build/FORK.JASL.CEMRG/MITK-build/bin",
    'windows' : "C:/dev/build/CEMRG/MITK-build/bin"
}
MIRTK_DIR = {
    'linux' : "$HOME/syncdir/cemrgapp_prebuilds/v2018.04.2/linux/Externals/MLib", 
    'darwin' : "$HOME/dev/libraries/MLib",
    'windows' : "C:/Lib/cemrg_libraries/MLib"
}

cmdapp_apply_clippers = { 
    'linux' : 'MitkCemrgApplyExternalClippers', 
    'darwin' : 'MitkCemrgApplyExternalClippers',
    'windows' : 'MitkCemrgApplyExternalClippers_release.bat'
}

cmdapp_scar_projection = {
    'linux' : 'MitkCemrgScarProjectionOptions', 
    'darwin' : 'MitkCemrgScarProjectionOptions',
    'windows' : 'MitkCemrgScarProjectionOptions_release.bat'
}

def main(args):
    """Main function"""


    #folder to process
    number = args.number
    x = args.x
    m = args.method
    folder = args.folder
    ignore = args.ignore_good_files
    debug = args.debug

    base_dic = {'windows': 'D:/', 'linux': '/media/jsl19/sandisk', 'darwin': '/Volumes/sandisk'}
    # data_folder = '09-dnav_vs_inav/carmaf/carmaf_cemrg'
    data_folder = '09-dnav_vs_inav/carmaf/outstanding' # outstanding cases
    method_str = 'IIR' if (m == 1) else 'MxSD'

    dir = fullfile(base_dic[chooseplatform()], data_folder)
    date_str = np.datetime_as_string(np.datetime64('today'), unit='D')
    log_file = fullfile(dir, f'log_{nav(x)}_{method_str}_{date_str}.txt')
    print('Log file: ' + log_file)

    log_to_file(log_file, 'Starting batch_carmaf', print_to_console=True) 
    log_to_file(log_file, 'Arguments: ' + str(args), print_to_console=True)

    # read the list of folders
    try:
        with open(fullfile(dir, PROJECT_FOLDERS[nav(x)]), 'r') as f: 
            folders_xnav = f.readlines()
    except FileNotFoundError:
        error_log(log_file, f'File {PROJECT_FOLDERS[nav(x)]} not found')
        return
    except UnicodeDecodeError:
        error_log(log_file, f'File {PROJECT_FOLDERS[nav(x)]} cannot be read, check the encoding')
        return

    list_of_numbers = []
    if number >= 0 : 
        list_of_numbers = [number]
    else: # process all folders
        list_of_numbers = range(len(folders_xnav))

    if folder != '':
        folderlist = folder.split(',')
        list_of_numbers = []
        # find if folder is contained in the list
        for idx, fx in enumerate(folders_xnav):
            for f in folderlist:
                if f in folders_xnav[idx]:
                    list_of_numbers.append(idx)

    total = len(list_of_numbers)

    log_to_file(log_file, f'Processing {total} folder(s)')

    # prepare paths 
    paths_xnav = [fullfile(dir, q.strip()) for q in folders_xnav]
    for n in list_of_numbers:
        # extract case from this_folder
        # this_case = folders_xnav[n].strip().split('/')[0]
        this_case = folders_xnav[n].strip().split('/')[1] # outstanding cases
        this_folder = paths_xnav[n]

        if ignore and (this_case in GOOD_FILES): 
            log_to_file(log_file, f'Ignoring {this_case}', print_to_console=True)
            continue
        else :
            log_to_file(log_file, f'Processing {this_case}')

        # remove files that start with ._ (macOS)
        for f in os.listdir(this_folder):
            if f.startswith('._'):
                os.remove(fullfile(this_folder, f))

        mvi = 'tx_prodMVI-by-mra2' + nav(x).lower() + '.vtk'
        pveins = 'PVeinsCroppedImage_new' if (this_case in ISSUES[nav(x)]) else 'PVeinsCroppedImage' 
        pveins += '.nii'
        output_sdir = args.output
        sweep = '0.7:0.01:1.5' if (m == 1) else '2.5:0.1:4'
    
        # find file in this_folder that starts with dcm-LGE
        lge = ''
        for f in os.listdir(this_folder):
            if f.startswith('dcm-LGE'):
                lge = f
                break
        
        # stop script if lge file is not found
        if lge == '':
            error_log(log_file, f'LGE file not found in {this_folder}')
            return
        
        if not pathlib.Path(fullfile(this_folder, pveins)).exists(): 
            error_log(log_file, f'PVeins file not found in {this_folder}')
            return
            
        # extract segmentation.vtk 
        arguments = [fullfile(this_folder, pveins)]
        arguments.append(fullfile(this_folder, 'segmentation.s.nii'))
        arguments.append('-iterations')
        arguments.append('1')
        seg_1_out, cmd_seg_1 = run_cmd(MIRTK_DIR[chooseplatform()], 'close-image', arguments, debug)
        if seg_1_out != 0: 
            error_log(log_file, 'Error in close image')
            continue

        log_to_file(log_file, cmd_seg_1, 'CMD')
        arguments.clear()

        arguments = [fullfile(this_folder, 'segmentation.s.nii')]
        arguments.append(fullfile(this_folder, 'segmentation.vtk'))
        arguments.append('-isovalue')
        arguments.append('0.5')
        arguments.append('-blur')
        arguments.append('0')
        seg_2_out, cmd_seg_2 = run_cmd(MIRTK_DIR[chooseplatform()], 'extract-surface', arguments, debug)

        if seg_2_out != 0: 
            error_log(log_file, 'Error in extract surface')
            continue

        log_to_file(log_file, cmd_seg_2, 'CMD')
        arguments.clear()

        arguments = [fullfile(this_folder, 'segmentation.vtk')]
        arguments.append(fullfile(this_folder, 'segmentation.vtk'))
        arguments.append('-iterations')
        arguments.append('10')
        seg_3_out, cmd_seg_3 = run_cmd(MIRTK_DIR[chooseplatform()], 'smooth-surface', arguments, debug) 

        if seg_3_out != 0:
            error_log(log_file, 'Error in smooth surface')
            continue

        log_to_file(log_file, cmd_seg_3, 'CMD')
        arguments.clear()

        arguments = ['-i']
        arguments.append(fullfile(this_folder, pveins))
        arguments.append('-mv')
        arguments.append('-mvname')
        arguments.append(mvi)
        if args.verbose:
            arguments.append('-v')

        mvi_out, cmd_mvi = run_cmd(CEMRG_DIR[chooseplatform()], cmdapp_apply_clippers[chooseplatform()], arguments, debug)
        
        if mvi_out != 0:
            error_log(log_file, f'MVI clipper failed for {this_folder}')
            continue

        log_to_file(log_file, cmd_mvi, 'CMD')
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

        scar_out, cmd_scar = run_cmd(CEMRG_DIR[chooseplatform()], cmdapp_scar_projection[chooseplatform()], arguments, debug)

        if scar_out != 0 :
            error_log(log_file, f'Scar projection failed for {this_folder}')
        
        log_to_file(log_file, cmd_scar, 'CMD')
                

if __name__ == '__main__':
    
    input_parser = argparse.ArgumentParser(description='Batch processing of carmaf')
    input_parser.add_argument("-n", "--number", type=int, required=False, help="Number of the folder to process", default=-1)
    input_parser.add_argument("-f", "--folder", type=str, required=False, help="Folder(s) to process", default='')
    input_parser.add_argument("-x", "--x", type=str,choices=['d', 'i'], required=True, help="dNav or iNav") 
    input_parser.add_argument("-m", "--method", type=int, choices=[1, 2], required=True, help="Method (IIR=1, M+x*SD=2)")
    input_parser.add_argument("-ignore", '--ignore-good-files', action='store_true', required=False, help='Ignore good files from analysis')
    input_parser.add_argument('-o', '--output', type=str, required=False, help='Output folder', default='OUTPUT_SWEEP')
    input_parser.add_argument("-d", "--debug", action="store_true", help="Debug mode")
    input_parser.add_argument("-v", "--verbose", action="store_true", help="Verbose mode")
    args = input_parser.parse_args()
    
    main(args)
