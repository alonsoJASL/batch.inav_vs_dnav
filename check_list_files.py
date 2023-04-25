import argparse

def main(args) : 
    KNOWN_ISSUES = {'iNav': ['2022091601', '2022072202', '2021110501', '2021102901', '2021091001',
                       '2021081301', '2021070902', '2021062501', '2021061101', '2021052102',
                       '2021051401', '2021032601', '2020110601', '2020112701', '2021120301'],
              'dNav': ['2022071502', '2022070102', '2022041301', '2022032501', '2022030401',
                       '2021121701', '2021101501', '2021100802', '2021092401', '2021091001',
                       '2021082701', '2021070902', '2021070901', '2021070202', '2021062501',
                       '2021061101', '2021052101', '2021051401', '2021041601', '2021032601',
                       '2021031902', '2020112701', '2021041601']}

    batch1_dnav_list = ['2020092901', '2020102701', '2020110601', '2020111302', '2020121801', '2020121802', '2021011501', '2021112601', '2022012801', '2022030401', '2022031101', '2022032501', '2022041301', '2022052702', '2022061001', '2022061002', '2022061701', '2022061702', '2022071502', '2022072201', '2022072202', '2022080501', '2022081902', '2022082602', '2022090201']
    sweep_dnav_list = KNOWN_ISSUES['dNav'] 

    # print folders in batch1_dnav_list but not in sweep_dnav_list 
    for f in batch1_dnav_list:
        mystr = 'YES:'
        if f not in sweep_dnav_list:
            mystr = 'NO:'

        if args.yes and mystr == 'YES:': 
            print(f'{mystr} {f}')
        
        if args.no and mystr == 'NO:':
            print(f'{mystr} {f}')

if __name__ == '__main__' : 
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--yes', '-y', action='store_true', help='Print folders in both')
    parser.add_argument('--no', '-n', action='store_true', help='Print folders in batch1 but not in sweep')

    args = parser.parse_args()
    main(args)
