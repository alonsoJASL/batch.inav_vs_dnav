import os
import platform 
import shutil
def chooseplatform():
    """Return the platform name"""
    return platform.system().lower()

def nav(x): return x+'Nav'

def main() :

    x = 'd'
    
    BATCH_1 = {
        'dNav': ['2020092901', '2020102701', '2020110601', '2020111302', '2020121801', '2020121802',
                 '2021011501', '2021112601', '2022012801', '2022030401', '2022031101', '2022032501',
                 '2022041301', '2022052702', '2022061001', '2022061002', '2022061701', '2022061702',
                 '2022071502', '2022072201', '2022072202', '2022080501', '2022081902', '2022082602',
                 '2022090201'],
        'iNav': ['2020102702', '2020111302', '2020121801', '2020121802', '2021111201', '2021112601',
                 '2021112602', '2022020401', '2022030401', '2022031101', '2022032501', '2022041301',
                 '2022042201', '2022050601', '2022052001', '2022052701', '2022061001', '2022061002',
                 '2022061701', '2022061702', '2022070101', '2022070801', '2022072202', '2022080501',
                 '2022080502', '2022081201', '2022081202', '2022081902', '2022082602', '2022090201',
                 '2022091601', '2022092301', '2022092302', '2022093001']
    }

    base_dic = {'windows': 'D:/', 
                'linux': '/media/jsl19/sandisk',
                'darwin': '/Volumes/sandisk'}

    batch_1_folder = f'{base_dic[chooseplatform()]}/09-dnav_vs_inav/registration_issue/{x}NAV'
    target_folder = f'{base_dic[chooseplatform()]}/09-dnav_vs_inav/carmaf/carmaf_cemrg'

    for idx in BATCH_1[nav(x)]:
        # CEMRG/dNav/PVeinsCroppedImage_new.nii
        source_file = os.path.join(batch_1_folder, idx, 'CEMRG', nav(x), 'PVeinsCroppedImage_new.nii')
        target_file = os.path.join(target_folder, idx, 'CEMRG', nav(x), 'PVeinsCroppedImage_new.nii')

        cmd = f'cp {source_file} {target_file}'
        print(cmd)

        # os.system(cmd)
        try :
            shutil.copy(source_file, target_file)        
        except FileNotFoundError as e:
            print(e)
            continue


if __name__ == "__main__" :
    main()